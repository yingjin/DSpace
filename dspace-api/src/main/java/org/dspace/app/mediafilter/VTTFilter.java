/*
 * JPEGFilter.java
 *
 * Version: $Revision: 1269 $
 *
 * Date: $Date: 2005-07-29 10:56:10 -0500 (Fri, 29 Jul 2005) $
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
/*
 * Copyright (c) 2008  Los Alamos National Security, LLC.
 *
 * Los Alamos National Laboratory
 * Research Library
 * Digital Library Research & Prototyping Team
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 *
 */

/**
 * Ying Jin, 2009-07-27
 * generating the symbolic links for all video and audio files that we would like to stream to another location
 */
package org.dspace.app.mediafilter;


import java.io.*;
import java.util.HashMap;
import org.dspace.core.ConfigurationManager;
import org.dspace.content.Bitstream;

import org.dspace.content.Item;

/**
 * generate symbolic links for the files given
 */
public class VTTFilter extends MediaFilter
{
    /*
    private HashMap extensionHash = new HashMap<String, String>()
    {
        {
            put("audio/x-mp3", ".mp3");
            put("video/quicktime", ".mov");
            put("audio/x-wav", ".wav");
        }

    };*/

    @Override
    public String getFilteredName(String oldFilename)
    {
        return oldFilename + ".jpg";
    }

    /**
     * @return String bundle name
     *
     */
    @Override
    public String getBundleName()
    {
        return "THUMBNAIL";
    }

    /**
     * @return String bitstreamformat
     */
    @Override
    public String getFormatString()
    {
        return "JPEG";
    }

    /**
     * @return String description
     */
    @Override
    public String getDescription()
    {
        return "Generated Thumbnail";
    }

    /**
     * @param source
     *            source input stream
     *
     * @return InputStream the resulting input stream
     */
    @Override
    public InputStream getDestinationStream(Item currentItem, InputStream source, boolean verbose){
        return null;
    }

    @Override
    public InputStream getDestinationStream(Bitstream source)
        throws Exception
    {

        // get the location of symbolic link. 
        String streaming_dir = ConfigurationManager.getProperty("streaming.dir");
        //String dspacebase_dir = ConfigurationManager.getProperty("dspacebase.dir");

        // //String ID = source.getID().toString();

        // special case here that I have to assume the assetstore dir is ending with "assetstore"
        String filename = source.getName();
        String filepath = source.getFilepath();
        System.out.println("filename ------ " + filename + ", filepath: " + filepath);
        String softpath_to_avfile = "../assetstore/" + filepath;

        //String softpath_to_avfile = "../" + filepath.substring(filepath.indexOf("assetstore"));
        //String absolute_path_to_avfile = ConfigurationManager.getProperty("assetstore.dir");
        //System.out.println("softpath ------ " + softpath_to_avfile);
        //System.out.println("streaming_dir ------ " + streaming_dir);

        // get relative path to the assetstore files

        // get the file extension
        // String extension = (String)extensionHash.get(mimetype);


        String streaming_name = filename;
        //String softpath_to_avfile =
        String cmd = "ln -sf " + softpath_to_avfile + " " + streaming_dir + "/" + streaming_name;

        //String cmd = "ln -sf " + filename + " " + streaming_dir + "/" + streaming_name;
        System.out.println("~~~~~~~~~~~~~~~  ~~ ~~ ~~ ~~ In VTTFilter: cmd = " + cmd);
        // call to generate the symbolic link
        Runtime.getRuntime().exec(cmd);
        return null;
    }

}
