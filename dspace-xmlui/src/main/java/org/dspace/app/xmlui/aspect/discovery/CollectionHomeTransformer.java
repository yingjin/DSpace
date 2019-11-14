/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.xmlui.aspect.discovery;

import org.dspace.app.xmlui.utils.HandleUtil;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.Body;
import org.dspace.app.xmlui.wing.element.Division;
import org.dspace.app.xmlui.wing.element.ReferenceSet;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Collection;
import org.dspace.content.DSpaceObject;
import org.xml.sax.SAXException;

import org.apache.cocoon.caching.CacheableProcessingComponent;
import org.apache.cocoon.util.HashUtil;
import org.apache.excalibur.source.SourceValidity;
import org.apache.log4j.Logger;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.utils.DSpaceValidity;
import org.dspace.core.Constants;
import org.dspace.discovery.*;
import org.dspace.discovery.configuration.DiscoveryConfiguration;
import org.dspace.core.Context;

import java.io.Serializable;
import java.sql.SQLException;
import java.io.IOException;
import java.util.List;

import org.dspace.discovery.configuration.DiscoveryCollectionHomeConfiguration;


/**
 * A class for collection home items transformer
 *
 *  @author Ying Jin (ying.jin at rice dot edu)
 */
public class CollectionHomeTransformer extends AbstractDSpaceTransformer implements CacheableProcessingComponent {

    private static final Logger log = Logger.getLogger(CollectionHomeTransformer.class);

    /**
     * Cached query results
     */
    protected DiscoverResult queryResults;

    /** Cached validity object */
    private SourceValidity validity;

    /**
     * Generate the unique caching key.
     * This key must be unique inside the space of this component.
     */
    @Override
    public Serializable getKey() {
        try
        {
            DSpaceObject dso = HandleUtil.obtainHandle(objectModel);

            if (dso == null)
            {
                return "0";
            }

            return HashUtil.hash(dso.getHandle());
        }
        catch (SQLException sqle)
        {
            // Ignore all errors and just return that the component is not
            // cachable.
            return "0";
        }
    }

    /**
     * Generate the cache validity object.
     *
     * The validity object all recently submitted items.
     * This does not include the community / collection
     * hierarchy, when this changes they will not be reflected in the cache.
     */
    public SourceValidity getValidity()
    {
    	if (this.validity == null)
    	{
            Collection collection = null;
            try
	        {
                Context.Mode originalMode = context.getCurrentMode();
                context.setMode(Context.Mode.READ_ONLY);

                DSpaceObject dso = HandleUtil.obtainHandle(objectModel);

                if (dso == null)
                {
                    return null;
                }

                if (!(dso instanceof Collection))
                {
                    return null;
                }

                collection = (Collection) dso;

                DSpaceValidity validity = new DSpaceValidity();

                // Add the actual collection;
                validity.add(context, collection);

                this.validity = validity.complete();

                context.setMode(originalMode);
            }
            catch (Exception e)
            {
                // Just ignore all errors and return an invalid cache.
            }

        }
        return this.validity;
    }

    /**
     * Retrieves the recent submitted items of the given scope
     *
     * @param dso the DSpace object can either be null (indicating home page), a collection or a community
     */
    protected void getHomeItems(DSpaceObject dso) {


          if(queryResults != null)
        {
            return; // queryResults;
        }

        try {
            DiscoverQuery queryArgs = new DiscoverQuery();

            //Add the default filter queries
            DiscoveryConfiguration discoveryConfiguration = SearchUtils.getDiscoveryConfiguration(dso);
            List<String> defaultFilterQueries = discoveryConfiguration.getDefaultFilterQueries();
            queryArgs.addFilterQueries(defaultFilterQueries.toArray(new String[defaultFilterQueries.size()]));
            queryArgs.setDSpaceObjectFilter(Constants.ITEM);

            DiscoveryCollectionHomeConfiguration homeConfiguration = discoveryConfiguration.getCollectionHomeConfiguration();
            if(homeConfiguration != null){
                queryArgs.setMaxResults(homeConfiguration.getPerpage());
                String sortField = SearchUtils.getSearchService().toSortFieldIndex(homeConfiguration.getMetadataSortField(), homeConfiguration.getType());
                if(sortField != null){
                    queryArgs.setSortField(
                            sortField,
                            DiscoverQuery.SORT_ORDER.desc
                    );
                }
                SearchService service = SearchUtils.getSearchService();
                queryResults = service.search(context, dso, queryArgs);
            }else{
                //No configuration, no results
                queryResults = null;
            }
        }catch (SearchServiceException se){
            log.error("Caught SearchServiceException while retrieving recent submission for: " + (dso == null ? "home page" : dso.getHandle()), se);
        }
    }

    @Override
    public void recycle() {
        queryResults = null;
        validity = null;
        super.recycle();
    }

       /**
     * Displays the home items for this collection
     */
    public void addBody(Body body) throws SAXException, WingException,
            SQLException, IOException, AuthorizeException {

       DSpaceObject dso = HandleUtil.obtainHandle(objectModel);
        // Set up the major variables
        Collection collection = (Collection) dso;
        if(!(dso instanceof Collection))
        {
            return;
        }


         getHomeItems(collection);

        //Only attempt to render our result if we have one.
        if(queryResults == null)
        {
            return;
        }

        if(0 < queryResults.getDspaceObjects().size()){
            // Build the collection viewer division.
            Division home = body.addDivision("collection-home", "primary repository collection");

            Division homeItemDiv = home
                    .addDivision("collection-home-item", "secondary home-item");

            ReferenceSet homeItem = homeItemDiv.addReferenceSet(
                    "collection-last-submitted", ReferenceSet.TYPE_SUMMARY_LIST,
                    null, "recent-submissions");

            for (DSpaceObject resultObj : queryResults.getDspaceObjects()) {
                if(resultObj != null){
                    homeItem.addReference(resultObj);
                }
            }
        }

    }


    }

