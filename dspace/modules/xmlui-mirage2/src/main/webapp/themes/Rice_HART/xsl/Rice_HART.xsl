<?xml version="1.0" encoding="UTF-8"?>

<!--
    
    Rice_Commencement.xsl
    
    For overrides in the "Rice University Commencement Programs and Ephemera" community to the base stylesheet (Rice.xsl).
    
    Authors: Ying Jin, Max Starkenburg

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

    <!--                    <xsl:call-template name="itemSummaryView-DIM-URI"/-->
                        <xsl:call-template name="itemSummaryView-DIM-alternative-title"/>
                        <xsl:call-template name="itemSummaryView-DIM-authors"/>
			<xsl:call-template name="itemSummaryView-DIM-vraartist"/>
                        <xsl:call-template name="itemSummaryView-DIM-architect"/>
                        <xsl:call-template name="itemSummaryView-DIM-illustrator"/>
                        <xsl:call-template name="itemSummaryView-DIM-photographer"/>
                        <xsl:call-template name="itemSummaryView-DIM-performer"/>
                        <xsl:call-template name="itemSummaryView-DIM-translator"/>
                        <xsl:call-template name="itemSummaryView-DIM-date"/>                        
			<xsl:call-template name="itemSummaryView-DIM-datenote"/>
                        <xsl:call-template name="itemSummaryView-DIM-description"/>
                        <xsl:call-template name="itemSummaryView-DIM-citation"/>
                        <xsl:call-template name="itemSummaryView-DIM-doi"/>
                        <xsl:call-template name="itemSummaryView-DIM-abstract"/>
                        <xsl:call-template name="itemSummaryView-DIM-subject"/>
                        <xsl:call-template name="itemSummaryView-DIM-type"/>
                        <xsl:call-template name="itemSummaryView-DIM-publisher"/>
                        <xsl:call-template name="itemSummaryView-DIM-department"/>
                        <!--xsl:call-template name="itemSummaryView-DIM-funder"/-->
                        <xsl:call-template name="itemSummaryView-DIM-URI"/>
                        <xsl:if test="$ds_item_view_toggle_url != ''">
                            <xsl:call-template name="itemSummaryView-show-full"/>
                        </xsl:if>
                        <xsl:call-template name="itemSummaryView-collections"/>
</xsl:template>

  <xsl:template name="itemSummaryView-DIM-vraartist">
        <xsl:if test="dim:field[@mdschema='vra' and @element='agent']">
            <div class="simple-item-view-vraagent item-page-field-wrapper table">
                <h5><i18n:text>xmlui.Rice.vraartist</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@mdschema='vra' and @element='agent']">

                            <xsl:copy-of select="./node()"/>

                        <xsl:if test="count(following-sibling::dim:field[@mdschema='vra'][@element='agent']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

        <xsl:template name="itemSummaryView-DIM-datenote">
        <xsl:if test="dim:field[@element='date' and @qualifier='note' and descendant::text()]">
            <div class="simple-item-view-datenote item-page-field-wrapper table">
                <h5><i18n:text>xmlui.Rice.datenote</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='date' and @qualifier='note']">
                            <xsl:copy-of select="./node()"/>
                        <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='note']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>


    
</xsl:stylesheet>
