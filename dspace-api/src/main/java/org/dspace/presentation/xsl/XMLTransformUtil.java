package org.dspace.presentation.xsl;

import java.lang.Exception;
import java.lang.String;
import java.util.ArrayList;
import java.util.List;
import java.util.Iterator;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.PosixParser;
import org.dspace.content.*;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.eperson.EPerson;

import org.dspace.handle.factory.HandleServiceFactory;
import org.dspace.handle.service.HandleService;
import org.dspace.eperson.factory.EPersonServiceFactory;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.eperson.service.EPersonService;
import org.dspace.content.service.CollectionService;
import org.dspace.content.service.ItemService;
import org.dspace.content.service.BundleService;
import org.dspace.content.service.BitstreamService;
import org.dspace.content.service.DSpaceObjectService;

//Ying updated for DSpace 6 upgrade

public class XMLTransformUtil
{
    
    /**
     * invoke as:
     * ds dsrun org.dspace.content.transform.XMLTransformUtil --collection=1911/2863
     * --eperson=sidb@rice.edu --primary="text/xml" --description="TEI-encoded original"
     * --schema=tei --removecached
     *   to set the first "text/xml" type doc to be the primary bitstream, to ste that bitstream's description, to add
     *   a format.xmlschema=tei on the containing item, and to remove all bitstreams with the same name as the primary
     *   +".xsl="
     * @param args
     *
     */
    public static void main(String[] args) throws Exception
    {
        // create an options object and populate it
        CommandLineParser parser = new PosixParser();
        Options options = new Options();
        HandleService handleService = HandleServiceFactory.getInstance().getHandleService();
        EPersonService ePersonService = EPersonServiceFactory.getInstance().getEPersonService();
        CollectionService collectionService = ContentServiceFactory.getInstance().getCollectionService();
        ItemService itemService = ContentServiceFactory.getInstance().getItemService();
        BundleService bundleService = ContentServiceFactory.getInstance().getBundleService();
        BitstreamService  bitstreamService = ContentServiceFactory.getInstance().getBitstreamService();
        
        
        options.addOption("c", "collection", true, "prepare items in collection");
        options.addOption("h", "handle", true, "prepare items with handle");
        options.addOption("p", "primary", true, "set bitstream with mimetype to primary");
        options.addOption("d", "description", true, "set item description");
        options.addOption("e", "eperson", true, "authorized user");
        options.addOption("s", "schema", true, "schema type");
        options.addOption("r", "removecached", false, "remove cached sxl transformed html docs");
        CommandLine line = parser.parse(options, args);
        
        // create a context
        Context c = new Context();
        
        // find the EPerson, assign to context
        String eperson = "";
        if (line.hasOption('e'))
        {
            eperson = line.getOptionValue('e');
        }
        else
        {
            System.out.println("Error, must specify eperson");
            System.exit(1);
        }
        EPerson myEPerson = null;
        if (eperson.indexOf('@') != -1)
        {
            // @ sign, must be an email
            myEPerson = ePersonService.findByEmail(c, eperson);
        }
        else
        {
            myEPerson = ePersonService.findByIdOrLegacyId(c, eperson);
        }
        if (myEPerson == null)
        {
            System.out.println("Error, eperson cannot be found: " + eperson);
            System.exit(1);
        }
        c.setCurrentUser(myEPerson);
        
        // make a list of the items to do...
        List<Item> items = new ArrayList<Item>();
        
        // if just one handle, that's easy
        if (line.hasOption('h'))
        {
            Item item = (Item)handleService.resolveToObject(c, line.getOptionValue('h'));
            if (item == null || item.getType() != Constants.ITEM)
            {
                System.out.println("Error, cannot find item with given handle");
                System.exit(1);
            }
            items.add(item);
        }

        DSpaceObjectService dspaceObjectService = ContentServiceFactory.getInstance().getDSpaceObjectService(Constants.ITEM);

        // if a whole collection, add each item in the collection.
        if (line.hasOption('c'))
        {
            String collectionStr = line.getOptionValue('c');
            Collection collection = null;
            // is the ID a handle?
            if (collectionStr.indexOf('/') != -1)
            {
                // string has a / so it must be a handle - try and resolve
                collection = (Collection) handleService.resolveToObject(c, collectionStr);
                // resolved, now make sure it's a collection
                if ((collection == null) || (collection.getType() != Constants.COLLECTION))
                {
                    collection = null;
                }
            }
            // not a handle, try and treat it as an integer collection
            // database ID
            else if (collectionStr != null)
            {
                collection = collectionService.findByIdOrLegacyId(c, collectionStr);
            }
            // was the collection valid?
            if (collection == null)
            {
                throw new IllegalArgumentException("Cannot resolve "
                                                   + collectionStr + " to collection");
            }
            
            // now get all the items in that collection
            Iterator<Item> cItems = itemService.findAllByCollection(c, collection);
            while (cItems.hasNext()){
                items.add(cItems.next());
            }
        }
        else
        {
            System.out.println("Error, must specify collection or handle");
            System.exit(1);
        }
        
        // should we set the primary bitstream?
        String primaryMimetype = null;
        if (line.hasOption('p'))
        {
            primaryMimetype = line.getOptionValue('p');
        }
        
        // should we add a description?
        String description = null;
        if (line.hasOption('d'))
        {
            description = line.getOptionValue('d');
        }
        
        // should we add a format.xmlschema to the item?
        String schema = null;
        if (line.hasOption('s'))
        {
            schema = line.getOptionValue('s');
        }
        
        // should we removed cached xsl transformations?
        boolean removeCached = line.hasOption('r');
        
        
        // Actually DO stuff
        try
        {
            if(!c.ignoreAuthorization()){
                c.turnOffAuthorisationSystem();
            }
            for (Item item : items)
            {
                System.out.println("Item "+item.getHandle()+"...");
                // get the ORIGINAl bundle
                List<Bundle> bundles = itemService.getBundles(item, "ORIGINAL");
                if (bundles.size() < 1)
                {
                    System.out.println(" - Error, item has no ORIGINAL bundle. Skipping.");
                }
                else
                {
                    Bundle bundle = bundles.get(0);
                    
                    // set the primary bitstream if requested
                    if (primaryMimetype != null)
                    {
                        // find the first bitstream with primaryMimetype
                        List<Bitstream> bitstreams = bundle.getBitstreams();
                        Bitstream xmlBitstream = null;
                        for (int i=0; i<bitstreams.size() && xmlBitstream == null; i++)
                        {
                            Bitstream b = bitstreams.get(i);
                            if ((bitstreamService.getFormat(c, b).getMIMEType()).equals(primaryMimetype))
                            {
                                xmlBitstream = b;
                            }
                        }
                        if (xmlBitstream == null)
                        {
                            System.out.println(" - no bitstream with mimetype "+primaryMimetype+" found");
                        }
                        
                        // set it as primary bitstream
                        else
                        {
                            bundle.setPrimaryBitstreamID(xmlBitstream);
                            //bundle.update();
                            System.out.println(" - set primary bitstream to "+xmlBitstream.getName());
                        }
                    }
                    
                    // set the primary bitstream's description if requested
                    Bitstream primary = bundle.getPrimaryBitstream();
                    if (primary != null && description != null)
                    {
                        //Bitstream primary = Bitstream.find(c, pb);
                        if (primary == null
                            || (primaryMimetype != null && !bitstreamService.getFormat(c, primary).getMIMEType().equals(primaryMimetype)))
                        {
                            System.out.println(" - can't set desctription; no correct primary bitstream");
                        }
                        else
                        {
                            primary.setDescription(c, description);
                            
                            //primary.update();
                            System.out.println(" - description set");
                        }
                    }
                    
                    // set the item's format.xmlschema if requested
                    if (primary != null && schema != null)
                    {
                        //Bitstream primary = bitstreamService.find(c, pb);
                        if (primary == null
                            || (primaryMimetype != null && !bitstreamService.getFormat(c, primary).getMIMEType().equals(primaryMimetype)))
                        {
                            System.out.println(" - can't set schema; no correct primary bitstream");
                        }
                        else
                        {
                            // remove any existing format.xmlschema
                            dspaceObjectService.clearMetadata(c, item, "format", "xmlschema", null, Item.ANY);
                            dspaceObjectService.addMetadata(c, item, "format", "xmlschema", null, Item.ANY, schema);
                            dspaceObjectService.update(c, item);
                            System.out.println(" - schema set");
                        }
                    }
                    
                    // remove cached xsl transformed docs
                    if (removeCached)
                    {
                        // get the HTML bundle
                        List<Bundle> cacheBundles = itemService.getBundles(item, CachedXMLTransform.CACHE_BUNDLE_NAME);
                        if (cacheBundles.size() < 1)
                        {
                            System.out.println(" - no cache bundle present");
                        }
                        else
                        {
                            for(int c1=0; c1<cacheBundles.size();c1++){
                                Bundle cacheBundle = cacheBundles.get(c1);
                            
                                // check each bitstream's name and delete matches
                                List<Bitstream> bitstreams = cacheBundle.getBitstreams();
                                for (int i=0; i<bitstreams.size(); i++)
                                {
                                    Bitstream b = bitstreams.get(i);
                                    if (b.getName().contains(".xml.") && (bitstreamService.getFormat(c, b)).getMIMEType().equals("text/html"))
                                    {
                                        System.out.println(" - removed bitstream "+b.getName());
                                        bitstreamService.delete(c, b);
                                    }
                                }
                                //cacheBundle.update();
                            }
                        }
                    }
                }
            }
            
            // commit all transactions
            c.complete();
        }
        catch (Exception e)
        {
            c.abort();
            e.printStackTrace();
            System.out.println(e);
        }
        
    }
    
}
