package org.dspace.presentation.xsl;

import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.lang.String;

import org.apache.log4j.Logger;
import org.dspace.core.ConfigurationManager;
import org.jdom.transform.XSLTransformException;

public class XMLTransformManager
{
    /** log4j category */
    private static Logger log = Logger.getLogger(XMLTransformManager.class);

    /** text strings identifying configuration file lines */
    private final static String prefix = "xslview.";
    private final static String filenameSuffix = ".stylesheet";
    private final static String dependsSuffix = ".depends";
    private final static String descriptionSuffix = ".description";
    private final static String paramsSuffix = ".params";
    private final static String schemaSuffix = ".schemastransformed";
    private final static String cacheSuffix = ".cache";
    private final static String transformLinksSuffix = ".transformlinks";
    private final static String reloadXSLSuffix = ".reloadxsl";


    /** list of all stylesheet names found in the configuration file */
    private static List<String> stylesheetNames = null;
    /**
     * Search the configuration file for the names of all stylesheets
     * @return a List of found stylesheet names
     */
    private static List<String> getStylesheetNames()
    {
        if (stylesheetNames == null) {

            log.debug("XMLTransform: looking for XSL stylesheets in config");

            stylesheetNames = new ArrayList<String>(3);
            Enumeration properties = ConfigurationManager.propertyNames();
            while (properties.hasMoreElements())
            {
                String key = (String)properties.nextElement();
                if (key.startsWith(prefix) && key.endsWith(filenameSuffix))
                {
                    log.debug("XMLTransform: Getting Stylesheet name from config line: "+key);
                    String stylesheetName = key.substring(prefix.length(), key.length()-filenameSuffix.length());
                    stylesheetNames.add(stylesheetName);
                }
            }
        }

        return stylesheetNames;
    }

