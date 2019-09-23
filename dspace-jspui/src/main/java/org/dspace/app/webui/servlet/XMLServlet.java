package org.dspace.app.webui.servlet;

import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.Map.Entry;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.TransformerException;

import org.apache.log4j.Logger;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Bitstream;
import org.dspace.content.Bundle;
import org.dspace.content.MetadataValue;
import org.dspace.content.Item;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.core.LogManager;
import org.dspace.core.Utils;
import org.dspace.presentation.xsl.XMLTransform;
import org.dspace.presentation.xsl.XMLTransformManager;
import org.jdom.JDOMException;

import org.dspace.handle.factory.HandleServiceFactory;
import org.dspace.handle.service.HandleService;

import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
/**
 * Servlet for serving XML files transformed into HTML
 * <P>
 * <code>/xsl/1911/123/seq_num/file.xml?xsl=file.xsl</code> - transform item XML2HTML
 * @author Sid Byrd
 * @version $Revision: 1.0 $
 */
public class XMLServlet extends DSpaceServlet
{
    /** log4j category */
    private static Logger log = Logger.getLogger(XMLServlet.class);
    protected ItemService itemService = ContentServiceFactory.getInstance().getItemService();
    protected HandleService handleService = HandleServiceFactory.getInstance().getHandleService();

    /**
     * Construct the name of the transformed product to be used on the page for display
     * purposes and in URLs to indicate which stylesheet to use
     * @param sourceBitstream the Bitstream transformed
     * @param transform the XSLTransform applied to sourceBitstream
     * @return the URL / display name
     */
    public static String makeURLBitstreamName(Bitstream sourceBitstream, XMLTransform transform)
    {
        return sourceBitstream.getName().replace(".xml", "."+transform.getName()+".html");
    }

    /**
     * Given the output of makeURLBitstreamName(), extract the transform name
     * @param bitstream the source bitstream looked up from the URL request
     * @param urlBitstreamName the last part of the URL request
     * @return the specified transformer name (which may not actually exist as an XMLTransform)
     *  or null if something didn't match up
     */
    private static String getTransformNameFromURL(Bitstream bitstream, String urlBitstreamName)
    {
        // trim the final ".html", then trim everything after the last '.'
        int stop = urlBitstreamName.lastIndexOf(".html");
        if (stop != -1)
        {
            String transformName = urlBitstreamName.substring(0, stop);
            int start = transformName.lastIndexOf('.');
            if (start != -1)
            {
                transformName = transformName.substring(start+1); //don't include the '.'
                return transformName;
            }
        }

        return null;
    }

