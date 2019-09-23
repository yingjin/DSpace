/*
 * CitationManager.java
 *
 * Version: $Revision: ? $
 *
 * Date: $Date: 2007-12-02 (Mon, 02 Dec 2007) $
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

package org.dspace.app.util;

import java.io.File;
import java.util.*;
import java.lang.Exception;
import org.xml.sax.SAXException;
import org.w3c.dom.*;
import javax.xml.parsers.*;

import org.apache.log4j.Logger;

import org.dspace.content.MetadataSchema;
import org.dspace.core.ConfigurationManager;
import org.dspace.content.MetadataValue;
import org.dspace.content.Collection;
import org.dspace.content.Community;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.core.Context;
import org.dspace.eperson.EPerson;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.eperson.factory.EPersonServiceFactory;
import org.dspace.eperson.service.EPersonService;


/**
 * Citation generator for DSpace. Reads and parses the citation definition
 * file which is configed in dspace.cfg.
 *
 * @author  Ying Jin
 * @version $Revision: ? $
 */

public class CitationManager
{
    private static final String DEFAULT_CITATION = "default";
    // default multiple value seperator
    private static final String DEFAULT_SEPERATOR = ", ";

    /** log4j logger */
    private static Logger log = Logger.getLogger(CitationManager.class);


    private static Boolean configed = false;

    /** The fully qualified pathname of the citation definition XML file configed in dspace.cfg*/
    //private String defsFile = ConfigurationManager.getProperty("citation-config");

    /**
     * Reference to the scope to citations map, computed from the citations
     * definition file. With <key, value> pair of <scope+document-type name, citation name>
     */
    private static HashMap<String, String> whichCitations = null;

    /**
     * Reference to the sensitive field to citations map, computed from the citations
     * definition file. With <key, value> pair of <citation name, sensitive-field-set name>
     */
    private static HashMap<String, String> sensitiveCitations = null;

    /**
     * Reference to the citations definitions map, computed from the citations
     * definition file. With the <key, value> pair of
     * <citation name, citation display format>. Here the display format with
     * the special element @dc-schema.dc-element.dc-qualifier@, which should be
     * replaced when getCitationString(Item item) is called.
     */
    private static HashMap<String, Vector> citationDefns  = null;


    /**
     * Reference to the citation-sensitive-fields map, computed from the citation defition file
     */
    private static HashMap<String, Vector> sensitiveFieldDefns = null;    // Holds citation sensitive fields definition


    public static void loadConfig(String fileName)
    //     throws ServletException
    {
    	// if citation is loaded, return
    	if((configed == true) && (citationDefns != null)){
    		return;
    	}

    	// if we load the config, we assume the citation is configed
    	// set it up to true
    	configed = true;
        System.out.println("Loading Citation Configuration...");

    	whichCitations = new HashMap();
    	citationDefns  = new HashMap();
    	sensitiveCitations = new HashMap();
    	sensitiveFieldDefns = new HashMap();

    	String uri = "file:" + new File(fileName).getAbsolutePath();

    	try
    	{
        	DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        	factory.setValidating(false);
        	factory.setIgnoringComments(true);
        	factory.setIgnoringElementContentWhitespace(true);

    		DocumentBuilder db = factory.newDocumentBuilder();
    		Document doc = db.parse(uri);
    		doNodes(doc);
    		checkValues();
    	}
    	catch (FactoryConfigurationError fe)
    	{
    		throw new RuntimeException("Cannot load configuration: " + fe);

    	}
    	catch (Exception e)
    	{

    		throw new RuntimeException("Error creating citation: " + e);
    	}
    }

    /**
     * Process the top level child nodes in the passed top-level node. These
     * should correspond to the citation maps, and the citation definitions.
     */
    private static void doNodes(Node n)
		throws SAXException
    {
    	if (n == null)
    	{
    		return;
    	}
    	Node e = getElement(n);
    	NodeList nl = e.getChildNodes();
    	int len = nl.getLength();
    	boolean foundMap  = false;
    	boolean foundDefs = false;
    	for (int i = 0; i < len; i++)
    	{
    		Node nd = nl.item(i);
    		if ((nd == null) || isEmptyTextNode(nd))
    		{
    			continue;
    		}
    		String tagName = nd.getNodeName();
    		if (tagName.equals("citation-map"))
    		{
    			processMap(nd);
    			foundMap = true;
    		}
    		else if (tagName.equals("citation-definitions"))
    		{
    			processDefinition(nd);
    			foundDefs = true;
    		}
    		else if (tagName.equals("citation-sensitive-fields"))
    		{
    			processSensitiveFields(nd);
    		}
    		// Ignore unknown nodes
    	}
    	if (!foundMap)
        {
    		throw new RuntimeException("No citation to document type map found.");
        }
    	if (!foundDefs)
        {
    		throw new RuntimeException("No citation definition found.");
        }
    }


