/*
 * ThresherXMLGenerator.java
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
import org.dspace.core.Context;
import org.dspace.core.Constants;
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
import org.dspace.core.ConfigurationManager;

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

public class ThresherXMLGenerator
{

        protected ContentHandler contentHandler;
        protected LexicalHandler lexicalHandler;

        protected NamespaceSupport namespaces;

        static ItemService itemService = ContentServiceFactory.getInstance().getItemService();
        //BundleService bundleService = ContentServiceFactory.getInstance().getBundleService();
        //BitstreamService  bitstreamService = ContentServiceFactory.getInstance().getBitstreamService();
        //BitstreamFormatService bitstreamFormatService = ContentServiceFactory.getInstance().getBitstreamFormatService();
        static HandleService handleService = HandleServiceFactory.getInstance().getHandleService();
        static CollectionService collectionService = ContentServiceFactory.getInstance().getCollectionService();
    
    
        public static void main(String[] argv) throws Exception
        {
            //String filePath = "/ds/sw/dspace/config/externalXML";
            String filePath = ConfigurationManager.getProperty("xmlui.externalxml.dir");
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
                myhelp.printHelp("ThresherXMLGenerator\n", options);
                System.out
                        .println("\n ThresherXMLGenerator -c <collection handle> -p <colleciton name>");

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


            ThresherXMLGenerator xmlGen = new ThresherXMLGenerator();

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
            HashMap<String, String> RIPYear = new HashMap();


            // go through all collections
            for (int i = 0; i < mycollections.length; i++)
            {

                TreeMap volumeIssue = new TreeMap();
               // use the record the volume # and year range
                RIPYear = new HashMap();

                // get all items from the collection and find the issue items
                Iterator<Item> iterator = itemService.findAllByCollection(c, mycollections[i]);
                while (iterator.hasNext())
                 {

                    Item item = iterator.next();

                    String itemHandle = item.getHandle();
                    ItemService itemService = ContentServiceFactory.getInstance().getItemService();
                    
                    List<MetadataValue>  dcpage = itemService.getMetadata(item, "dc","citation", "pageNumber", Item.ANY);
                    List<MetadataValue>  dcvolume = itemService.getMetadata(item, "dc","citation", "volumeNumber", Item.ANY);
                    List<MetadataValue>  dcissue = itemService.getMetadata(item, "dc","citation", "issueNumber", Item.ANY);
                    List<MetadataValue>  dcvolumeyear = itemService.getMetadata(item,"dc","citation", "volumeYear", Item.ANY);
                    if(dcpage != null && dcpage.size() != 0){
                        // this is an article, do nothing
                        if((dcvolume != null) && (dcvolume.size() != 0)){
                        }else{
                            System.out.println("This item " + itemHandle + " has no volume number!!!");
                        }

                        if((dcissue != null) && (dcissue.size() != 0)){
                        }else{
                            System.out.println("This item " + itemHandle + " has no issue number!!!");
                        }
                        if((dcvolumeyear != null) && (dcvolumeyear.size() != 0)){
                        }else{
                            System.out.println("This item " + itemHandle + " has no volume year!!!");
                        }
                    }else{
                        // this is an issue volume index. I'd like to know the volume number, and/or issue number, issue date and handle
                        // let's see if there is any issue numbers
/*
                        if((dcvolume != null) && (dcvolume.length != 0)){
                            volumeNum = dcvolume[0].value;
                            if((dcissue != null) && (dcissue.length != 0)){
                                issueNum = dcissue[0].value;
                            }
                        }else{
                            System.out.println("This item " + itemHandle + " has no volume number!!!");
                        }
*/
/*
                        DCValue[] dctitle = item.getMetadata("dc","title",null, Item.ANY);
                        String title = "";
                        if((dctitle != null) && (dctitle.length != 0)){

                            //date = dcdate[0].value.substring(0,4);
                            title = dctitle[0].value;
                           // System.out.println("This item " + itemHandle + " Date is: " + date);

                        }else{
                            System.out.println("This item " + itemHandle + " has no title info!!!");
                        }

                        Pattern pattern1 = Pattern.compile("\\d\\d\\d\\d-\\d\\d\\d\\d");
                        Pattern pattern2 = Pattern.compile("\\d\\d\\d\\d");

                		Matcher matcher = pattern1.matcher(title);
                        String year = "";
                        if(matcher.find()){
                            year = title.substring(matcher.start(), matcher.end());
                            System.out.println("Match first pattern - " + year);
		                }else{
                            matcher = pattern2.matcher(title);
                            if(matcher.find()){
                                year = title.substring(matcher.start(), matcher.end());
                                System.out.println("Match second pattern - " + year);
                            }
                        }

                        if(year!=""){
                            date = year;
                        }
*/

                        String volumeNum = "";
