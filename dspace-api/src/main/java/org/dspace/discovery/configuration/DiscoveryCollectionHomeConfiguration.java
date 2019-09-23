/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.discovery.configuration;

import org.springframework.beans.factory.annotation.Required;

/**
 * @author Ying Jin (ying.jin at rice dot edu)
 */
public class DiscoveryCollectionHomeConfiguration {

    private String metadataSortField;
    private String type;

    private int perpage = 60;

    public String getMetadataSortField() {
        return metadataSortField;
    }

    @Required
    public void setMetadataSortField(String metadataSortField) {
        this.metadataSortField = metadataSortField;
    }

    public int getPerpage() {
        return perpage;
    }

    @Required
    public void setPerpage(int perpage) {
        this.perpage = perpage;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }
}