    /**
     * Process the citation-map section of the XML file.
     */
    private static void processMap(Node e)
        throws SAXException
    {
    	NodeList nl = e.getChildNodes();
    	int len = nl.getLength();
    	for (int i = 0; i < len; i++)
    	{
    		Node nd = nl.item(i);
    		if (nd.getNodeName().equals("name-map"))
    		{
                String cid;
                String scope = getAttribute(nd, "scope");
                String c_citationname = getAttribute(nd, "citation-name");
                if(c_citationname != null){
                    cid = getCid(scope, "");
                    whichCitations.put(cid, c_citationname);
                }

                if (scope == null){
                    throw new SAXException("name-map element is missing scope attribute");
                }

                NodeList mnl = nd.getChildNodes();
                int mlen = mnl.getLength();

                for(int j=0; j < mlen; j++){
                    Node mnd = mnl.item(j);
                    if (mnd.getNodeName().equals("map-type")){
                        String dctype = getAttribute(mnd, "document-type");
                        String value = getAttribute(mnd, "citation-name");
                        String content = getValue(mnd);
                        if (dctype == null)
                        {
                            throw new SAXException("name-map element is missing document-type attribute");
                        }
                        if (value == null)
                        {
                            throw new SAXException("name-map element is missing citation-name attribute");
                        }
                        if (content != null && content.length() > 0)
                        {
                            throw new SAXException("name-map element has content, it should be empty.");
                        }

                        if(scope != null){
                            cid = getCid(scope, dctype);
                            whichCitations.put(cid, value);
                        }

                    }
                }

    		}  // ignore any child node that isn't a "name-map"
    	}
    }

    /**
     * getCid - combine the scope handle with the document type
     * @param scope - handle of the scope
     * @param dctype - the document type
     * @return combined string
     */
    public static String getCid(String scope, String dctype){
        return scope + "_" + dctype;
    }

    /**
     * Process the citation-definitions section of the XML file.  Refer citation-config.xml for details
     */
    private static void processDefinition(Node e)
        throws SAXException
    {
    	int numCitations = 0;
    	NodeList nl = e.getChildNodes();
    	int len = nl.getLength();
    	for (int i = 0; i < len; i++) // number of citation definition
    	{
    		Node nd = nl.item(i);
    		// process each citation definition
    		if (nd.getNodeName().equals("citation"))
    		{
    			numCitations++;
    			String citationName = getAttribute(nd, "name");
    			if (citationName == null)
    			{
    				throw new SAXException("citation element has no name attribute");
    			}

    			String sensitiveFieldName = getAttribute(nd, "sensitive-fields-name");
    			if (sensitiveFieldName != null){
    				sensitiveCitations.put(citationName, sensitiveFieldName);
    			}

    			Vector fields = new Vector(); // the citation contains fields
    			citationDefns.put(citationName, fields);
				NodeList flds = nd.getChildNodes();
    			int lenflds = flds.getLength();
    			for (int k = 0; k < lenflds; k++)
    			{
    					Node nfld = flds.item(k);
    					if ( nfld.getNodeName().equals("field") )
    					{
    						// process each field definition
							HashMap field = new HashMap();

                            // Add each field to vector fields
							fields.add(field);
							processFields(citationName, nfld, field);
    					}
    			}
    		}
    	}
    	if (numCitations == 0)
    	{
    		throw new RuntimeException("No citation definition found.");

    	}
    }

