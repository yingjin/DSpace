package org.dspace.embargo;

import org.dspace.authorize.AuthorizeException;
import org.dspace.content.DCDate;
import org.dspace.content.Item;
import org.dspace.core.Context;

import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.dspace.services.factory.DSpaceServicesFactory;
import org.dspace.embargo.service.EmbargoService;

/**
 * Rice needs a custom combination of Default and DayTable embargo setters.
 */
public class RiceEmbargoSetter extends DefaultEmbargoSetter
{
    // patterns for number, optional space, days|weeks|months|years (last 's' optional)
    private final static Pattern daysPattern = Pattern.compile("(\\d+)\\s?day(?:s)?", Pattern.CASE_INSENSITIVE);
    private final static Pattern weeksPattern = Pattern.compile("(\\d+)\\s?week(?:s)?", Pattern.CASE_INSENSITIVE);
    private final static Pattern monthsPattern = Pattern.compile("(\\d+)\\s?month(?:s)?", Pattern.CASE_INSENSITIVE);
    private final static Pattern yearsPattern = Pattern.compile("(\\d+)\\s?year(?:s)?", Pattern.CASE_INSENSITIVE);

    public RiceEmbargoSetter() {
        super();
    }

    /**
     * Performs a match to extract an int
     * @param matcher a matcher whose group 1 should match an int
     * @return the matched int, or -1 if no match or if the match wasn't an int
     */
    private int matchedInt (Matcher matcher) {
        if (matcher.matches() && matcher.start(1) >= 0) {
            try {
                int number = Integer.parseInt(matcher.group(1));
                return number;
            } catch (NumberFormatException e) {
            }
        }
        return -1;
    }

    /**
     * Parses embargo "terms" into a definite "lift" date.
     * Terms can be the lift date itself in DCDate-compatible format (same as with DefaultEmbargoSetter),
     * or it can be a duration from now, specified as days, weeks, months, or years.
     * (Why not use preconfigured numbers of days, like in DayTableEmbargoSetter? Because 6 months
     * isn't always 180 days, and 1 year isn't always 365. We can do better.)
     *
     * @param context the DSpace context
     * @param item the item to embargo
     * @param terms the embargo terms
     * @return parsed date in DCDate format
     */
    public DCDate parseTerms(Context context, Item item, String terms)
        throws SQLException, AuthorizeException {
            
            String termsOpen = DSpaceServicesFactory.getInstance().getConfigurationService().getProperty("embargo.terms.open");
            

    	if (terms != null) {
            // forever is a special case
            if (termsOpen.equals(terms)) {
                return EmbargoService.FOREVER;
            }

            // if it matches a known duration, use that
            int unit = -1;
            int quantity = matchedInt(daysPattern.matcher(terms));
            if (quantity > 0) {
                unit = Calendar.DATE;
            } else {
                quantity = matchedInt(weeksPattern.matcher(terms));
                if (quantity > 0) {
                    unit = Calendar.WEEK_OF_YEAR;
                } else {
                    quantity = matchedInt(monthsPattern.matcher(terms));
                    if (quantity > 0) {
                        unit = Calendar.MONTH;
                    } else {
                        quantity = matchedInt(yearsPattern.matcher(terms));
                        if (quantity > 0) {
                            unit = Calendar.YEAR;
                        }
                    }
                }
            }
            // if one of the patterns matched, add up the time and set it
            if (unit > 0) {
                Calendar lift = Calendar.getInstance(); // now
                lift.setTimeZone(TimeZone.getTimeZone("UTC")); // DCDate(java.util.Date) expects time in UTC, not local
                lift.add(unit, quantity);
                return new DCDate(lift.getTime());
            }

            // If it doesn't contain a hyphen, it is not an ISO-8601 date with granularity > year,
            //  so don't bother trying to make a date from it, especially since the DCDate constructor
            //  accepts numbers like '0' as valid dates (thinking we're referring to 0 A.D. or whatever).
            // Otherwise, try to interpret it as a valid lift date
            // Ying updated this to have end date input working
            if (terms.length() > 0 ) {
                return new DCDate(terms);
            }
        }
        return null;
    }

    /**
     * Test parses a sample "terms"
     * @param argv first parram is the "terms" to parse. Output is the corresponding generated "lift" value.
     */
    public static void main(String argv[]) {
        RiceEmbargoSetter setter = new RiceEmbargoSetter();
        try {
            System.out.println("input is '"+argv[0]+"'");
            DCDate d = setter.parseTerms(null, null, argv[0]);
            if (d == null) {
                System.out.println("lift is true null");
            } else {
                System.out.println("lift date is "+d);
                System.out.println("DCDate as Date: "+new SimpleDateFormat("MMMM dd, yyyy GG, HH:mm:ss 'GMT'").format(d.toDate()));
            }
        } catch (Exception e) {
            System.err.println(e.getMessage());
            System.err.println(e.getStackTrace());
        }
    }
}