    // On the surface it doesn't make much sense for this servlet to
    // handle POST requests, but in practice some HTML pages which
    // are actually JSP get called on with a POST, so it's needed.
    protected void doDSPost(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
            {
        doDSGet(context, request, response);
            }

    protected void doDSGet(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
        Bitstream bitstream = null;
        Item item = null;

        // Get the ID from the URL
        String idString = request.getPathInfo();
        String handle = "";
        String sequence = "";
        String bitstreamURLName = "";

        if (idString != null)
        {
             // Parse 'handle' and 'sequence' (bitstream seq. number) out
             // of remaining URL path, which is typically of the format:
             //    {handle}/{sequence}/{bitstream-name}
             // But since the bitstream name MAY have any number of "/"s in
             // it, and the handle is guaranteed to have one slash, we
             // scan from the start to pick out handle and sequence:

             // Remove leading slash if any:
            if (idString.startsWith("/"))
            {
                idString = idString.substring(1);
            }

            // skip first slash within handle
            int slashIndex = idString.indexOf('/');
            if (slashIndex != -1)
            {
                slashIndex = idString.indexOf('/', slashIndex + 1);
                if (slashIndex != -1)
                {
                    handle = idString.substring(0, slashIndex);
                    // sequence is betweeen the handle and the next slash
                    int slash2 = idString.indexOf('/', slashIndex + 1);
                    if (slash2 != -1)
                    {
                        sequence = idString.substring(slashIndex+1,slash2);
                        // bitstreamURLname is after the last slash
                        // if this is an overlap with sequence, then it just won't load.
                        int lastSlash = idString.lastIndexOf('/');
                        if (lastSlash != -1)
                        {
                            bitstreamURLName = idString.substring(lastSlash+1);
                        }
                    }
                    else
                        sequence = idString.substring(slashIndex+1);
                }
                else
                    handle = idString;
            }

            // Find the corresponding bitstream
            try
            {
                item = (Item) handleService.resolveToObject(context,
                        handle);

                if (item == null)
                {
                    log.info(LogManager.getHeader(context, "invalid_id",
                            "path=" + handle));
                    JSPManager
                            .showInvalidIDError(request, response, handle, -1);

                    return;
                }

                int sid = Integer.parseInt(sequence);

                List<Bundle> bundles = item.getBundles();

                for (int i = 0; (i < bundles.size()) && bitstream == null; i++)
                {
                    List<Bitstream> bitstreams = bundles.get(i).getBitstreams();

                    for (int k = 0; (k < bitstreams.size()) && bitstream == null; k++)
                    {
                        if (sid == bitstreams.get(k).getSequenceID())
                        {
                            bitstream = bitstreams.get(k);
                        }
                    }
                }
            }
            catch (NumberFormatException nfe)
            {
                // Invalid ID - this will be dealt with below
            }
        }

        // Did we get a bitstream?
        if (bitstream != null)
        {
            // make sure the bitstream is xml
            String mimetype = bitstream.getFormat(context).getMIMEType();
            if (mimetype.equals("text/xml"))
            {
                // get schema name from item metadata's format.xmlschema
                List<MetadataValue> schemas = itemService.getMetadata(item, "dc", "format", "xmlschema", Item.ANY);
                String schema = (schemas.size() > 0)? schemas.get(0).getValue() : "";
                if (schema != null && schema.length() > 0)
                {
                    // get list of transformers that work for this schema
                    List<XMLTransform> transforms = XMLTransformManager.getTransformsForSchema(schema);
                    XMLTransform transform = null;

                    // get transform name from URL. If it's in the list, use it.
                    String transformName = getTransformNameFromURL(bitstream, bitstreamURLName);
                    for (XMLTransform t: transforms)
                    {
                        if (t.getName().equals(transformName))
                        {
                            transform = t;
                        }
                    }

                    // if named transformer wasn't found, take the first transformer that is valid for the schema
                    if (transform == null && transforms.size() > 0)
                    {
                        transform = transforms.get(0);
                    }

                    if (transform != null)
                    {
                        assert transform.isValidForSchema(schema);

                        // Make list of params, trimming each value to 20 chars for safety
                        // Only bother with params the transformer accepts.
                        Map<String, String> params = new HashMap<String, String>(transform.getParamsAccepted().size());
                        for (Entry<String, String> param : transform.getParamsAccepted().entrySet())
                        {
                            String paramValue = request.getParameter(param.getKey());
                            if (paramValue != null)
                            {
                                if (paramValue.length() > 20)
                                {
                                    paramValue = paramValue.substring(0, 20);
                                }
                                params.put(param.getKey(), paramValue);
                            }
                        }

                        // Do the transformation, taking care of caching, etc. as needed
                        InputStream bitsIn;
                        try
                        {
                            bitsIn = transform.transformedResult(context, item, bitstream, params);
                        }
                        catch (JDOMException e)
                        {
                            // error parsing the XML from the source bitstream
                            log.info(LogManager.getHeader(context, "xml_parse_error", e.getMessage()));
                            JSPManager.showInternalError(request, response);
                            return;
                        }
                        catch (TransformerException e)
                        {
                            // error performing transform, or error setting up transformer
                            log.info(LogManager.getHeader(context, "xsl_error", e.getMessage()));
                            JSPManager.showInternalError(request, response);
                            return;
                        }

                        // deliver the output
                        log.info(LogManager.getHeader(context, "view_bitstream",
                                "bitstream_id=" + bitstream.getID()));
               //                 +" xsltransform=" + transform.getName()));   // Ying commented this out as statistics won't work with this extra info

                        response.setContentType("text/html; charset=UTF-8");
                        Utils.bufferedCopy(bitsIn, response.getOutputStream());
                        bitsIn.close();
                        response.getOutputStream().flush();

                        return;
                    }
                    else
                    {
                        log.info(LogManager.getHeader(context, "bad_xsl_transform", transformName+"; "+schema));
                    }
                }
                else
                {
                    log.info(LogManager.getHeader(context, "no_schema_error", "item has no format.xmlschema"));
                }
            }
            else
            {
                log.info(LogManager.getHeader(context, "not_xml_error", "bitstream mimetype is not text/xml"));
            }

            // errors from above fall through to here
            String queryString = request.getQueryString();
            log.info(LogManager.getHeader(context, "xsl_invalid_request",
                idString+ ((queryString != null)?"?"+request.getQueryString():"")));
            JSPManager.showIntegrityError(request, response);

            return;

        }

        // No bitstream - we got an invalid ID
        log.info(LogManager.getHeader(context, "view_bitstream",
                "invalid_bitstream_id=" + idString));

        JSPManager.showInvalidIDError(request, response, idString,
                Constants.BITSTREAM);
    }

}