    /**
     * Process fields
     * @param citationName name of the citation
     * @param n node for the field
     * @param field the hashmap will hold field info
     * @throws SAXException
     */
    private static void processFields(String citationName, Node n, HashMap field)
           throws SAXException
    {

    	// get all field attribute
    	String required = getAttribute(n, "required");
    	field.put("required", required);

    	String defaultValue = getAttribute(n, "default-value");
    	field.put("default-value", defaultValue);

        String max_n_value = getAttribute(n, "max-n-value");
        field.put("max-n-value", max_n_value);

        String max_n_ending = getAttribute(n, "max-n-ending");
        field.put("max-n-ending", max_n_ending);

        String showIfExist = getAttribute(n, "show-if-exist");
        field.put("show-if-exist", showIfExist);

        String noshowIfExist = getAttribute(n, "noshow-if-exist");
        field.put("noshow-if-exist", noshowIfExist);

        String OP = getAttribute(n, "op");
        field.put("op", OP);

    	NodeList nl = n.getChildNodes();
    	int len = nl.getLength();
    	for (int i = 0; i < len; i++)
    	{
    		Node nd = nl.item(i);
    		if ( ! isEmptyTextNode(nd) )
    		{
    			String tagName = nd.getNodeName();
    			String value   = getValue(nd);
    			field.put(tagName, value);

    			if (tagName.equals("display-format"))
    			{
    				String multipleValueSeperator = getAttribute(nd, "multiple-value-seperator");
    				if(multipleValueSeperator != null){
    					field.put("multiple-value-seperator", multipleValueSeperator);
    				}

                    String formatit = getAttribute(nd, "format-it");
                    if(formatit != null){
                        field.put("format-it", formatit);
                    }
    			}
    		}
    	}
    	String missing = null;

    	if (field.get("display-format") == null)
    	{
    		missing = "display-format";
    	}

    	if ( missing != null )
    	{
    		String msg = "Required field " + missing + " missing in " + citationName;
    		throw new SAXException(msg);
        }

    }

    /**
     * Process the citation-sensitive-field section of the XML file.
     *  Each element is formed thusly:
     *      <field-set name="..." >
     *          <sensitive-field>
     *            <dc-schema>schema</dc-schema>
     *            <dc-element>element</dc-element>
     *            <dc-qualifier>qualifier</dc-qualifier>
     *          </sensitive-field>
     *      </field-set>
     * For each field-set element, create a new vector, and extract all
     * the sensitive-field contained within it. Store the vector
     * in the hashmap.
     */
    private static void processSensitiveFields(Node e)
		throws SAXException
    {
    	NodeList nl_1 = e.getChildNodes();
    	int len_1 = nl_1.getLength();
    	for (int i = 0; i < len_1; i++)
    	{
	    	Node nd_1 = nl_1.item(i);
		    String tagName = nd_1.getNodeName();

			//System.out.print("In processSensitiveFields: " + tagName +"\n");
		    // process each field-set
		    if (tagName.equals("field-set"))
		    {
		    	String setName = getAttribute(nd_1, "name");
		    	if (setName == null)
		    	{
		    		String errString =
		    			"Missing name attribute for field-set in citation-sensitive-fields.";
		    		throw new SAXException(errString);

		    	}
		    	Vector<String> fields = new Vector();
		    	sensitiveFieldDefns.put(setName, fields);
		    	NodeList nl_2 = nd_1.getChildNodes();
		    	int len_2 = nl_2.getLength();
		    	for (int j = 0; j < len_2; j++)
		    	{
		    		Node nd_2 = nl_2.item(j);
		    		String nn_2 = nd_2.getNodeName();
		    		String sfSchema = null;
		    		String sfElement = null;
		    		String sfQualifier = null;
		    		String sfAll = null;

	    			//System.out.print("In processSensitiveFields: " + nn_2 +"\n");
		    		if (nn_2.equals("sensitive-field"))
		    		{
		    			NodeList nl_3 = nd_2.getChildNodes();
		    			int len_3 = nl_3.getLength();
		    			for (int k = 0; k < len_3; k++)
		    			{
		    				Node nd_3 = nl_3.item(k);
		    				String fName = nd_3.getNodeName();
		    				if (fName.equals("dc-schema"))
		    				{
		    					sfSchema = getValue(nd_3);
		    				}
		    				else if (fName.equals("dc-element"))
		    				{
		    					sfElement = getValue(nd_3);
		    				}
		    				else if (fName.equals("dc-qualifier"))
		    				{
		    					sfQualifier = getValue(nd_3);
		    				}
		    			}

			        	String missing = null;
			        	if (sfElement == null)
			        	{
			        		missing = "dc-element";
			        	}

			        	if ( missing != null )
			        	{
			        		String msg = "Required field " + missing + " missing in " + setName;
			        		throw new SAXException(msg);
			            }

			    		if(sfSchema == null){
			    			sfSchema = MetadataSchema.DC_SCHEMA;
			    		}

			    		if(sfQualifier == null){
			    			sfAll = sfSchema + "." + sfElement;
			    		}else{
			    			sfAll = sfSchema + "." + sfElement + "." + sfQualifier;
			    		}
			    		fields.add(sfAll);

		    		}

		    	}
		    }
    	}
    }

