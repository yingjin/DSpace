/*
 * FormatIt.java
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

import java.util.regex.Pattern;
import java.util.regex.Matcher;

import org.apache.log4j.Logger;


/**
 * Format the given field for the citation generation
 *
 * @author  Ying Jin
 * @version $Revision: ? $
 */

public class FormatIt
{
    /** log4j logger */
    private static Logger log = Logger.getLogger(FormatIt.class);

    private static Pattern authorPattern1 = Pattern.compile(", \\d\\d\\d\\d");
    private static Pattern authorPattern2 = Pattern.compile("\\(\\d\\d\\d\\d");
    private static Pattern wrcPattern1 = Pattern.compile("Woodson Research Center");
    private static Pattern wrcPattern2 = Pattern.compile("MS \\d");


    /**
     * All format-it handled here
     *
     * @param formatit format-it setup
     * @param value
     * @return formatted value
     */
    public static String formatIt(String formatit, String value){
        if(formatit.equalsIgnoreCase("firstname-initial-only")){
            return getFirstNameInitials(value);
        }else if(formatit.equalsIgnoreCase("year-only")){
            return getYearOnly(value);
        }else if(formatit.equalsIgnoreCase("thresher-date")){
            return getThresherDate(value);
        }else if(formatit.equalsIgnoreCase("americas-author")){
            return getAmericasAuthor(value);
        }else if(formatit.equalsIgnoreCase("americas-ms-source")){
            return getAmericasMSSource(value);
        }else if(formatit.equalsIgnoreCase("ece-conferencedate")){
            return getECEConferenceDate(value);
        }else if(formatit.equalsIgnoreCase("get-wrc")){
            return getWRC(value);
        }else if(formatit.equalsIgnoreCase("thesis-diss")){
            return getThesisDiss(value);
        }else{
            // do nothing
            return value;
        }

    }


    /**
     * Get the date in format of e.g. October 19, 2008
     *
     * @param date the date in YYYY-MM-DD format
     * @return formatted value
     */
    private static String getThresherDate(String date){


        if(date.length() <=4) return date;

        StringBuffer dateBuffer = new StringBuffer();
        String[] dateValue = date.split("-");
        String[] toMonth = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
        String year = "";
        String mon = "";
        String day = "";

        for(int i=0; i<dateValue.length; i++){
            if(i==0)
                year = dateValue[i];
            if(i==1)
                mon = toMonth[Integer.valueOf(dateValue[i]).intValue()-1];
            if(i==2)
                day = dateValue[i];
        }
        if((mon !=null) && (mon != "")) dateBuffer.append(mon);
        if((day !=null) && (day != "")) dateBuffer.append(" " + day);
        if((year != null) && (year != "")) {
            dateBuffer.append(", ");
            dateBuffer.append(year);
        }
        return dateBuffer.toString();
    }

    /**
     * Get the date in format of e.g. Oct. 2008
     *
     * @param date the date in YYYY-MM-DD format
     * @return formatted value
     */
    private static String getECEConferenceDate(String date){


        if(date.length() <=4) return date;

        StringBuffer dateBuffer = new StringBuffer();
        String[] dateValue = date.split("-");
        String[] toMonth = {"Jan.", "Feb.", "Mar.", "Apr.", "May", "Jun.", "Jul.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec."};
        String year = "";
        String mon = "";

        for(int i=0; i<dateValue.length; i++){
            if(i==0)
                year = dateValue[i];
            if(i==1)
                mon = toMonth[Integer.valueOf(dateValue[i]).intValue()-1];
        }
        if((mon !=null) && (mon != "")) dateBuffer.append(mon);
        if((year != null) && (year != "")) {
            dateBuffer.append(" ");
            dateBuffer.append(year);
        }
        return dateBuffer.toString();
    }

    /**
     * Get year only from date in YYYY-MM-DD format
     *
     * @param year
     * @return formatted value
     */
    private static String getYearOnly(String year){
        if(year.length() > 4){
            return year.substring(0,4);
        }
        return year;
    }

    /**
     * Get authors for amaricas project. This only requires to remove the date info
     *
     * @param author
     * @return formatted value
     */
    private static String getAmericasAuthor(String author){

        String parsedAuthor = author;

        Matcher authorMatcher1 = authorPattern1.matcher(author);
        Matcher authorMatcher2 = authorPattern2.matcher(author);

          if(authorMatcher1.find()){
            parsedAuthor = (authorPattern1.split(author))[0].trim();
        }else if(authorMatcher2.find()){
            parsedAuthor = (authorPattern2.split(author))[0].trim();
        }

        return parsedAuthor;
    }


    /**
     * Get part of the line before "MS \\d" from dc.source.collection 
     *
     * @param source
     * @return formatted value
     */
    private static String getAmericasMSSource(String source){
        String parsedSource="";
            String[] ss = source.split(",");

            for(int i=0; i<ss.length; i++){
                Matcher wrcMatcher2 = wrcPattern2.matcher(ss[i]);
                if(wrcMatcher2.find()){
                    parsedSource = ", " + parsedSource + ss[i];
                    return parsedSource + ".";
                }
                parsedSource += ss[i] + ", ";

            }
        return ".";
    }


    /**
     * Check and see if there are wrc in dc.source.collection
     *
     * @param source
     * @return "Woodson Research Center"
     */
    private static String getWRC(String source){

        Matcher wrcMatcher1 = wrcPattern1.matcher(source);
        if(wrcMatcher1.find()){
            return "Woodson Research Center";
        }else{
            return "";
        }
    }

    /**
     * get the first name initial only, e.g. F. N. Lastname
     *
     * @param name  full name
     * @return name with the firstname initial only
     */
    private static String getFirstNameInitials(String name){
        // seperate the firstname and lastname
        int cn = name.indexOf(",");
        if(cn != -1 ){
            String lastname = name.substring(0, cn);
            String firstname = name.substring(cn+1);

            String[] fns = firstname.trim().split(" ");
            String initialFirstname = "";

            for(int i=0; i<fns.length; i++){
              initialFirstname += fns[i].trim().substring(0, 1).toUpperCase();
              initialFirstname += ". ";
            }
            return (initialFirstname + lastname);

        }
        return name;
    }

   /**
     *
     * If thesis.degree.level = Masters, return “Master’s Thesis”
     * If thesis.degree.level = Doctoral, return “PhD diss.”
     *
     * @param name  full name
     * @return name with the firstname initial only
     */
    private static String getThesisDiss(String degreelevel){
        if (degreelevel.equalsIgnoreCase("masters") ) {
            return  "Master’s Thesis";
        }else if (degreelevel.equalsIgnoreCase("doctoral")) {
            return "Diss.";
        }
        return "";
    }
}
