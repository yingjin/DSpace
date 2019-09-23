package org.dspace.presentation.xsl;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.xml.transform.TransformerException;

import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.BitstreamFormat;
import org.dspace.content.Bundle;
import org.dspace.content.Bitstream;
import org.dspace.content.Item;
import org.dspace.core.Context;
import org.dspace.core.LogManager;
import org.jdom.JDOMException;
import org.jdom.transform.XSLTransformException;

import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.content.service.BundleService;
import org.dspace.content.service.BitstreamService;
import org.dspace.content.service.BitstreamFormatService;

public class CachedXMLTransform extends XMLTransform
{
    /** log4j category */
    private static Logger log = Logger.getLogger(CachedXMLTransform.class);
    ItemService itemService = ContentServiceFactory.getInstance().getItemService();
    BundleService bundleService = ContentServiceFactory.getInstance().getBundleService();
    BitstreamService  bitstreamService = ContentServiceFactory.getInstance().getBitstreamService();
    BitstreamFormatService bitstreamFormatService = ContentServiceFactory.getInstance().getBitstreamFormatService();
    

    /**
     * See superclass - does nothing extra in constructor
     */
    protected CachedXMLTransform(String name, String filename, List<File> dependencies, String description,
            Map<String, String> paramsAccepted, List<String> schemasTransformed, boolean transformBitstreamLinks,
            boolean transformThumbnails, boolean reloadXSL)
    throws XSLTransformException
    {
        super(name, filename, dependencies, description, paramsAccepted, schemasTransformed,
                transformBitstreamLinks, transformThumbnails, reloadXSL);
    }

    /** The name of the bundle created to store cached transformations of the xml file */
    public static final String CACHE_BUNDLE_NAME = "HTML";

    private String makeCachedBitstreamName(Bitstream sourceBitstream, Map<String, String> params)
    {
        StringBuilder cachedNameTemp = new StringBuilder();
        cachedNameTemp.append(sourceBitstream.getName()+".xsl="+getName());
        for (Entry<String, String> param : params.entrySet())
        {
            cachedNameTemp.append("&"+param.getKey()+"="+param.getValue());
        }
        return cachedNameTemp.toString();
    }

    /**
     * Returns the string to be stored in a cache bitstream's source field.
     * Before storing it the time should be appended.
     * @param stylesheetName the stylesheet used to make the cached bitstream
     * @return the source string
     */
    private static String makeCachedBitstreamSource(String stylesheetName)
    {
        return "XSL:"+stylesheetName+" cached at ";
    }

    private Bundle findCacheBundle(Item item)
    {
        try
        {
            List<Bundle> bundles = itemService.getBundles(item, CACHE_BUNDLE_NAME);
            if (bundles.size() > 0)
            {
                return bundles.get(0);
            }
        }
        catch  (SQLException e)
        {
        }
        return null;
    }

    private Bitstream findCachedBitstream(String cachedName, Bundle cacheBundle)
    {
        for (Bitstream bitstream : cacheBundle.getBitstreams())
        {
            if (bitstream.getName().equals(cachedName))
            {
                return bitstream;
            }
        }
        return null;
    }

    private boolean cachedBitstreamIsUpToDate(Bitstream cachedBitstream)
    {
        // compare the timestamp recorded in the cached bitstream's source field
        //  to the transformer's timestamp
        String sourceStr = cachedBitstream.getSource();
        String sourcePrefix = makeCachedBitstreamSource(getName());
        if (sourceStr != null && sourceStr.startsWith(sourcePrefix))
        {
            String cacheModifiedStr = sourceStr.substring(sourcePrefix.length());
            try
            {
                long cacheModified = Long.parseLong(cacheModifiedStr);
                if (lastModified(true) < cacheModified)
                {
                    // FIXME - is there a non-hack way to check when the bitstream was modified?
                    return true;
                }
            }
            catch (NumberFormatException e)
            {
                // falls through to return false
            }
        }
        return false;
    }

    private void deleteCachedBitstream(Context context, Bundle cacheBundle, Bitstream cachedBitstream) throws AuthorizeException, SQLException, IOException
    {
        try
        {
            if(!context.ignoreAuthorization()){
                context.turnOffAuthorisationSystem();
            }
            bitstreamService.delete(context, cachedBitstream);
            //cacheBundle.update();
            context.commit();
        }
        finally
        {
            if(context.ignoreAuthorization()){
                context.restoreAuthSystemState();
            }
        }
    }