    public static Boolean isConfiged()
    {
    	return configed;
    }


    /**
     * Read in the citation definition and return the citation string according to the defined format
     *
     * @param item
     * @return Returns the citation string for the given item.
     */
    public static String getCitationString(Item item){

    	String documentType;
    	String citationName;
    	String citationString = "";
    	List<MetadataValue> dcv = ContentServiceFactory.getInstance().getItemService().getMetadata(item, "dc", "type", null, Item.ANY);
        // now, i try to setup a default citation for records with document type specified
    	if((dcv == null) || dcv.isEmpty()){
			//return "" if there is no document type
            documentType = "";
		}else{
			documentType = dcv.get(0).getValue();
		}

        try{
            // get the owning collection
            Collection col = item.getOwningCollection();
            // no owning collection, return null
            if (col == null) return null;

            // get the cid
            String cid = CitationManager.getCid(col.getHandle(), documentType);
            // no documentType
            String ccid = "";
            if(documentType != ""){

                ccid = CitationManager.getCid(col.getHandle(), "");
            }else{
                ccid = cid;
            }

            // if there is no match up of the cid with the config, try communities
            if (whichCitations.get(cid) == null){

                List<Community> commnities = col.getCommunities();
                for (int n=0; n<commnities.size(); n++){
                    String chandle = commnities.get(n).getHandle();
                    cid = CitationManager.getCid(chandle, documentType);
                    if (whichCitations.get(cid) != null) {
                        break;
                    }else{
                        if(whichCitations.get(ccid) == null){
                            ccid = CitationManager.getCid(chandle, "");
                        }
                    }
                }
            }

            /**
             * check if there is a definition for this document type. If no,
             * use default. If there is no default, return null.
             */

            if(whichCitations.get(cid) == null){
                // then check ccid
                if(whichCitations.get(ccid) == null){
                    // use default
                    if(citationDefns.get("default") != null){
                        citationName = "default";
                    }else{
                        return null;
                    }
                }else{
                    citationName = (String)whichCitations.get(ccid);
                }
            }else{
                citationName = (String)whichCitations.get(cid);
            }

            // Then check if it is sensitive
            if (sensitiveCitations.get(citationName) != null){
                String sensitiveFieldSetName = (String)sensitiveCitations.get(citationName);
                Vector fields = (Vector)sensitiveFieldDefns.get(sensitiveFieldSetName);
                for (int i = 0; i < fields.size(); i++){
                    String field = (String)fields.get(i);
                    //List<Metadatum> values = (item.getMetadata(field));
                    List<MetadataValue> values = ContentServiceFactory.getInstance().getItemService().getMetadataByMetadataString(item, field);
                    //Metadatum[] values = item.getMetadataByMetadataString(field);
                    if ((values == null) || (values.isEmpty())){
                        // if sensitive field is null, return
                        System.out.println("Sensitive to "+field);
                        log.info("Citation " + citationName + " - Sensitive to " + field);
                        return null;
                    }else{
                        //citationString += "not sensitive to field " + field + "; ";
                    }
                }
                //citationString += "sensitive field size is 0; ";
            }else{
                //citationString += "not sensitive ";
            }

            // then let's assembly citation fields
            Vector citation = (Vector)citationDefns.get(citationName);
            for(int j=0; j < citation.size(); j++){
                HashMap field = (HashMap)citation.get(j);
                String dcSchema = (String)field.get("dc-schema");
                String dcElement = (String)field.get("dc-element");
                String dcQualifier = (String)field.get("dc-qualifier");
                String displayFormat = (String)field.get("display-format");


                String noshow_if_exist = (String)field.get("noshow-if-exist");
                String show_if_exist = (String)field.get("show-if-exist");
                String op = (String)field.get("op");

                if((op == null) || (op.length() == 0)){
                    op = "AND";
                }

                boolean showit = true;

                if(noshow_if_exist != null){
                    // check if the noshow_if_exist field is empty
                    String[] nifields = noshow_if_exist.split(";");
                    for(int ni=0; ni<nifields.length; ni++){
                        List<MetadataValue> sen = ContentServiceFactory.getInstance().getItemService().getMetadataByMetadataString(item, nifields[ni].trim());
                        if((sen != null) && (sen.size() != 0)){
                            if(op.equalsIgnoreCase("OR")){
                                // at lease one exists, get out
                                showit = false;
                                break;
                            }else{
                                if(ni == nifields.length-1){
                                    showit= false;
                                    break;
                                }
                            }
                        }else if(op.equalsIgnoreCase("AND")){
                            break;
                        }
                    }
                }else if(show_if_exist != null){
                    // check if the show_if_exist field is empty
                    showit = false;
                    String[] nifields = show_if_exist.split(";");
                    for(int ni=0; ni<nifields.length; ni++){
                        List<MetadataValue> sen = ContentServiceFactory.getInstance().getItemService().getMetadataByMetadataString(item, nifields[ni].trim());
                        if((sen != null) && (sen.size() != 0)){
                            if(op.equalsIgnoreCase("OR")){
                                // at lease one exists, get out
                                showit = true;
                                break;
                            }else{
                                if(ni == nifields.length-1){
                                    showit= true;
                                    break;
                                }
                            }
                        }else if(op.equalsIgnoreCase("AND")){
                            break;
                        }
                    }
                }


                if(showit){
                    if((displayFormat.indexOf("@field@") == -1)
                        && (((dcSchema==null) || ("".equals(dcSchema))))
                        && ((dcElement==null) || ("".equals(dcElement)))
                        && ((dcQualifier==null) || ("".equals(dcQualifier)))){
                        // if there is no @field@ in displayFormat,
                        // and dcSchema, dcElement, and dcQualifier are all empty,
                        // we'll display it as it is
                        citationString += displayFormat;
                    }else{

						// Check here, maybe values from ContentServiceFactory should be copied to a local var so it won't change the actual value
                        List<MetadataValue> values;
						List<String> locvalues = new ArrayList<String>();
                        if ("".equals(dcQualifier))
                        {
                            values = ContentServiceFactory.getInstance().getItemService().getMetadata(item, dcSchema, dcElement, null, Item.ANY);
                        }
                        else
                        {
                            values = ContentServiceFactory.getInstance().getItemService().getMetadata(item, dcSchema,  dcElement, dcQualifier, Item.ANY);
                        }


                        String fieldValue = "";
                        if((values != null) && (values.size() != 0)){

                        	// First, copy values to locvalues so it won't change the original
							for(int i=0; i<values.size(); i++){
								locvalues.add(i, values.get(i).getValue());
							}
                            String formatit = (String)field.get("format-it");

                            if(values.size() > 1){ // with multiple values
                                // get the max-n-value
                                String max_n_value = (String)field.get("max-n-value");
                                // get the max-n-ending, only use it when lengh of value is greater than max-n-value
                                String max_n_ending = (String)field.get("max-n-ending");

                                int nvalue = locvalues.size();
                                if(max_n_value != null){
                                    nvalue = Integer.valueOf(max_n_value).intValue();
                                    if(nvalue >= locvalues.size()){
                                        nvalue = locvalues.size();
                                    }else{
                                        if(max_n_ending != null){
                                            //displayFormat +=  " " + max_n_ending.trim();
											locvalues.set(nvalue,max_n_ending.trim());
                                            nvalue++;

                                        }
                                    }
                                }

                                // get the seperator
                                String seperator = (String)field.get("multiple-value-seperator");
                                if (seperator == null){
                                    seperator = DEFAULT_SEPERATOR;
                                    }

                                for (int k=0; k < nvalue; k++){

                                   if(formatit!= null){
                                       fieldValue += FormatIt.formatIt(formatit, locvalues.get(k));
                                   }else{
                                       fieldValue += locvalues.get(k);
                                   }
                                   if (k == (nvalue - 2) && !locvalues.get(nvalue-1).equals("et al.")){
                                        fieldValue += " and ";
                                   }else if (k < (nvalue - 1)){
                                        fieldValue += seperator + " ";
                                   }
                                }

                            }else{
                                    if(formatit!= null){
                                        fieldValue = FormatIt.formatIt(formatit, locvalues.get(0));

                                    }else{

                                        fieldValue = locvalues.get(0);
                                    }
                                }
                            }

                            // replace the @field@ if fieldvalue is not empty
                            if(fieldValue != ""){
                                citationString += displayFormat.replace("@field@", fieldValue);
                            }
                        }
                    }
                }
            }catch (java.sql.SQLException e){

        }

        return citationString;
    }

