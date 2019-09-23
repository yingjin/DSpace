/*
 * PeriodicalXMLGenerator.java
 *
 * Version: $Revision: ? $
 *
 * Date: $Date: 2008-12-17 (Wed, 17 Dec 2008) $
 *
 * Copyright (c) 2002-2005, Hewlett-Packard Company and Massachusetts
 * Institute of Technology.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * - Neither the name of the Hewlett-Packard Company nor the name of the
 * Massachusetts Institute of Technology nor the names of their
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */

package org.dspace.app.xmlui.utils;

import org.apache.commons.cli.*;
import org.dspace.app.xmlui.wing.Namespace;
import org.dspace.content.Collection;
import org.dspace.content.Item;
import org.dspace.core.Constants;
import org.dspace.core.Context;

import org.xml.sax.ContentHandler;
import org.xml.sax.ext.LexicalHandler;
import org.xml.sax.helpers.AttributesImpl;
import org.xml.sax.helpers.NamespaceSupport;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.sax.SAXTransformerFactory;
import javax.xml.transform.sax.TransformerHandler;
import javax.xml.transform.stream.StreamResult;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Iterator;
import java.util.TreeMap;

import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.content.service.CollectionService;


import org.dspace.handle.factory.HandleServiceFactory;
import org.dspace.handle.service.HandleService;

import org.dspace.content.MetadataValue;

import java.util.List;

// SAX classes.
//JAXP 1.1

/**
 * The code will generate the volume-issue tree in an XML
 *
 * @author  Ying Jin
 * @version $Revision: ? $
 */

public class PeriodicalXMLGenerator
{

        protected ContentHandler contentHandler;
        protected LexicalHandler lexicalHandler;

        protected NamespaceSupport namespaces;
        static ItemService itemService = ContentServiceFactory.getInstance().getItemService();
        static HandleService handleService = HandleServiceFactory.getInstance().getHandleService();
        static CollectionService collectionService = ContentServiceFactory.getInstance().getCollectionService();

        public static void main(String[] argv) throws Exception
        {
            String filePath = "/ds/data/dspace/config/externalXML";

            // create an options object and populate it
            CommandLineParser parser = new PosixParser();

            Options options = new Options();

//            options.addOption("f", "fix", false, "Fix data in DSpace");
            options.addOption("c", "collection", true,
                    "destination collection(s) Handle or database ID");

//            options.addOption("f", "fix", false, "Fix data in DSpace");
            options.addOption("p", "project", true,
                    "destination collection(s) name");

            options.addOption("h", "help", false, "help");

            CommandLine line = parser.parse(options, argv);

            String[] collections = null; // db ID or handles
            int status = 0;

            if (line.hasOption('h'))
            {
                HelpFormatter myhelp = new HelpFormatter();
                myhelp.printHelp("PeriodicalXMLGenerator\n", options);
                System.out
                        .println("\n PeriodicalXMLGenerator -c <collection handle> -p <colleciton name>");

                System.exit(0);
            }

            if (line.hasOption('c')) // collections
            {
                collections = line.getOptionValues('c');
            }

            if (collections == null)
            {
                    System.out
                            .println("Error - at least one destination collection must be specified");
                    System.out.println(" (run with -h flag for details)");
                    System.exit(1);
            }


            PeriodicalXMLGenerator xmlGen = new PeriodicalXMLGenerator();

            // create a context
            Context c = new Context();

            // find collections
            Collection[] mycollections = null;

            System.out.println("Destination collections:");

            mycollections = new Collection[collections.length];

            // validate each collection arg to see if it's a real collection
            for (int i = 0; i < collections.length; i++)
            {
                // is the ID a handle?
                if (collections[i].indexOf('/') != -1)
                {
                    // string has a / so it must be a handle - try and resolve
                    // it
                    mycollections[i] = (Collection) handleService
                            .resolveToObject(c, collections[i]);

                    // resolved, now make sure it's a collection
                    if ((mycollections[i] == null)
                            || (mycollections[i].getType() != Constants.COLLECTION))
                    {
                        mycollections[i] = null;
                    }
                }
                // not a handle, try and treat it as an integer collection
                // database ID
                else if (collections[i] != null)
                {
                    mycollections[i] = collectionService.findByLegacyId(c, Integer.parseInt(collections[i]));
                }

                // was the collection valid?
                if (mycollections[i] == null)
                {
                    throw new IllegalArgumentException("Cannot resolve "
                            + collections[i] + " to collection");
                }

                // print progress info
                String owningPrefix = "";

                if (i == 0)
                {
                    owningPrefix = "Owning ";
                }

                System.out.println(owningPrefix + " Collection: "
                        + mycollections[i].getName());

            }
            // end of validating collections
            xmlGen.generateXML(c, mycollections, filePath);


            System.exit(status);
        }

