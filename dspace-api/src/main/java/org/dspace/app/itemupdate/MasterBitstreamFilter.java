/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.itemupdate;

import java.sql.SQLException;
import java.util.List;

import org.dspace.content.Bitstream;
import org.dspace.content.Bundle;

/** 
 * 		Filter all bitstreams in the MASTER bundle
 *
 */
public class MasterBitstreamFilter extends BitstreamFilterByBundleName
{	
	public MasterBitstreamFilter()
	{
		//empty
	}
	
	/**
	 *   Tests bitstreams for containment in an MASTER bundle
	 *  @param bitstream Bitstream
	 *  @return true if the bitstream is in the MASTER bundle
	 *  
	 *  @throws BitstreamFilterException if filter error
	 */
	@Override
    public boolean accept(Bitstream bitstream)
	throws BitstreamFilterException
	{		
		try
		{
			List<Bundle> bundles = bitstream.getBundles();
			for (Bundle bundle : bundles)
			{
                if (bundle.getName().equals("MASTER"))
				{
					return true;
				}
			}		
		}
		catch(SQLException e)
		{
			throw new BitstreamFilterException(e);
		}
		return false;
	}

}