    /**
     * Check that all referenced citation-sensitive-fields are present
     * and field is consistent
     *
     * Throws ServletException if detects a missing sensitive-field.
     */

    private static void checkValues()
		//throws ServletException
    {
    	// Step through each citation definitions
    	Iterator ki = sensitiveCitations.keySet().iterator();
    	while (ki.hasNext())
    	{
    		String citationName = (String)ki.next();
   			String sensitiveFieldSetName = (String)sensitiveCitations.get(citationName);

    		if((Vector)sensitiveFieldDefns.get(sensitiveFieldSetName) == null){
				String errString = "Cannot find sensitive field set definition for " + sensitiveFieldSetName;
				throw new RuntimeException(errString);
    		}
    	}
    }


    private static Node getElement(Node nd)
    {
        NodeList nl = nd.getChildNodes();
        int len = nl.getLength();
        for (int i = 0; i < len; i++)
        {
    	    Node n = nl.item(i);
    	    if (n.getNodeType() == Node.ELEMENT_NODE)
    	    {
    	    	return n;
            }
        }
        return null;
     }

    private static boolean isEmptyTextNode(Node nd)
    {
    	boolean isEmpty = false;
    	if (nd.getNodeType() == Node.TEXT_NODE)
    	{
    		String text = nd.getNodeValue().trim();
    		if (text.length() == 0)
    		{
    			isEmpty = true;
    		}
    	}
    	return isEmpty;
    }