        private void generateXML(Context c, Collection[] mycollections, String filePath)
                throws Exception
        {

            /** Namespace declaration*/
            String cdsURI = "http://www.rice.edu/CDS/";
            Namespace CDS = new Namespace(cdsURI);
            HashMap thresherYear = new HashMap();

            thresherYear.put("46", "46 (1958-1959)");
            thresherYear.put("47", "47 (1959-1960)");
            thresherYear.put("48", "48 (1960-1961)");
            thresherYear.put("49", "49 (1961-1962)");
            thresherYear.put("50", "50 (1962-1963)");
            thresherYear.put("51", "51 (1963-1964)");
            thresherYear.put("52", "52 (1964-1965)");
            thresherYear.put("53", "53 (1965-1966)");
            thresherYear.put("54", "54 (1966-1967)");

            // go through all collections
            for (int i = 0; i < mycollections.length; i++)
            {

                TreeMap volumeIssue = new TreeMap();

                // get all items from the collection and find the issue items
                Iterator<Item> iterator = itemService.findAllByCollection(c, mycollections[i]);
                while (iterator.hasNext())
                 {
                    Item item = iterator.next();

                    String itemHandle = item.getHandle();
                    List<MetadataValue> dcvalue = itemService.getMetadata(item,"dc","citation", "pageNumber", Item.ANY);
                    if(dcvalue != null && dcvalue.size() != 0){
                        // this is an article, do nothing
                        List<MetadataValue> dcvolume = itemService.getMetadata(item,"dc","citation", "volumeNumber", Item.ANY);
                        String volumeNum = "";
                        if((dcvolume != null) && (dcvolume.size() != 0)){

                        }else{
                            System.out.println("This item " + itemHandle + " has no volume number!!!");
                        }

                        List<MetadataValue> dcissue = itemService.getMetadata(item, "dc","citation", "issueNumber", Item.ANY);
                        String issueNum = "";
                        if((dcissue != null) && (dcissue.size() != 0)){
                        }else{
                            System.out.println("This item " + itemHandle + " has no issue number!!!");
                        }
                    }else{
                        // this is an issue. I'd like to know the volume number, issue number, issue date and handle
                        List<MetadataValue> dcdate = itemService.getMetadata(item, "dc","date", "issued", Item.ANY);
                        String date = "";
                        if((dcdate != null) && (dcdate.size() != 0)){

                            //date = dcdate[0].value.substring(0,4);
                            date = dcdate.get(0).getValue();
                           // System.out.println("This item " + itemHandle + " Date is: " + date);

                        }else{
                            System.out.println("This item " + itemHandle + " has no date info!!!");
                        }

                        List<MetadataValue> dcvolume = itemService.getMetadata(item, "dc","citation", "volumeNumber", Item.ANY);
                        String volumeNum = "";
                        if((dcvolume != null) && (dcvolume.size() != 0)){


                            volumeNum = (String)thresherYear.get(dcvolume.get(0).getValue());
                            //System.out.println("This is a volume - " + volumeNum );

                        }else{
                            System.out.println("This item " + itemHandle + " has no volume number!!!");
                        }

                        List<MetadataValue> dcissue = itemService.getMetadata(item, "dc","citation", "issueNumber", Item.ANY);
                        String issueNum = "";
                        if((dcissue != null) && (dcissue.size() != 0)){
                            issueNum = dcissue.get(0).getValue();
                            //System.out.println("This is an issue - " + issueNum );

                        }else{
                            System.out.println("This item " + itemHandle + " has no issue number!!!");
                        }

                        ItemInfo itemInfo = new ItemInfo(itemHandle, volumeNum, date, issueNum);
                        volumeIssue.put(volumeNum+NomalizeIssue(issueNum)+itemHandle, itemInfo);
                    }

                }
                String outFile = filePath + "/" +mycollections[i].getHandle().replaceAll("/", "_") + ".xml";
                System.out.println("Generating XML: " + outFile);


                // PrintWriter
                PrintWriter out = new PrintWriter(new FileOutputStream(outFile));

                StreamResult streamResult = new StreamResult(out);

                SAXTransformerFactory tf = (SAXTransformerFactory) SAXTransformerFactory.newInstance();

                // SAX2.0 ContentHandler.

                TransformerHandler hd = tf.newTransformerHandler();

                Transformer serializer = hd.getTransformer();

                //serializer.setOutputProperty(OutputKeys.ENCODING,"ISO-8859-1");

                //serializer.setOutputProperty(OutputKeys.DOCTYPE_SYSTEM,"users.dtd");

                serializer.setOutputProperty(OutputKeys.INDENT,"yes");

                hd.setResult(streamResult);

                hd.startDocument();

                AttributesImpl atts = new AttributesImpl();
                atts.addAttribute("", "", "xmlns:cds", "CDATA", "http://www.rice.edu/CDS");
                atts.addAttribute("", "", "xmlns", "CDATA", "http://www.rice.edu/CDS");

                hd.startElement("","","issues",atts);

                
                Iterator it = volumeIssue.keySet().iterator();
                while (it.hasNext())
                {
                      String handle = (String)it.next();
                      ItemInfo itemInfo = (ItemInfo)volumeIssue.get(handle);
                      atts.clear();
                      if ((itemInfo.getVolume() !="") && (itemInfo.getIssue()!="")){
                        atts.addAttribute("","","vol","CDATA",itemInfo.getVolume());
                        atts.addAttribute("","","num","CDATA",itemInfo.getIssue());
                        atts.addAttribute("","","year","CDATA",itemInfo.getDate());
                        atts.addAttribute("","","handle","CDATA",itemInfo.getHandle());
                        hd.startElement("","","issue",atts);
                        hd.endElement("","","issue");
                      }
                }
                hd.endElement("","","issues");
                hd.endDocument();
              }
        }

private String NomalizeIssue(String issueNum){
    if(issueNum.length()==1){
        return "0"+issueNum;
    }
    return issueNum;
}

private class ItemInfo{

    private String handle;
    private String volume;
    private String date;
    private String issue;

    public ItemInfo(String handle, String volume, String date, String issue){
        this.handle = handle;
        this.volume = volume;
        this.date = date;
        this.issue = issue;
    }

    public String getHandle(){
        return this.handle;
    }
    public String getVolume(){
        return this.volume;
    }
    public String getDate(){
        return this.date;
    }
    public String getIssue(){
        return this.issue;
    }
}
}