//                        DCValue[] dcvolume = item.getMetadata("dc","citation", "volumeNumber", Item.ANY);
                        if((dcvolume != null) && (dcvolume.size() != 0)){


                            volumeNum = dcvolume.get(0).getValue();
                            if(volumeNum.equalsIgnoreCase("Index")){
                                volumeNum = "0";
                            }
                            //System.out.println("This is a volume - " + volumeNum );

                        }else{
                            System.out.println("This item " + itemHandle + " has no volume number!!!");
                        }

                        String issueNum = "";
//                        DCValue[] dcissue = item.getMetadata("dc","citation", "issueNumber", Item.ANY);
                        if((dcissue != null) && (dcissue.size() != 0)){
                            issueNum = dcissue.get(0).getValue();
                            if(issueNum.equalsIgnoreCase("Index")){
                                issueNum = "0";
                            }
                            //System.out.println("This is an issue - " + issueNum );

                        }else{
                            System.out.println("This item " + itemHandle + " has no issue number!!!");
                        }

                        String volumeYear = "";
                        if((dcvolumeyear != null) && (dcvolumeyear.size() != 0)){
                            volumeYear = dcvolumeyear.get(0).getValue();
                            //System.out.println("This is an issue - " + issueNum );

                        }else{
                            System.out.println("This item " + itemHandle + " has no volume year!!!");
                        }

                        List<MetadataValue>  dcdate = itemService.getMetadata(item, "dc","date", "issued", Item.ANY);
                        String date = "";
                        if((dcdate != null) && (dcdate.size() != 0)){

                            date = dcdate.get(0).getValue();
                            //  System.out.println("This item " + itemHandle + " Date is: " + date);

                        }else{
                            System.out.println("This item " + itemHandle + " has no date info!!!");
                        }

                        ItemInfo itemInfo = new ItemInfo(itemHandle, volumeNum, date, issueNum, volumeYear);
                        volumeIssue.put(NomalizeNum(volumeNum)+NomalizeNum(issueNum)+itemHandle, itemInfo);
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
                      String volnum = itemInfo.getVolume();
                      atts.clear();
                      if (itemInfo.getVolume() !=""){
                          String date = itemInfo.getDate();
                          atts.addAttribute("","","year","CDATA",date);
                          if(itemInfo.getVolume().equalsIgnoreCase("0")){
                              atts.addAttribute("","","vol","CDATA","Index");
                          }else{
                              int datei = Integer.parseInt(date.substring(0,4));
                              String datev = date.substring(0,4);
                              String volumeYear = itemInfo.getVolyear();
                              // add another field for grouping in order

                              if(RIPYear.containsKey(volnum)){
                                  //atts.addAttribute("","","vol","CDATA",volnum+" ("+RIPYear.get(volnum)+")");
                                  atts.addAttribute("","","vol","CDATA",volnum+" ("+ volumeYear +")");
                                  atts.addAttribute("","","groupingvol","CDATA",NomalizeNum(volnum)+""+volumeYear);
                              }else{

                                  int datej = datei + 1;
                                  datev = datei + "-" + datej;
                                  RIPYear.put(volnum, datev);
                                  // let's replace the datev with volumeYear
                                  //atts.addAttribute("","","vol","CDATA",volnum+" ("+datev+")");
                                  //String volumeYear = itemInfo.getVolyear();
                                  atts.addAttribute("","","vol","CDATA",volnum+" ("+volumeYear+")");
                                  atts.addAttribute("","","groupingvol","CDATA",NomalizeNum(volnum)+""+volumeYear);
                              }
                          }
                          if(itemInfo.getIssue().equalsIgnoreCase("0")){
                                atts.addAttribute("","","num","CDATA","Index");
                          }else{
                                atts.addAttribute("","","num","CDATA",itemInfo.getIssue());
                          }
                          atts.addAttribute("","","handle","CDATA",itemInfo.getHandle());
                          hd.startElement("","","issue",atts);
                          hd.endElement("","","issue");
                      }else{

                          System.out.println("============ itemInfo is empty!!!");
                      }
                }
                hd.endElement("","","issues");
                hd.endDocument();
              }
        }

private String NomalizeNum(String num){
    if(num.length()==1){
        return "00"+num;
    }if (num.length()==2){
        return "0"+num;
    }
    return num;
}

private class ItemInfo{

    private String handle;
    private String volume;
    private String date;
    private String issue;
    private String volyear;

    public ItemInfo(String handle, String volume, String date, String issue, String volyear){
        this.handle = handle;
        this.volume = volume;
        this.volyear = volyear;
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
    public String getVolyear(){
        return this.volyear;
    }
}


}