    /**
     * Returns the value of the node's attribute named <name>
     */
    private static String getAttribute(Node e, String name)
    {
    	NamedNodeMap attrs = e.getAttributes();
    	int len = attrs.getLength();
    	if (len > 0)
    	{
    		int i;
    		for (i = 0; i < len; i++)
    		{
    			Node attr = attrs.item(i);
    			if (name.equals(attr.getNodeName()))
    			{
    				return attr.getNodeValue().trim();
    			}
    		}
    	}
    	//no such attribute
    	return null;
    }

    /**
     * Returns the value found in the Text node (if any) in the
     * node list that's passed in.
     */
    private static String getValue(Node nd)
    {

    	String tagName = nd.getNodeName();

    	NodeList nl = nd.getChildNodes();
    	int len = nl.getLength();
    	for (int i = 0; i < len; i++)
    	{
    		Node n = nl.item(i);
    		short type = n.getNodeType();
    		if (type == Node.TEXT_NODE)
    		{
    	    	if (tagName.equals("display-format")){
    	    		return n.getNodeValue();
    	    	}else{
    	    		return n.getNodeValue().trim();
    			}
    		}
    	}
    	// Didn't find a text node
    	return null;
    }

    /**
     * this main is too old.
     * @param args
     */
    public static void main(String [ ] args){

    	try{
	    	System.out.println("Citation configuration!\n");

	    	// create a context
	        Context c = new Context();

	        // find the EPerson, assign to context
            EPersonService epersonService = EPersonServiceFactory.getInstance().getEPersonService();
	        EPerson myEPerson = epersonService.findByEmail(c, "email here");;
	       
	        c.setCurrentUser(myEPerson);

	        Item item = null;
	        int itemid;
	        if(args.length != 0){
	        	itemid = Integer.parseInt(args[0]);
	        }else{
	        	itemid = 6;
	        }
/**
	    	item = Item.find(c, itemid);
	        if(item != null){
		    	CitationManager.loadConfig("citation location here");
		    	if(CitationManager.configed){
		    		String citation = CitationManager.getCitationString(item);
		    		if(citation != null){
		    			System.out.println(citation);
		    		}else{
		    			System.out.println("No citation for the item with id " + itemid);
		    		}

		    	}else{
		    		System.out.println("Not configed :(.");
		    	}
	        }else{
	    		System.out.println("Can't find specified item with id " + itemid);
	        }
 */
    	}catch(java.sql.SQLException e){
    		e.printStackTrace();
    	}
    }
}