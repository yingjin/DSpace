<?xml version="1.0" encoding="UTF-8"?>

<!--

    Rice_Researchdata.xsl

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


    <!-- Ying: Updated this for our new theme -->
    <xsl:template name="simple-item-record-rows">
  <!--                    <xsl:call-template name="itemSummaryView-DIM-URI"/-->
          <xsl:call-template name="itemSummaryView-DIM-authors"/>
          <!--xsl:call-template name="itemSummaryView-DIM-title"/-->
          <xsl:call-template name="itemSummaryView-DIM-date-recorded"/>
          <xsl:call-template name="itemSummaryView-DIM-description"/>
          <xsl:call-template name="itemSummaryView-DIM-doi"/>
          <xsl:call-template name="itemSummaryView-DIM-citation"/>
          <xsl:call-template name="itemSummaryView-DIM-subject-keyword"/>
          <xsl:call-template name="itemSummaryView-DIM-publisher"/>
          <xsl:call-template name="itemSummaryView-DIM-URI"/>

          <xsl:if test="$ds_item_view_toggle_url != ''">
              <xsl:call-template name="itemSummaryView-show-full"/>
          </xsl:if>
          <xsl:call-template name="itemSummaryView-collections"/>
    </xsl:template>
         <xsl:template name="itemSummaryView-DIM-authors">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='author' and descendant::text()] or dim:field[@element='creator' and descendant::text()]">
            <div class="simple-item-view-authors item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text></h5>
                <xsl:choose>
                    <xsl:when test="dim:field[@element='creator']">
                        <xsl:for-each select="dim:field[@element='creator']">
                            <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