    /** list of all XMLTransforms, one for each stylesheet configured in the config file */
    private static Map<String, XMLTransform> transformers = null;
    /**
     * Returns all XMLTransforms, set up as detailed in the config file
     * @return a Map with the XMLTransforms as values under their configuration names as keys
     */
    public static Map<String,XMLTransform> getTransformers()
    {
        if (transformers == null)
        {
            // Set up each stylesheet mentioned in the config file
            transformers = new HashMap<String, XMLTransform>(3);
            for (String stylesheet : getStylesheetNames())
            {
                // get each config option for this stylesheet
                String stylesheetFile = ConfigurationManager.getProperty(prefix+stylesheet+filenameSuffix);
                String description = ConfigurationManager.getProperty(prefix+stylesheet+descriptionSuffix);
                String depends = ConfigurationManager.getProperty(prefix+stylesheet+dependsSuffix);
                String params = ConfigurationManager.getProperty(prefix+stylesheet+paramsSuffix);
                String schemas = ConfigurationManager.getProperty(prefix+stylesheet+schemaSuffix);
                String cacheStr = ConfigurationManager.getProperty(prefix+stylesheet+cacheSuffix);
                String transformLinks = ConfigurationManager.getProperty(prefix+stylesheet+transformLinksSuffix);
                String reloadXSLStr = ConfigurationManager.getProperty(prefix+stylesheet+reloadXSLSuffix);
                if (stylesheetFile == null || description == null || schemas == null)
                {
                    // Note: Only these three options are required. The others are optional.
                    log.error("XMLTransform: Incomplete configuration for stylesheet "+stylesheet);
                }
                else
                {
                    // parse the params line into a list of params
                    Map<String, String> paramsMap = new HashMap<String, String>(2);
                    if (params != null)
                    {
                        for (String paramTemp : Arrays.asList(params.split(";")))
                        {
                            String[] paramTempSplit = paramTemp.split(":");
                            if (paramTempSplit.length == 2)
                            {
                                paramsMap.put(paramTempSplit[0], paramTempSplit[1]);
                            }
                        }
                    }

                    // parse the depends line into a list of filenames
                    List<File> dependsList = new ArrayList<File>();
                    if (depends != null)
                    {
                        for (String dependName : Arrays.asList(depends.split(";")))
                        {
                            // check each entry on the depends line, keeping in mind that each
                            //  entry may contain a wildcard char.
                            String dirname = "", filename = "";
                            int lastSlash = dependName.lastIndexOf('/');
                            if (lastSlash != -1)
                            {
                                dirname = dependName.substring(0, lastSlash);
                                filename = dependName.substring(lastSlash+1);
                            }

                            // wildcard in filename - expand into a list of real filenames
                            int starIndex = filename.indexOf('*');
                            if (starIndex != -1)
                            {
                                File directory = new File(dirname);
                                if (directory.isDirectory())
                                {
                                    // get chars before and after the '*'
                                    final String prefix = filename.substring(0, starIndex);
                                    final String suffix = (starIndex == filename.length())? ""
                                            : filename.substring(starIndex+1, filename.length());
                                    // find all files in the dir that have the prefix and suffix
                                    File[] files = directory.listFiles(new FilenameFilter() {
                                        public boolean accept(File dir, String name)
                                        {
                                            return name.startsWith(prefix) && name.endsWith(suffix);
                                        }
                                    });
                                    // add found files to the list
                                    dependsList.addAll(Arrays.asList(files));
                                }
                            }

                            // no wildcards - just add the one file
                            else
                            {
                                File dependFile = new File(dependName);
                                if (dependFile.canRead())
                                {
                                    dependsList.add(dependFile);
                                }
                            }
                        }
                    }

                    //parse the schemas line into a list of schemas
                    List<String>schemasList = new ArrayList<String>(2);
                    for (String schema : Arrays.asList(schemas.split(";")))
                    {
                        schemasList.add(schema);
                    }

                    // check whether to allow caching
                    boolean cache = false;
                    if (cacheStr != null)
                    {
                        if (cacheStr.equals("true") && paramsMap.size() == 0)
                        {
                            cache = true;
                        }
                    }

                    // check whether to transform links
                    boolean transformThumbnails = transformLinks != null
                        && transformLinks.contains("thumbnail");
                    boolean transformBitstreamLinks = transformLinks != null
                        && transformLinks.contains("bitstream");

                    // check whether to reload xsl when the files are updated
                    boolean reloadXSL = (reloadXSLStr != null
                        && reloadXSLStr.contains("true"));

                    // create the XMLTransform
                    try
                    {
                        XMLTransform newTransform;
                        if (!cache)
                        {
                            newTransform = new XMLTransform(stylesheet, stylesheetFile, dependsList,
                                    description, paramsMap, schemasList, transformBitstreamLinks,
                                    transformThumbnails, reloadXSL);
                        }
                        else
                        {
                            newTransform = new CachedXMLTransform(stylesheet, stylesheetFile, dependsList,
                                    description, paramsMap, schemasList, transformBitstreamLinks,
                                    transformThumbnails, reloadXSL);
                        }
                        transformers.put(stylesheet, newTransform);
                    }
                    catch (XSLTransformException e)
                    {
                        log.error(e.getMessage());
                    }

                }
            }
        }
        return transformers;
    }

    /**
     * Returns the transformer of the given name, if configured.
     * @return the named XMLTransform, or null if it isn't there
     */
    public static XMLTransform getTransform(String name)
    {
        Map<String, XMLTransform> map = getTransformers();
        return map.get(name);
    }

    /**
     * Returns all configured XMLTransforms for a given schema
     * @param schema the type of XML the XMLTransformers accept
     * @return all the XMLTransformers for the schema
     */
    public static List<XMLTransform> getTransformsForSchema(String schema)
    {
        List<XMLTransform> list = new ArrayList<XMLTransform>();

        for (XMLTransform transform : getTransformers().values())
        {
            if (transform.isValidForSchema(schema))
            {
                list.add(transform);
            }
        }

        return list;
    }

}
