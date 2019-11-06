<?xml version="1.0" encoding="UTF-8"?>

<!-- 

    Rice_ETD.xsl

    This file contains overrides of templates, as commented below, for the 
    "Rice University Electronic Theses and Dissertations" community of the 
    Rice Digital Scholarship archive.
    
-->    

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:output indent="yes"/>

  <xsl:template name="simple-item-record-rows">
 
                     <!--xsl:call-template name="itemSummaryView-DIM-alternative-title"/-->
                     <xsl:call-template name="itemSummaryView-DIM-authors"/>
                     <xsl:call-template name="itemSummaryView-DIM-date"/>
                     <xsl:call-template name="itemSummaryView-DIM-advisor"/>
                     <xsl:call-template name="itemSummaryView-DIM-department"/>
                     <xsl:call-template name="itemSummaryView-DIM-degree"/>
                     <xsl:call-template name="itemSummaryView-DIM-abstract"/>
                     <xsl:call-template name="itemSummaryView-DIM-description"/>
                     <xsl:call-template name="itemSummaryView-DIM-subject"/>
                     <xsl:call-template name="itemSummaryView-DIM-citation"/>
                     <xsl:if test="$ds_item_view_toggle_url != ''">
                         <xsl:call-template name="itemSummaryView-show-full"/>
                     </xsl:if>
                     <xsl:call-template name="itemSummaryView-collections"/>
     </xsl:template>


    <!-- MMS: 'Author' row in simple item record (don't let this catch the 'Advisor' information) -->
    <xsl:template name="itemSummaryView-DIM-authors">
       <xsl:if test="dim:field[@element='creator'] or dim:field[@element='contributor'][not(@qualifier='funder') and not(@qualifier='translator') and not(@qualifier='advisor')]">
             <div class="simple-item-view-anthors item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text></h5>
                <div>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                <span>
                                    <xsl:if test="@authority">
                                        <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                    </xsl:if>
                                    <xsl:copy-of select="node()"/>
                                </span>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='creator']">
                            <xsl:for-each select="dim:field[@element='creator']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <!-- MMS: Don't let dc.contributor.funder or .translator count as an author. -->
                        <xsl:when test="dim:field[@element='contributor'][not(@qualifier='funder') and not(@qualifier='translator') and not(@qualifier='advisor')]">
                            <xsl:for-each select="dim:field[@element='contributor'][not(@qualifier='funder') and not(@qualifier='translator') and not(@qualifier='advisor')]">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][not(@qualifier='funder') and not(@qualifier='translator') and not(@qualifier='advisor')]) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
