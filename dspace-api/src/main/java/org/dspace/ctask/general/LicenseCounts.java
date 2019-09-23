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
 * FileCount is to give the report of License counts for each item in a collection/community
 *
 * @author Ying Jin
 */
@Distributive
public class LicenseCounts extends AbstractCurationTask
{
    // map of handle license
    private Map<String, Integer>licenseTable = new HashMap<String, Integer>();

    // map of handle cc license
    private Map<String, Integer> cclicenseTable = new HashMap<String, Integer>();
    /**
     * Perform the curation task upon passed DSO
     *
     * @param dso the DSpace object
     * @throws IOException
     */
    @Override
    public int perform(DSpaceObject dso) throws IOException
    {
        licenseTable.clear();
        cclicenseTable.clear();
        distribute(dso);
        formatResults();
        return Curator.CURATE_SUCCESS;
    }
    
    @Override
    protected void performItem(Item item) throws SQLException, IOException
    {
        for (Bundle bundle : item.getBundles())
        {
            if (bundle.getName().equalsIgnoreCase("LICENSE")){
                String handle = item.getHandle();
                for (Bitstream bs : bundle.getBitstreams())
                {

                    Integer count = licenseTable.get(handle);
                    if (count == null)
                    {
                        count = 1;
                    }
                    else
                    {
                        count += 1;
                    }
                    licenseTable.put(handle, count);
                }
            }
	        else if (bundle.getName().equalsIgnoreCase("CC-LICENSE")) {
                    String handle = item.getHandle();
                    for (Bitstream bs : bundle.getBitstreams())
                    {

                        Integer count = cclicenseTable.get(handle);
                        if (count == null)
                        {
                            count = 1;
                        }
                        else
                        {
                            count += 1;
                        }
                        cclicenseTable.put(handle, count);
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
	    sb.append("LICENSE Count - \n | ");
            for (String handle : licenseTable.keySet())
            {
                sb.append(String.format("%s", handle)).
                        append(String.format("%6d\n | ", licenseTable.get(handle)));
            }

	    sb.append("\n\nCC-LICENSE Count - \n | ");
            for (String handle : cclicenseTable.keySet())
            {
                sb.append(String.format("%s", handle)).
                        append(String.format("%6d\n | ", cclicenseTable.get(handle)));
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

