<?xml version="1.0" encoding="UTF-8"?>

<!-- 

    Rice_CTTL.xsl

    This file contains overrides of templates, as commented below, for the 
    CTTL "Web adventures for education" community of the 
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

        <!-- Ying: Updated this for our new theme -->
     <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
         <div class="item-summary-view-metadata">
             <xsl:call-template name="itemSummaryView-DIM-title"/>
             <div class="row">
                      <!-- Generate the bitstream information from the file section -->

             <!--    <div class="col-sm-12">
                     <div class="row">
                         <div class="col-xs-6 col-sm-6">
                             <xsl:call-template name="itemSummaryView-DIM-thumbnail"/>
                         </div>
                         <div class="col-xs-6 col-sm-6">
                             <xsl:call-template name="itemSummaryView-DIM-file-section"/>
                         </div>
                     </div>
                 </div>   -->
                 <div class="col-sm-12">
                     <xsl:call-template name="simple-item-record-rows"/>
                 </div>
             </div>
         </div>
     </xsl:template>

    <xsl:template name="simple-item-record-rows">
 <!--                    <xsl:call-template name="itemSummaryView-DIM-URI"/-->
                     <xsl:call-template name="itemSummaryView-DIM-description"/>
                     <xsl:call-template name="itemSummaryView-DIM-authors"/>
                     <xsl:call-template name="itemSummaryView-DIM-nsdl-uri"/>
                      <xsl:if test="$ds_item_view_toggle_url != ''">
                         <xsl:call-template name="itemSummaryView-show-full"/>
                     </xsl:if>
                     <xsl:call-template name="itemSummaryView-collections"/>
     </xsl:template>

    <xsl:template name="itemSummaryView-DIM-nsdl-uri">
    <xsl:if test="dim:field[@mdschema='nsdl' and @element='identifier' and @qualifier='uri']">
        <div class="simple-item-view-nsdl-identifier-uri item-page-field-wrapper table">
            <h5>Go to game:</h5>
            <div>
                <xsl:for-each select="dim:field[@mdschema='nsdl' and @element='identifier' and @qualifier='uri']">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:copy-of select="./node()"/>
                        </xsl:attribute>
                        <img alt="Thumbnail">
                            <xsl:attribute name="src">
                                <xsl:value-of select="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                    mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:attribute>
                        </img>
                    </a>
                    <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
               </div>
        </div>
     </xsl:if>
</xsl:template>


</xsl:stylesheet>
