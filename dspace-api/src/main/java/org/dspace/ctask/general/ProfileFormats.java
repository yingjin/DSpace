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

import org.dspace.content.*;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.BitstreamFormatService;
import org.dspace.curate.AbstractCurationTask;
import org.dspace.curate.Curator;
import org.dspace.curate.Distributive;

/**
 * ProfileFormats is a task that creates a distribution table of Bitstream 
 * formats for it's passed object. Primarily a curation task demonstrator.
 *
 * @author richardrodgers
 */
@Distributive
public class ProfileFormats extends AbstractCurationTask
{
    // map of formats to occurrences
    protected Map<String, Integer> fmtTable = new HashMap<String, Integer>();
    protected BitstreamFormatService bitstreamFormatService = ContentServiceFactory.getInstance().getBitstreamFormatService();
    // map of formats to size
    private Map<String, Long> sizeTable = new HashMap<String, Long>();      // Ying added this for total size


    /**
     * Perform the curation task upon passed DSO
     *
     * @param dso the DSpace object
     * @throws IOException if IO error
     */
    @Override
    public int perform(DSpaceObject dso) throws IOException
    {
        fmtTable.clear();
        distribute(dso);
        formatResults();
        return Curator.CURATE_SUCCESS;
    }
    
    @Override
    protected void performItem(Item item) throws SQLException, IOException
    {
        for (Bundle bundle : item.getBundles())
        {
            for (Bitstream bs : bundle.getBitstreams())
            {
                long size = bs.getSize();      // Ying added this for total size
                String fmt = bs.getFormat(Curator.curationContext()).getShortDescription();
                Integer count = fmtTable.get(fmt);
                Long totalsize = sizeTable.get(fmt); // Ying added this for total size
                if (count == null)
                {
                    count = 1;
                    totalsize = bs.getSize();  // Ying added this for total size
                }
                else
                {
                    count += 1;
                    totalsize += bs.getSize();  // Ying added this for total size
                }
                fmtTable.put(fmt, count);
                sizeTable.put(fmt, totalsize);  // Ying added this for total size
            }
        }
    }
    
    private void formatResults() throws IOException
    {
        try
        {
            StringBuilder sb = new StringBuilder();
            for (String fmt : fmtTable.keySet())
            {
                String sizeIn = bytesTo(sizeTable.get(fmt)); // Ying added this for total size

                BitstreamFormat bsf = bitstreamFormatService.findByShortDescription(Curator.curationContext(), fmt);
                sb.append(String.format("%6d", fmtTable.get(fmt))).append(" (").
                append(bitstreamFormatService.getSupportLevelText(bsf).charAt(0)).append(")").
                append(bsf.getDescription()).append("\t; Total Size: ").
                append(String.format("%s\n | ", sizeIn)); // Ying added this total size
            }
            report(sb.toString());
            setResult(sb.toString());
        }
        catch (SQLException sqlE)
        {
            throw new IOException(sqlE.getMessage(), sqlE);
        }
    }

     // Ying added this for size information
 private static final long  MEGABYTE = 1024L * 1024L;
 private static final long  KILOBYTE = 1024L;

 private static String bytesTo(long bytes) {
     long size = bytes / MEGABYTE ;
     if (size == 0){
        size = bytes / KILOBYTE ;
        return size + "KB" ;

     }else{
         return size + "MB" ;
     }
   }

}