    private void createCachedBitstream(Context context, Item item, Bundle cacheBundle, Bitstream sourceBitstream,
            String cachedName, InputStream bitsIn) throws AuthorizeException, SQLException, IOException
    {
        try
        {
            if(!context.ignoreAuthorization()){
                context.turnOffAuthorisationSystem();
            }

            // first, create new bundle if needed
            if (cacheBundle == null)
            {
                cacheBundle = bundleService.create(context, item, CACHE_BUNDLE_NAME);
                
            }

            assert(bitsIn.markSupported());
            bitsIn.mark(bitsIn.available()+1);
            Bitstream cacheBitstream = bitstreamService.create(context, cacheBundle, bitsIn);
            
            if (bitsIn.markSupported())
            bitsIn.reset();

            // Now set the format and name of the bitstream
            cacheBitstream.setName(context, cachedName);
            cacheBitstream.setSource(context, makeCachedBitstreamSource(getName())
                    + String.valueOf(System.currentTimeMillis()));
            cacheBitstream.setDescription(context, sourceBitstream.getName()+": "+getDescription());
            BitstreamFormat bf = bitstreamFormatService.findByShortDescription(context, "HTML");
            bitstreamService.setFormat(context, cacheBitstream, bf);

            log.info(LogManager.getHeader(context, "cache_transformed_bitstream",
                    "bitstream_id=" + cacheBitstream.getID()));
            bitstreamService.update(context, cacheBitstream);
            itemService.update(context, item);
            context.commit();
        }
        finally
        {
            if(context.ignoreAuthorization()){
                context.restoreAuthSystemState();
            }
        }
    }

    public InputStream transformedResult(Context context, Item item, Bitstream sourceBitstream,
            Map<String, String> params)
            throws AuthorizeException, SQLException, IOException, JDOMException, TransformerException
    {
        // find existing cached bitstream if present
        String cachedName = makeCachedBitstreamName(sourceBitstream, params);
        Bundle cacheBundle = findCacheBundle(item);
        Bitstream cachedBitstream = null;
        if (cacheBundle != null)
        {
            cachedBitstream = findCachedBitstream(cachedName, cacheBundle);
        }

        // delete the cached copy if it's out of date
        if (cachedBitstream != null && !cachedBitstreamIsUpToDate(cachedBitstream))
        {
           // Ying commented out this to avoid the bitstream got deleted and can't generate the new one
           // deleteCachedBitstream(context, cacheBundle, cachedBitstream);
           // cachedBitstream = null;
        }

        InputStream bitsIn;
        if (cachedBitstream == null)
        {
            // If no valid cached result, transform the source and cache a copy
            bitsIn = super.transformedResult(context, item, sourceBitstream, params);
            // TODO - check whether parameters validated before we cache anything
            createCachedBitstream(context, item, cacheBundle, sourceBitstream, cachedName, bitsIn);
        } else {
            // If a valid cached copy was found, just use that.
            bitsIn = bitstreamService.retrieve(context,cachedBitstream);
        }

        return bitsIn;
    }

}





/*{

    // This is where we'll put something to serve.
    InputStream bitsIn = null;

    // if no valid cached bitstream, transform the content to make one
    if (cacheBitstream == null)
    {
        log.info(LogManager.getHeader(context, "transform_bitstream",
                "bitstream_id=" + bitstream.getID() + " using xsl=" + transform.getName()));

        // parse in the xml from the source bitsream
        Document xmlfile;
        Document htmlfile;
        try
        {
            SAXBuilder builder = new SAXBuilder();
            xmlfile = builder.build(bitstream.retrieve());
        }
        catch (JDOMException e)
        {
            log.info(LogManager.getHeader(context, "xml_error",
                    e.getMessage()));
            JSPManager.showInternalError(request, response);
            return;
        }

        // run the XSLT transformation
        try
        {
            htmlfile = transform.transformXML(xmlfile, params);
            // TODO - check whether parameters validated before we cache anything
        }
        catch (TransformerException e)
        {
            // error performing transform, or error setting up transformer
            log.info(LogManager.getHeader(context, "xslt_error",
                    e.getMessage()));
            JSPManager.showInternalError(request, response);
            return;
        }

        // find servlet names for direct access to all bitstreams in the Item
        Map<String, List<String>> map = getAllBitstreamURLs(item, request.getContextPath());
        // replace all image source to the RetrieveServlet for faster display
        replaceMatchingAttributes(htmlfile, "img", "src", map, 0);
        // replace all www bitstream links to the BitstreamServlet for standard URL display
        replaceMatchingAttributes(htmlfile, "a", "href", map, 1);

        // serialize html output to a buffer
        XMLOutputter outputter = new XMLOutputter();
        ByteArrayOutputStream bitsOut = new ByteArrayOutputStream();
        outputter.output(htmlfile, bitsOut);
        bitsIn = new ByteArrayInputStream(bitsOut.toByteArray());

        // cache the transformed result
        if (transform.allowsCaching())
        {

        }
    }
    else
    {
        // using cached bitstream
        bitsIn = cacheBitstream.retrieve();
    }
}
*/
