/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.ctask.general;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import org.dspace.content.Bitstream;
import org.dspace.content.Bundle;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.core.Context;

import org.dspace.curate.AbstractCurationTask;
import org.dspace.curate.Curator;
import org.dspace.curate.Distributive;

/**
 * FileCount is to give the report of PERMIT counts for each item in a collection/community
 *
 * @author Ying Jin
 */
@Distributive
public class PermitCounts extends AbstractCurationTask
{
    // map of handle license
    private Map<String, Integer>permitTable = new HashMap<String, Integer>();

    /**
     * Perform the curation task upon passed DSO
     *
     * @param dso the DSpace object
     * @throws IOException
     */
    @Override
    public int perform(DSpaceObject dso) throws IOException
    {
        permitTable.clear();
        distribute(dso);
        formatResults();
        return Curator.CURATE_SUCCESS;
    }
    
    @Override
    protected void performItem(Item item) throws SQLException, IOException
    {
        for (Bundle bundle : item.getBundles())
        {
            if (bundle.getName().equalsIgnoreCase("PERMIT")){
                String handle = item.getHandle();
                for (Bitstream bs : bundle.getBitstreams())
                {

                    Integer count = permitTable.get(handle);
                    if (count == null)
                    {
                        count = 1;
                    }
                    else
                    {
                        count += 1;
                    }
                    permitTable.put(handle, count);
                }
            }
        }
    }
    
    private void formatResults() throws IOException
    {
        //try
        //{
            Context c = new Context();
            StringBuilder sb = new StringBuilder();
	    sb.append("PERMIT Count - \n | ");
            for (String handle : permitTable.keySet())
            {
                sb.append(String.format("%s", handle)).
                        append(String.format("%6d\n | ", permitTable.get(handle)));
            }
            report(sb.toString());
            setResult(sb.toString());
            //c.complete();
            //}
            //catch (SQLException sqlE)
            //{
            //    throw new IOException(sqlE.getMessage(), sqlE);
            //}
    }
}

