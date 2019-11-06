<?xml version="1.0" encoding="UTF-8"?>

<!--
    
    reusable-overrides.xsl
    
    Description: This file contains template overrides that have been found to have use in multiple 
    themes, even when those themes are of drastically different appearance (e.g. the Rice theme vs. 
    the Americas theme).  It allows themes to avoid pulling in all of Rice.xsl to get certain basic
    functionality.  The template may include what we might consider bug fixes or feature additions 
    to the base set of stylesheets provided by DSpace.  However, depending on the circumstances, even 
    these overrides may need to be overridden (e.g. the Shepherd School theme displays "mets:file" 
    differently).
    
    It differs from reusable-new-templates.xsl in tdhat it contains overrides of templates that have
    already been defined elsewhere (mostly in the base set of DSPace stylesheets) or that are very 
    similar to those defined elsewhere but with a greater specificity applied.
    
    Author: Max Starkenburg
    Author: Ying Jin
    Author: Sid Byrd
    Author: Alexey Maslov (original author of many of the overridden templates, to which we have, in some cases, just made small edits)
    
-->


<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"

    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:jstring="java.lang.String"
    xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights confman">

    <xsl:import href="rice-homepage.xsl" />
    <xsl:import href="rice-deposit-work.xsl" />
    <xsl:param name="browser" />

     <xsl:variable name="repositoryURL" select="dri:document/dri:meta/dri:pageMeta/dri:trail[1]/@target"/>
    <xsl:variable name="baseURL" select="confman:getProperty('dspace.baseUrl')"/>



    <!-- From common.xsl
        The following options can be appended to the external metadata URL to request specific
        sections of the METS document:

        sections:

        A comma-separated list of METS sections to included. The possible values are: "metsHdr", "dmdSec",
        "amdSec", "fileSec", "structMap", "structLink", "behaviorSec", and "extraSec". If no list is provided then *ALL*
        sections are rendered.


        dmdTypes:

        A comma-separated list of metadata formats to provide as descriptive metadata. The list of avaialable metadata
        types is defined in the dspace.cfg, disseminationcrosswalks. If no formats are provided them DIM - DSpace
        Intermediate Format - is used.


        amdTypes:

        A comma-separated list of metadata formats to provide administative metadata. DSpace does not currently
        support this type of metadata.


        fileGrpTypes:

        A comma-separated list of file groups to render. For DSpace a bundle is translated into a METS fileGrp, so
        possible values are "THUMBNAIL","CONTENT", "METADATA", etc... If no list is provided then all groups are
        rendered.


        structTypes:

        A comma-separated list of structure types to render. For DSpace there is only one structType: LOGICAL. If this
        is provided then the logical structType will be rendered, otherwise none will. The default operation is to
        render all structure types.
    -->

    <!-- Then we resolve the reference tag to an external mets object -->
    <xsl:template match="dri:reference" mode="summaryList">
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="@url"/>
            <!-- Since this is a summary only grab the descriptive metadata, and the thumbnails -->
            <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL</xsl:text>
            <!-- An example of requesting a specific metadata standard (MODS and QDC crosswalks only work for items)->
            <xsl:if test="@type='DSpace Item'">
                <xsl:text>&amp;dmdTypes=DC</xsl:text>
            </xsl:if>-->
        </xsl:variable>
        <xsl:comment> External Metadata URL: <xsl:value-of select="$externalMetadataURL"/> </xsl:comment>
        <li>
            <xsl:attribute name="class">
                <xsl:text>ds-artifact-item </xsl:text>
                <xsl:choose>
                    <xsl:when test="position() mod 2 = 0">even</xsl:when>
                    <xsl:otherwise>odd</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="document($externalMetadataURL)" mode="summaryList"/>
            <xsl:apply-templates />
        </li>
    </xsl:template>


    <!-- From discovery.xml, remove no-author -->
       <xsl:template name="itemSummaryList">
        <xsl:param name="handle"/>
        <xsl:param name="externalMetadataUrl"/>

        <xsl:variable name="metsDoc" select="document($externalMetadataUrl)"/>

           <xsl:variable name="type">

               <xsl:for-each select="$metsDoc/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='type' and @qualifier='dcmi']">

                   <xsl:if test=". = 'Sound'">
                       <xsl:value-of select="'music'"/>
                   </xsl:if>
               </xsl:for-each>
           </xsl:variable>

        <div class="row ds-artifact-item ">

            <!--Generates thumbnails (if present)-->
            <div class="col-sm-3 hidden-xs">
                <xsl:apply-templates select="$metsDoc/mets:METS/mets:fileSec" mode="artifact-preview">
                    <xsl:with-param name="href" select="concat($context-path, '/handle/', $handle)"/>
                    <xsl:with-param name="type" select="$type"/>
                </xsl:apply-templates>
            </div>


            <div class="col-sm-9 artifact-description">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:choose>
                            <xsl:when test="$metsDoc/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/@withdrawn">
                                <xsl:value-of select="$metsDoc/mets:METS/@OBJEDIT"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat($context-path, '/handle/', $handle)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <h4>
                        <xsl:choose>
                            <xsl:when test="dri:list[@n=(concat($handle, ':dc.title'))]">
                                <xsl:apply-templates select="dri:list[@n=(concat($handle, ':dc.title'))]/dri:item"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <!-- Generate COinS with empty content per spec but force Cocoon to not create a minified tag  -->
                        <span class="Z3988">
                            <xsl:attribute name="title">
                                <xsl:for-each select="$metsDoc/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim">
                                    <xsl:call-template name="renderCOinS"/>
                                </xsl:for-each>
                            </xsl:attribute>
                            <xsl:text>&#160;</xsl:text>
                            <!-- non-breaking space to force separating the end tag -->
                        </span>
                    </h4>
                </xsl:element>
                <div class="artifact-info">
                    <span class="author h4">    <small>
                        <xsl:choose>
                            <xsl:when test="dri:list[@n=(concat($handle, ':dc.contributor.author'))]">
                                <xsl:for-each select="dri:list[@n=(concat($handle, ':dc.contributor.author'))]/dri:item">
                                    <xsl:variable name="author">
                                        <xsl:apply-templates select="."/>
                                    </xsl:variable>
                                    <span>
                                        <!--Check authority in the mets document-->
                                        <xsl:if test="$metsDoc/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='contributor' and @qualifier='author' and . = $author]/@authority">
                                            <xsl:attribute name="class">
                                                <xsl:text>ds-dc_contributor_author-authority</xsl:text>
                                            </xsl:attribute>
                                        </xsl:if>
                                        <xsl:apply-templates select="."/>
                                    </span>

                                    <xsl:if test="count(following-sibling::dri:item) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="dri:list[@n=(concat($handle, ':dc.creator'))]">
                                <xsl:for-each select="dri:list[@n=(concat($handle, ':dc.creator'))]/dri:item">
                                    <xsl:apply-templates select="."/>
                                    <xsl:if test="count(following-sibling::dri:item) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="dri:list[@n=(concat($handle, ':dc.contributor'))]">
                                <xsl:for-each select="dri:list[@n=(concat($handle, ':dc.contributor'))]/dri:item">
                                    <xsl:apply-templates select="."/>
                                    <xsl:if test="count(following-sibling::dri:item) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <!--i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text-->
                            </xsl:otherwise>
                        </xsl:choose>
                        </small></span>
                    <xsl:text> </xsl:text>
                    <xsl:if test="dri:list[@n=(concat($handle, ':dc.date.issued'))]">
                        <span class="publisher-date h4">   <small>
                            <xsl:text>(</xsl:text>
                            <xsl:if test="dri:list[@n=(concat($handle, ':dc.publisher'))]">
                                <span class="publisher">
                                    <xsl:apply-templates select="dri:list[@n=(concat($handle, ':dc.publisher'))]/dri:item"/>
                                </span>
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <span class="date">
                                <xsl:value-of
                                        select="substring(dri:list[@n=(concat($handle, ':dc.date.issued'))]/dri:item,1,10)"/>
                            </span>
                            <xsl:text>)</xsl:text>
                            </small></span>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="dri:list[@n=(concat($handle, ':dc.description.abstract'))]/dri:item/dri:hi">
                            <div class="abstract">
                                <xsl:for-each select="dri:list[@n=(concat($handle, ':dc.description.abstract'))]/dri:item">
                                    <xsl:apply-templates select="."/>
                                    <xsl:text>...</xsl:text>
                                    <br/>
                                </xsl:for-each>

                            </div>
                        </xsl:when>
                        <xsl:when test="dri:list[@n=(concat($handle, ':fulltext'))]">
                            <div class="abstract">
                                <xsl:for-each select="dri:list[@n=(concat($handle, ':fulltext'))]/dri:item">
                                    <xsl:apply-templates select="."/>
                                    <xsl:text>...</xsl:text>
                                    <br/>
                                </xsl:for-each>
                            </div>
                        </xsl:when>
                        <xsl:when test="dri:list[@n=(concat($handle, ':dc.description.abstract'))]/dri:item">
                        <div class="abstract">
                                <xsl:value-of select="util:shortenString(dri:list[@n=(concat($handle, ':dc.description.abstract'))]/dri:item[1], 220, 10)"/>
                        </div>
                    </xsl:when>
                    </xsl:choose>
                </div>
            </div>
        </div>
    </xsl:template>

      <xsl:template match="dri:list/dri:list/dri:list" mode="dsoList" priority="8">
            <!--
                Retrieve the type from our name, the name contains the following format:
                    {handle}:{metadata}
            -->
            <xsl:variable name="handle">
                <xsl:value-of select="substring-before(@n, ':')"/>
            </xsl:variable>
            <xsl:variable name="type">
                <xsl:value-of select="substring-after(@n, ':')"/>
            </xsl:variable>
            <xsl:variable name="externalMetadataURL">
                <xsl:text>cocoon://metadata/handle/</xsl:text>
                <xsl:value-of select="$handle"/>
                <xsl:text>/mets.xml</xsl:text>
                <!-- Since this is a summary only grab the descriptive metadata, and the thumbnails -->
                <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL</xsl:text>
                <!-- An example of requesting a specific metadata standard (MODS and QDC crosswalks only work for items)->
                <xsl:if test="@type='DSpace Item'">
                    <xsl:text>&amp;dmdTypes=DC</xsl:text>
                </xsl:if>-->
            </xsl:variable>


        <xsl:choose>
            <xsl:when test="$type='community'">
                <xsl:call-template name="communitySummaryList">
                    <xsl:with-param name="handle">
                        <xsl:value-of select="$handle"/>
                    </xsl:with-param>
                    <xsl:with-param name="externalMetadataUrl">
                        <xsl:value-of select="$externalMetadataURL"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$type='collection'">
                <xsl:call-template name="collectionSummaryList">
                    <xsl:with-param name="handle">
                        <xsl:value-of select="$handle"/>
                    </xsl:with-param>
                    <xsl:with-param name="externalMetadataUrl">
                        <xsl:value-of select="$externalMetadataURL"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$type='item'">
                <xsl:call-template name="itemSummaryList">
                    <xsl:with-param name="handle">
                        <xsl:value-of select="$handle"/>
                    </xsl:with-param>
                    <xsl:with-param name="externalMetadataUrl">
                        <xsl:value-of select="$externalMetadataURL"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- TODO: Adding this can break the search "GO" and "login" buttons etc...WHY!!!!



    Ying:from core/elements.xsl -
        Non-interactive divs get turned into HTML div tags. The general process, which is found in many
        templates in this stylesheet, is to call the template for the head element (creating the HTML h tag),
        handle the attributes, and then apply the templates for the all children except the head. The id
        attribute is -->
    <xsl:template match="dri:div--DEBUG" priority="1">
        <xsl:apply-templates select="dri:head"/>
        <xsl:apply-templates select="@pagination">
            <xsl:with-param name="position">top</xsl:with-param>
        </xsl:apply-templates>
        <div>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">ds-static-div</xsl:with-param>
            </xsl:call-template>
            <xsl:choose>
                <!--  does this element have any children -->
                <xsl:when test="child::node()">
                    <xsl:apply-templates select="*[not(name()='head')]"/>
                </xsl:when>
                <!-- if no children are found we add a space to eliminate self closing tags -->
                <xsl:otherwise>
                    &#160;
                </xsl:otherwise>
            </xsl:choose>
        </div>
        <xsl:variable name="itemDivision">
            <xsl:value-of select="@n"/>
        </xsl:variable>
        <xsl:variable name="xrefTarget">
            <xsl:value-of select="./dri:p/dri:xref/@target"/>
        </xsl:variable>
        <!-- we decided to remove the cc-license on the bottom and using regular metadata display-->
        <!--xsl:if test="$itemDivision='item-view'">
            <xsl:call-template name="cc-license">
                <xsl:with-param name="metadataURL" select="./dri:referenceSet/dri:reference/@url"/>
            </xsl:call-template>

            <xsl:call-template name="rights-statement">
                   <xsl:with-param name="metadataURL" select="./dri:referenceSet/dri:reference/@url"/>
               </xsl:call-template>

        </xsl:if-->

        <xsl:apply-templates select="@pagination">
            <xsl:with-param name="position">bottom</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

       <!--Ying: The rights statement: updated from cc-license in core/page-structure.xsl. also changed core/elements.xsl-->
    <xsl:template name="rights-statement">
        <xsl:param name="metadataURL"/>
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="$metadataURL"/>
            <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL</xsl:text>
        </xsl:variable>
        <xsl:variable name="LicenseName"
                      select="document($externalMetadataURL)//dim:field[@element='rights']"
                />
        <xsl:variable name="LicenseUri"
                      select="document($externalMetadataURL)//dim:field[@element='rights'][@qualifier='uri']"
                />

                <xsl:variable name="handleUri">
            <xsl:for-each select="document($externalMetadataURL)//dim:field[@element='identifier' and @qualifier='uri']">
                <a>
                    <xsl:attribute name="href">
                        <xsl:copy-of select="./node()"/>
                    </xsl:attribute>
                    <xsl:copy-of select="./node()"/>
                </a>
                <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

                  <!-- Add "Rights and Usage" section for any dc.rights and dc.rights.uri fields -->
            <!--xsl:if test="document($externalMetadataURL)//dim:field[@element='rights']"-->
         <xsl:if test="$LicenseName and (not($LicenseUri) or not(contains($LicenseUri, 'creativecommons')))">
                <div about="{$handleUri}" class="row" style="vertical-align:center;">
                    <div class="col-sm-1 col-xs-12" style="vertical-align:bottom;">
                        <!-- i18n: Rights and Usage -->
                        <!--i18n:text>xmlui.Rice.RightsAndUsage</i18n:text-->
                        <img class="img-responsive">
                             <xsl:attribute name="src">
                                 <xsl:value-of select="concat($theme-path,'/images/340px-Copyright.svg.png')"/>
                                 <!--xsl:value-of select="concat($theme-path,'/images/rights.jpg')"/-->
                             </xsl:attribute>
                         </img>

                    </div> <div class="col-sm-8" style="vertical-align:bottom;">
                           <span>
                               <xsl:for-each select="document($externalMetadataURL)//dim:field[@element='rights']">
                                <xsl:choose>
                                    <xsl:when test="contains(.,'http://')">
                                        <xsl:call-template name="makeLinkFromText"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy>
                                            <xsl:call-template name="parse">
                                                <xsl:with-param name="str" select="./node()"/>
                                            </xsl:call-template>
                                        </xsl:copy>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <br/>
                            </xsl:for-each>
                        </span>
                    </div>
                </div>
            </xsl:if>

    <!--    <xsl:variable name="ccLicenseName"
                      select="document($externalMetadataURL)//dim:field[@element='rights']"
                />
        <xsl:variable name="ccLicenseUri"
                      select="document($externalMetadataURL)//dim:field[@element='rights'][@qualifier='uri']"
                />
        <xsl:variable name="handleUri">
            <xsl:for-each select="document($externalMetadataURL)//dim:field[@element='identifier' and @qualifier='uri']">
                <a>
                    <xsl:attribute name="href">
                        <xsl:copy-of select="./node()"/>
                    </xsl:attribute>
                    <xsl:copy-of select="./node()"/>
                </a>
                <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:if test="$ccLicenseName and $ccLicenseUri and contains($ccLicenseUri, 'creativecommons')">
            <div about="{$handleUri}" class="row">
            <div class="col-sm-3 col-xs-12">
                <a rel="license"
                   href="{$ccLicenseUri}"
                   alt="{$ccLicenseName}"
                   title="{$ccLicenseName}"
                        >
                    <img class="img-responsive">
                        <xsl:attribute name="src">
                            <xsl:value-of select="concat($theme-path,'/images/cc-ship.gif')"/>
                        </xsl:attribute>
                        <xsl:attribute name="alt">
                            <xsl:value-of select="$ccLicenseName"/>
                        </xsl:attribute>
                    </img>
                </a>
            </div> <div class="col-sm-8">
                <span>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.cc-license-text</i18n:text>
                    <xsl:value-of select="$ccLicenseName"/>
                </span>
            </div>
            </div>
        </xsl:if>   -->
    </xsl:template>


           <!-- From item-list.xsl - Generate the info about the item from the metadata section -->
        <!--xsl:template match="dim:dim" mode="itemSummaryList-DIM">
            <xsl:variable name="itemWithdrawn" select="@withdrawn" />
            <div class="artifact-description">
                <div class="artifact-title">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:choose>
                                <xsl:when test="$itemWithdrawn">
                                    <xsl:value-of select="ancestor::mets:METS/@OBJEDIT" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="ancestor::mets:METS/@OBJID" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="dim:field[@element='title']">
                                <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </div>
                <span class="Z3988">
                    <xsl:attribute name="title">
                        <xsl:call-template name="renderCOinS"/>
                    </xsl:attribute>
                    &#xFEFF;
                </span>
                <div class="artifact-info">
                    <span class="author">
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
                            <xsl:when test="dim:field[@element='contributor']">
                             <xsl:if test="not(dim:field[@element='contributor'][@qualifier='funder'])">


                                <xsl:for-each select="dim:field[@element='contributor']">
                                    <xsl:copy-of select="node()"/>
                                    <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                                </xsl:if>
                            </xsl:when>

                            <xsl:otherwise>

                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                    <xsl:text> </xsl:text>
                    <xsl:if test="dim:field[@element='date' and @qualifier='issued'] or dim:field[@element='publisher']">
                        <span class="publisher-date">
                            <xsl:text>(</xsl:text>

                            <span class="date">
                                <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                            </span>
                            <xsl:text>)</xsl:text>
                        </span>
                    </xsl:if>
                </div>
            </div>
        </xsl:template-->


       <!--handles the rendering of a single item in a list in metadata mode-->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM-metadata">
        <xsl:param name="href"/>
        <div class="artifact-description">
            <h4 class="artifact-title">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$href"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title']">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <span class="Z3988">
                    <xsl:attribute name="title">
                        <xsl:call-template name="renderCOinS"/>
                    </xsl:attribute>
                    &#xFEFF; <!-- non-breaking space to force separating the end tag -->
                </span>
            </h4>
            <div class="artifact-info">
                <span class="author h4">
                    <small>
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
                        <xsl:when test="dim:field[@element='contributor']">
                            <!-- Ying's note, the code works here for the summarylist-->
                            <xsl:if test="not(dim:field[@element='contributor'][@qualifier='funder'])">
                            <xsl:for-each select="dim:field[@element='contributor']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                                 <i18n:text></i18n:text>
                        </xsl:otherwise>
                        <!--xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                        </xsl:otherwise-->
                    </xsl:choose>
                    </small>
                </span>
                <xsl:text> </xsl:text>
                <xsl:if test="dim:field[@element='date' and @qualifier='issued']">
	                <span class="publisher-date h4">  <small>
	                    <xsl:text>(</xsl:text>
	                    <!--xsl:if test="dim:field[@element='publisher']">
	                        <span class="publisher">
	                            <xsl:copy-of select="dim:field[@element='publisher']/node()"/>
	                        </span>
	                        <xsl:text>, </xsl:text>
	                    </xsl:if-->
	                    <span class="date">
	                        <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
	                    </span>
	                    <xsl:text>)</xsl:text>
                        </small></span>
                </xsl:if>
            </div>
            <xsl:if test="dim:field[@element = 'description' and @qualifier='abstract']">
                <xsl:variable name="abstract" select="dim:field[@element = 'description' and @qualifier='abstract']/node()"/>
                <div class="artifact-abstract">
                    <xsl:value-of select="util:shortenString($abstract, 220, 10)"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>

    <!-- we have no setup for xmlui.theme.mirage.item-list.emphasis, just hard coded with 'file' -->
     <xsl:template name="itemSummaryList-DIM">
        <xsl:variable name="itemWithdrawn" select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/@withdrawn" />

        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="$itemWithdrawn">
                    <xsl:value-of select="@OBJEDIT"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@OBJID"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- confman:getProperty('xmlui.theme.mirage.item-list.emphasis') -->
        <xsl:variable name="emphasis" select="'file'"/>
         <xsl:variable name="type">

            <xsl:for-each select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='type' and @qualifier='dcmi']">

                 <xsl:if test=". = 'Sound'">
                    <xsl:value-of select="'music'"/>
                </xsl:if>
            </xsl:for-each>
         </xsl:variable>



        <xsl:choose>
            <xsl:when test="'file' = $emphasis">


                <div class="item-wrapper row">
                    <div class="col-sm-3 hidden-xs">
                        <xsl:apply-templates select="./mets:fileSec" mode="artifact-preview">
                            <xsl:with-param name="href" select="$href"/>
                            <xsl:with-param name="type" select="$type"/>
                        </xsl:apply-templates>
                    </div>

                    <div class="col-sm-9">
                        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                             mode="itemSummaryList-DIM-metadata">
                            <xsl:with-param name="href" select="$href"/>
                        </xsl:apply-templates>
                    </div>

                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                     mode="itemSummaryList-DIM-metadata"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ============================================
                     Reference listings
         ============================================ -->
    
    <!-- Ying (via MMS): Find the first thumbnail to display in summary list page. -->
    <!--xsl:template match="mets:fileGrp[@USE='THUMBNAIL']/mets:file" mode="thumbnail">
        <xsl:if test="position()=1">
            <a href="{ancestor::mets:METS/@OBJID}">
                <img alt="Thumbnail">
                    <xsl:attribute name="src">
                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                    </xsl:attribute>
                </img>
            </a>
        </xsl:if>
    </xsl:template-->



    <!-- ============================================
                   Item record page (general)
         ============================================ -->
    
    <!-- Ying added this template for jp2 in iiif image -->
    <xsl:template match="mets:file[@MIMETYPE='image/jp2']" mode="itemSummaryView-DIM">
        <xsl:param name="context"/>
        <xsl:param name="handle"/>

        <a class="image-link" href="http://localhost:5000/{$handle}">
            <img alt="Thumbnail">
                <xsl:attribute name="src">
                    <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                                mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                </xsl:attribute>
            </img>
        </a>
    </xsl:template>
    <!-- END Ying added this template for jp2 in iiif image -->

    <!-- Ying: Updated this for our new theme -->
     <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
         <div class="item-summary-view-metadata">
             <xsl:call-template name="itemSummaryView-DIM-title"/>
         <div class="row">

          <!-- Generate the bitstream information from the file section -->
         <xsl:if test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' and @USE='ORIGINAL']/mets:file[@MIMETYPE='image/jp2']">
             <!--h3><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h3-->
             <div class="file-list">
                 <xsl:apply-templates select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' and @USE='ORIGINAL']/mets:file[@MIMETYPE='image/jp2']" mode="itemSummaryView-DIM">
                     <xsl:with-param name="context" select="//mets:METS"/>
                     <xsl:with-param name="handle" select="//mets:METS[@OBJID]"/>
                 </xsl:apply-templates>
             </div>
         </xsl:if>
         <xsl:choose>
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <!--h3><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h3-->
                <div class="file-list">
                    <xsl:apply-templates select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE' or @USE='CC-LICENSE']">
                        <xsl:with-param name="context" select="//mets:METS"/>
                        <xsl:with-param name="primaryBitstream" select="//mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                    </xsl:apply-templates>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="//mets:fileSec/mets:fileGrp[@USE='ORE']"/>
            </xsl:when>
            <xsl:otherwise>
                <h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h2>
                <table class="ds-table file-list">
                    <tr class="ds-table-header-row">
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <p><i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text></p>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>
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

     <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
         <xsl:variable name="repositoryURL" select="dri:document/dri:meta/dri:pageMeta/dri:trail[1]/@target"/>
         <xsl:variable name="bitstreamurl1" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
         <xsl:variable name="bitstreamurl" select="substring-before($bitstreamurl1, '&amp;isAllowed')"/>
         <xsl:variable name="ID"><xsl:value-of select="@ID"/></xsl:variable>
         <xsl:variable name="streamingfilename">
             <xsl:value-of select="$ID"/>_<xsl:value-of select="mets:FLocat/@xlink:title"/>
         </xsl:variable>
         <xsl:variable name="filename">
             <xsl:value-of select="mets:FLocat/@xlink:title"/>
         </xsl:variable>
         <xsl:variable name="first_lf">
             <xsl:value-of select='substring($filename, 0, 1)'/><xsl:text>.vtt</xsl:text>
         </xsl:variable>


         <xsl:variable name="FL_ID">
             <xsl:value-of select="substring($ID, 1,1)"/>
         </xsl:variable>

        <div class="file-wrapper row">
            <div class="col-xs-6 col-sm-5">
                <div class="thumbnail">
                    <xsl:choose>
                        <xsl:when test="@MIMETYPE='image/jp2'">
                            <a class="image-link" href="javascript:showJPEG2000Viewer('{$bitstreamurl}')">
                                <img alt="Thumbnail">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                            mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                    </xsl:attribute>
                                </img>
                            </a>
                        </xsl:when>

                        <xsl:when test="@MIMETYPE='video/mp4' or @MIMETYPE='video/m4v'">
                            <!--div class="videoContainer" style="height: 0;overflow: hidden;padding-bottom: 56.25%;padding-top: 25px;position: relative;">
                            <div id="{$streamingfilename}" style="position:absolute;width:100% !important;height: 100% !important;">Loading the player...</div>
                            -->
                            <xsl:variable name="filename_suffix">
                                <xsl:if test="@MIMETYPE='video/mp4'">
                                    <xsl:text>mp4</xsl:text>
                                </xsl:if>
                                <xsl:if test="@MIMETYPE='video/m4v'">
                                    <xsl:text>m4v</xsl:text>
                                </xsl:if>
                            </xsl:variable>)

                            <div class="videoContainer">
                            <div id="{$streamingfilename}">Loading the player...</div>

                            <xsl:variable name="mp4thumb1" select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            <xsl:variable name="mp4thumb" select="substring-before($mp4thumb1, '?')"/>

                            <xsl:choose>
                                <xsl:when test="contains($filename, '_caption')">
                                    <!-- find the sibling vtt file and get the streaming name -->
                                    <xsl:variable name="vtt_filename">
                                        <xsl:value-of select='$filename'/><xsl:text>.vtt</xsl:text>
                                    </xsl:variable>
                                    <script type="text/javascript">
                                        jwplayer.key = "7v+RIu3+q3k5BpVlhvaNE9PseQLW8aQiUgoyLA==";
                                        var playerInstance = jwplayer('<xsl:value-of select="$streamingfilename"/>');
                                        playerInstance.setup({

                                            playlist: [{
                                                image: "<xsl:value-of select='$mp4thumb'/>",
                                                sources: [{
                                                    file: "<xsl:value-of select="$baseURL"/>/streaming/<xsl:value-of select='$filename_suffix' />/<xsl:value-of select='$FL_ID'/>/<xsl:value-of select='$streamingfilename'/>"
                                                },{
                                                    file: "rtmp://fldp.rice.edu/fondren/mp4:<xsl:value-of select='$streamingfilename'/>"
                                                }],
                                                tracks: [{
                                                    file: "<xsl:value-of select="$baseURL"/>/streaming/vtt/<xsl:value-of select='$first_lf'/>/<xsl:value-of
                                                        select='$vtt_filename'/>",
                                                    label: "English",
                                                    kind: "captions",
                                                    "default": true
                                                }]

                                            }],
                                            primary: "html5",
                                            rtmp: {
                                                bufferlength: 10
                                            },
                                            aspectratio:"16:9",
                                            allowfullscreen: true,
                                            width: "100%",
                                        });
                                    </script>
                                </xsl:when>
                                <xsl:otherwise>
                                    <script type="text/javascript">
                                        jwplayer.key = "7v+RIu3+q3k5BpVlhvaNE9PseQLW8aQiUgoyLA==";
                                        var playerInstance = jwplayer('<xsl:value-of select="$streamingfilename"/>');
                                        playerInstance.setup({

                                            playlist: [{
                                                image: "<xsl:value-of select='$mp4thumb'/>",
                                                sources: [{
                                                    file: "<xsl:value-of select="$baseURL"/>/streaming/<xsl:value-of select='$filename_suffix' />/<xsl:value-of select='$FL_ID'/>/<xsl:value-of select='$streamingfilename'/>"
                                                },{
                                                    file: "rtmp://fldp.rice.edu/fondren/mp4:<xsl:value-of select='$streamingfilename'/>"
                                                }],

                                            }],
                                            primary: "html5",
                                            rtmp: {
                                                bufferlength: 10
                                            },
                                            aspectratio:"16:9",
                                            allowfullscreen: true,
                                            width: "100%",
                                        });
                                    </script>
                                </xsl:otherwise>

                            </xsl:choose>

                        </div>
                    </xsl:when>

                    <xsl:when test="@MIMETYPE='audio/x-mp3'">

                                    <!-- With JWPlayer 6 -->
                        <xsl:choose>
                            <xsl:when test="contains($filename, '_caption')">
                                <!-- find the sibling vtt file and get the streaming name -->
                                <xsl:variable name="vtt_filename">
                                    <xsl:value-of select='$filename'/><xsl:text>.vtt</xsl:text>
                                </xsl:variable>


                                <div id="{$streamingfilename}">Loading the player...</div>

                                <script type="text/javascript">
                                jwplayer.key = "7v+RIu3+q3k5BpVlhvaNE9PseQLW8aQiUgoyLA==";
                                var playerInstance = jwplayer('<xsl:value-of select="$streamingfilename"/>');
                                playerInstance.setup({
                                    playlist: [{

                                        sources: [{
                                             file: "<xsl:value-of select="$baseURL"/>/streaming/mp3/<xsl:value-of select="$FL_ID"/>/<xsl:value-of select="$streamingfilename"/>"
                                        },{
                                            file: "rtmp://fldp.rice.edu/fondren/mp3:<xsl:value-of select='$streamingfilename'/>"
                                        }],
                                        tracks: [{
                                            file: "<xsl:value-of select="$baseURL"/>/streaming/vtt/<xsl:value-of
                                        select='$first_lf'/>/<xsl:value-of select='$vtt_filename'/>",
                                            label: "English",
                                            kind: "captions",
                                            "default": true
                                        }]
                                    }],
                                    primary: "html5",
                                    height: "100",
                                    width: "320",
                                });
                                </script>
                            </xsl:when>
                            <xsl:otherwise>

                                <div id="{$streamingfilename}">Loading the player...</div>

                                <script type="text/javascript">
                                    jwplayer.key = "7v+RIu3+q3k5BpVlhvaNE9PseQLW8aQiUgoyLA==";
                                    var playerInstance = jwplayer('<xsl:value-of select="$streamingfilename"/>');
                                    playerInstance.setup({
                                        playlist: [{

                                            sources: [{
                                                file: "<xsl:value-of select="$baseURL"/>/streaming/mp3/<xsl:value-of select="$FL_ID"/>/<xsl:value-of select="$streamingfilename"/>"
                                                },{
                                                file: "rtmp://fldp.rice.edu/fondren/mp3:<xsl:value-of select='$streamingfilename'/>"
                                            }],

                                        }],
                                        primary: "html5",
                                        height: "30",
                                        width: "320",
                                    });
                                </script>

                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="(@MIMETYPE='ohms/xml')">
                         <a type="button" class="btn btn-primary">
                            <xsl:attribute name="href">
                                <xsl:value-of select="$baseURL"/>/ohms/viewer.php?cachefile=<xsl:value-of select="$streamingfilename"/>
                            </xsl:attribute>
                            <span class="glyphicon glyphicon-arrow-down" style="visibility: hidden"></span><span class="glyphicon glyphicon-headphones"></span><xsl:text> </xsl:text><span class="glyphicon glyphicon-comment"></span><xsl:text> Synchronized Viewer</xsl:text>
                         </a>
                    </xsl:when>

                        <xsl:otherwise>

                            <a class="image-link">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                </xsl:attribute>
                                <xsl:choose>
                                    <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                        mets:file[@GROUPID=current()/@GROUPID]">
                                        <img alt="Thumbnail">
                                            <xsl:attribute name="src">
                                                <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                            mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                            </xsl:attribute>
                                        </img>
                                    </xsl:when>
                                    <xsl:otherwise>
                                            <img alt="xmlui.mirage2.item-list.thumbnail" i18n:attr="alt" src="{concat($theme-path,'/images/Text_Page_Icon.png')}">
                                            </img>
                                        <!--img alt="Thumbnail">
                                                <xsl:attribute name="data-src">
                                                <xsl:text>holder.js/100%x</xsl:text>
                                                <xsl:value-of select="$thumbnail.maxheight"/>
                                                <xsl:text>/text:No Thumbnail</xsl:text>
                                            </xsl:attribute>
                                        </img-->
                                    </xsl:otherwise>
                                </xsl:choose>
                            </a>
                        </xsl:otherwise>
                    </xsl:choose>
                    </div>
            </div>

            <div class="col-xs-6 col-sm-5">
                <dl class="file-metadata dl-horizontal">
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:attribute name="title">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        </xsl:attribute>
                        <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:title, 30, 5)"/>
                    </dd>
                <!-- File size always comes in bytes and thus needs conversion -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:choose>
                            <xsl:when test="@SIZE &lt; 1024">
                                <xsl:value-of select="@SIZE"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                <!-- Lookup File Type description in local messages.xml based on MIME Type.
         In the original DSpace, this would get resolved to an application via
         the Bitstream Registry, but we are constrained by the capabilities of METS
         and can't really pass that info through. -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains(@MIMETYPE,';')">
                                <xsl:value-of select="substring-before(substring-after(@MIMETYPE,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:with-param>
                        </xsl:call-template>
                    </dd>
                <!-- Display the contents of 'Description' only if bitstream contains a description -->
                <xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
                        <dt>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text>
                            <xsl:text>:</xsl:text>
                        </dt>
                        <dd class="word-break">
                            <xsl:attribute name="title">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            </xsl:attribute>
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            <!--xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:label, 30, 5)"/-->
                        </dd>
                </xsl:if>
                </dl>
            </div>

            <div class="file-link col-xs-6 col-xs-offset-6 col-sm-2 col-sm-offset-0">
                <xsl:choose>
                    <xsl:when test="@ADMID">
                        <xsl:call-template name="display-rights"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="view-open"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>

</xsl:template>

    <xsl:template name="view-open">
        <xsl:param name="context" select="."/>
           <xsl:variable name="repositoryURL" select="dri:document/dri:meta/dri:pageMeta/dri:trail[1]/@target"/>
           <xsl:variable name="bitstreamurl1" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
           <xsl:variable name="bitstreamurl" select="substring-before($bitstreamurl1, '&amp;isAllowed')"/>
           <xsl:variable name="streamingfilename">
               <xsl:value-of select="@ID"/>_<xsl:value-of select="mets:FLocat/@xlink:title"/>
           </xsl:variable>

        <xsl:choose>
            <xsl:when test="(@MIMETYPE='audio/x-mp3') or (@MIMETYPE='video/mp4') or (@MIMETYPE='video/m4v')">
                 <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$baseURL"/>/streaming/<xsl:value-of select="$streamingfilename"/>
                    </xsl:attribute>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                 </a>
            </xsl:when>
            <xsl:when test="(@MIMETYPE='ohms/xml')">
                 <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$baseURL"/>/ohms/viewer.php?cachefile=<xsl:value-of select="$streamingfilename"/>
                    </xsl:attribute>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                 </a>
            </xsl:when>
            <xsl:otherwise>
                <a>
                    <xsl:attribute name="href">
                    <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                    </xsl:attribute>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="simple-item-record-rows">

    <!--                    <xsl:call-template name="itemSummaryView-DIM-URI"/-->
                        <xsl:call-template name="itemSummaryView-DIM-alternative-title"/>
                        <!--xsl:call-template name="itemSummaryView-DIM-subtitle"/-->
                        <xsl:call-template name="itemSummaryView-DIM-authors"/>
                        <xsl:call-template name="itemSummaryView-DIM-architect"/>
                        <xsl:call-template name="itemSummaryView-DIM-illustrator"/>
                        <xsl:call-template name="itemSummaryView-DIM-photographer"/>
                        <xsl:call-template name="itemSummaryView-DIM-performer"/>
                        <xsl:call-template name="itemSummaryView-DIM-translator"/>
                        <xsl:call-template name="itemSummaryView-DIM-date"/>
                        <xsl:call-template name="itemSummaryView-DIM-abstract"/>
                        <xsl:call-template name="itemSummaryView-DIM-description"/>
                        <xsl:call-template name="itemSummaryView-DIM-citation"/>
                        <xsl:call-template name="itemSummaryView-DIM-doi"/>
                        <xsl:call-template name="itemSummaryView-DIM-subject"/>
                        <xsl:call-template name="itemSummaryView-DIM-type"/>
                        <xsl:call-template name="itemSummaryView-DIM-publisher"/>
                        <xsl:call-template name="itemSummaryView-DIM-department"/>
                        <xsl:call-template name="itemSummaryView-DIM-Related-Work"/>
                        <xsl:call-template name="itemSummaryView-DIM-URI"/>
                        <xsl:call-template name="itemSummaryView-DIM-rights"/>
                        <xsl:call-template name="itemSummaryView-DIM-relation-URI"/>
                        <xsl:if test="$ds_item_view_toggle_url != ''">
                            <xsl:call-template name="itemSummaryView-show-full"/>
                        </xsl:if>
                        <xsl:call-template name="itemSummaryView-collections"/>
</xsl:template>

    <xsl:template name="itemSummaryView-DIM-relation-URI">
        <xsl:if test="dim:field[@element='relation' and @qualifier='uri' and descendant::text()]">
            <div class="simple-item-view-uri item-page-field-wrapper table">
                <h5><i18n:text>xmlui.Rice.relation-uri</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='relation' and @qualifier='uri']">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:copy-of select="./node()"/>
                            </xsl:attribute>
                            <xsl:copy-of select="./node()"/>
                        </a>
                        <xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='uri']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-Related-Work">
        <xsl:if test="dim:field[@element='relation'][@qualifier='HasPart' and descendant::text()]">
            <div class="simple-item-view-architect item-page-field-wrapper table">
                <h5><i18n:text>xmlui.Rice.related-work</i18n:text></h5>
                <xsl:for-each select="dim:field[@element='relation' and @qualifier='HasPart']">
                    <xsl:copy-of select="./node()"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='HasPart']) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </div>
        </xsl:if>
        <xsl:if test="dim:field[@element='relation' and not(@qualifier) and descendant::text()]">
        <div class="simple-item-view-architect item-page-field-wrapper table">
        <h5><i18n:text>xmlui.Rice.related-work</i18n:text></h5>
                <xsl:for-each select="dim:field[@element='relation' and not(@qualifier)]">
                    <xsl:copy-of select="./node()"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='relation' and not(@qualifier)]) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
        </xsl:if>
        <xsl:if test="dim:field[@element='relation'][@qualifier='IsPartOfSeries' and descendant::text()]">
            <div class="simple-item-view-architect item-page-field-wrapper table">
            <h5><i18n:text>xmlui.Rice.related-work</i18n:text></h5>
                <xsl:for-each select="dim:field[@element='relation' and @qualifier='IsPartOfSeries']">
                    <xsl:copy-of select="./node()"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='IsPartOfSeries']) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
        </xsl:if>
        <xsl:if test="dim:field[@element='relation'][@qualifier='IsReferencedBy' and descendant::text()]">
            <div class="simple-item-view-architect item-page-field-wrapper table">
            <h5><i18n:text>xmlui.Rice.related-work</i18n:text></h5>
                <xsl:for-each select="dim:field[@element='relation' and @qualifier='IsReferencedBy']">
                    <xsl:copy-of select="./node()"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='IsReferencedBy']) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
        </xsl:if>
        <xsl:if test="dim:field[@element='relation'][@qualifier='IsPartOf' and descendant::text()]">
            <div class="simple-item-view-architect item-page-field-wrapper table">
            <h5><i18n:text>xmlui.Rice.related-work</i18n:text></h5>
                <xsl:for-each select="dim:field[@element='relation' and @qualifier='IsPartOf']">
                    <xsl:copy-of select="./node()"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='IsPartOf']) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-URI">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='uri' and descendant::text()]">
            <div class="simple-item-view-uri item-page-field-wrapper table">
                <h5><i18n:text>xmlui.Rice.uri</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:copy-of select="./node()"/>
                            </xsl:attribute>
                            <xsl:copy-of select="./node()"/>
                        </a>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template name="itemSummaryView-DIM-rights">
    <xsl:if test="dim:field[@element='rights' and not(@qualifier)]">
        <div class="simple-item-view-rights item-page-field-wrapper table">
            <h5><i18n:text>xmlui.Rice.rights</i18n:text></h5>
            <span>
                <xsl:for-each select="dim:field[@element='rights' and not(@qualifier)]">
                    <xsl:choose>
                        <xsl:when test="(contains(.,'http://') or contains(.,'https://') )">
                            <xsl:call-template name="makeLinkFromText"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."></xsl:value-of><xsl:text> </xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!--xsl:copy-of select="./node()"/-->
                </xsl:for-each>
            </span>
        </div>
    </xsl:if>
        <xsl:if test="dim:field[@element='rights' and @qualifier='uri']">
            <div class="simple-item-view-rights item-page-field-wrapper table">
                <h5><i18n:text>xmlui.Rice.rights.uri</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='rights' and @qualifier='uri']">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:copy-of select="./node()"/>
                        </xsl:attribute>
                        <xsl:copy-of select="./node()"/>
                    </a>
                    <xsl:if test="count(following-sibling::dim:field[@element='rights' and @qualifier='uri']) != 0">
                        <br/>
                    </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
</xsl:template>
    <xsl:template name="itemSummaryView-DIM-authors">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='author' and descendant::text()] or dim:field[@element='creator' and descendant::text()]">
            <div class="simple-item-view-authors item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text></h5>
                <xsl:choose>
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                            <div>
                                <xsl:if test="@authority">
                                    <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                </xsl:if>
                                <xsl:copy-of select="node()"/>
                            </div>
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
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-architect">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='architect' and descendant::text()]">
            <div class="simple-item-view-architect item-page-field-wrapper table">
                <h5><i18n:text>xmlui.Rice.architect</i18n:text></h5>
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='architect']">
                            <div>
                                <xsl:if test="@authority">
                                    <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                </xsl:if>
                                <xsl:copy-of select="node()"/>
                            </div>
                        </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-funder">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='funder' and descendant::text()]">
            <div class="simple-item-view-funder item-page-field-wrapper table">
                <h5><i18n:text>xmlui.Rice.funder</i18n:text></h5>
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='funder']">
                            <div>
                                <xsl:if test="@authority">
                                    <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                </xsl:if>
                                <xsl:copy-of select="node()"/>
                            </div>
                        </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-illustrator">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='illustrator' and descendant::text()]">
            <div class="simple-item-view-illustrator item-page-field-wrapper table">
                <h5><i18n:text>xmlui.Rice.illustrator</i18n:text></h5>
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='illustrator']">
                            <div>
                                <xsl:if test="@authority">
                                    <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                </xsl:if>
                                <xsl:copy-of select="node()"/>
                            </div>
                        </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-photographer">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='photographer' and descendant::text()]">
            <div class="simple-item-view-photographer item-page-field-wrapper table">
                <h5><i18n:text>xmlui.Rice.photographer</i18n:text></h5>
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='photographer']">
                            <div>
                                <xsl:if test="@authority">
                                    <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                </xsl:if>
                                <xsl:copy-of select="node()"/>
                            </div>
                        </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

     <xsl:template name="itemSummaryView-DIM-citation">
          <xsl:if test="dim:field[@element='identifier'][@qualifier='citation']">
              <div class="simple-item-view-citation item-page-field-wrapper table">
              <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-citation</i18n:text></h5>
                  <div>
                      <xsl:copy>
                          <xsl:call-template name="parse">
                              <xsl:with-param name="str" select="dim:field[@element='identifier'][@qualifier='citation'][1]/node()"/>
                              <xsl:with-param name="omit-link" select="1"/>
                          </xsl:call-template>
                      </xsl:copy>
                  </div>
              </div>
          </xsl:if>
      </xsl:template>
      <!--xsl:template name="itemSummaryView-DIM-doi">
          <xsl:if test="dim:field[@element='identifier' and @qualifier='doi']">
          <div class="simple-item-view-doi item-page-field-wrapper table">
              <h5><i18n:text>xmlui.Rice.doi</i18n:text></h5>
                  <div>
                      <xsl:for-each select="dim:field[@element='identifier' and @qualifier='doi']">
                          <a>
                               <xsl:attribute name="href">
                                        <xsl:text>http://dx.doi.org/</xsl:text><xsl:copy-of select="./node()"/>
                                    </xsl:attribute>
                          <xsl:text>doi:</xsl:text><xsl:copy-of select="./node()"/>
                          </a>
                          <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='doi']) != 0">
                              <br/>
                          </xsl:if>

                      </xsl:for-each>
                  </div>
              </div>
          </xsl:if>
      </xsl:template-->

    <xsl:template name="itemSummaryView-DIM-doi">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='doi']">
        <div class="simple-item-view-doi item-page-field-wrapper table">
            <h5><i18n:text>xmlui.Rice.doi</i18n:text></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='doi']">
                        <a>
                             <xsl:attribute name="href">
                                      <xsl:copy-of select="./node()"/>
                                  </xsl:attribute>
                        <xsl:copy-of select="./node()"/>
                        </a>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='doi']) != 0">
                            <br/>
                        </xsl:if>

                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- 'Series' row in simple item record -->
    <xsl:template name="itemSummaryView-DIM-series">
        <xsl:if test="dim:field[@element='relation' and @qualifier='ispartofseries']">
            <div class="simple-item-view-series item-page-field-wrapper table">
            <h5><i18n:text>xmlui.ArtifactBrowser.AdvancedSearch.type_series</i18n:text></h5>
                     <xsl:for-each select="dim:field[@element='relation' and @qualifier='ispartofseries']">
                         <xsl:copy-of select="./node()"/>
                         <xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='ispartofseries']) != 0">
                             <br/>
                         </xsl:if>
                     </xsl:for-each>
            </div>
         </xsl:if>
    </xsl:template>


     <!-- 'Issue' row in simple item record -->
     <xsl:template name="itemSummaryView-DIM-issue">
         <xsl:variable name="query_string" select="$document/dri:meta/dri:pageMeta/dri:metadata[@element='search' and @qualifier='queryField']"/>
         <xsl:variable name="context_path" select="$document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>
         <xsl:variable name="collection_handle" select="substring-after($document/dri:meta/dri:pageMeta/dri:metadata[@element='focus' and @qualifier='container'], ':')"/>
         <xsl:variable name="num" select="dim:field[@element='citation' and @qualifier='issueNumber']"/>
         <xsl:variable name="vol" select="dim:field[@element='citation' and @qualifier='volumeNumber']"/>
         <xsl:if test="dim:field[@element='relation' and @qualifier='ispartofseries']">
             <div class="simple-item-view-issue item-page-field-wrapper table">

                     <xsl:choose>
                         <xsl:when test="contains($num, 'Special Issue') ">
                                 <h5><i18n:text>xmlui.Periodicals.Issue</i18n:text>:</h5>
                             <div>
                                     <a href="{$context_path}/handle/{$collection_handle}/search?{$query_string}=series%3A%28%22Volume+{$vol}%2C+,%20+{$num}%22+-%22Page%22%29">Issue <xsl:value-of select="$num"/></a>
                             </div>
                         </xsl:when>
                         <xsl:when test="contains($num, 'Supplement')">

                         </xsl:when>
                         <xsl:otherwise>
                                  <h5><i18n:text>xmlui.Periodicals.Issue</i18n:text>:</h5>
                             <div>
                                     Issue <xsl:value-of select='$num'/>
                                 </div>
                         </xsl:otherwise>
                     </xsl:choose>
             </div>
         </xsl:if>
     </xsl:template>


  <!--      <xsl:template name="itemSummaryView-DIM-subject-keyword">
          <xsl:if test="dim:field[@element='subject'][@qualifier='keyword']">
          <div class="simple-item-view-keyword item-page-field-wrapper table">
              <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-keyword</i18n:text></h5>
                  <div>
                      <xsl:if test="count(following-sibling::dim:field[@element='subject'][@qualifier='keyword']) >= 5">
                          <xsl:for-each select="dim:field[@element='subject'][@qualifier='keyword']">
                          <xsl:if test="position() &lt;= 5">
                              <span>
                                  <xsl:copy-of select="node()"/>
                              </span>
                              <xsl:text>; </xsl:text>
                          </xsl:if>
                      </xsl:for-each>
                      <span class="show-hide" style="display: none;">
                          <xsl:text>[ </xsl:text>
                          <span class="show"><i18n:text>xmlui.Periodicals.show</i18n:text></span>
                          <span class="hide" style="display: none;"><i18n:text>xmlui.Periodicals.hide</i18n:text></span>
                          <xsl:text> ]</xsl:text>
                      </span>

                       <div class="hiddenfield">

                          <span class="hiddenvalue">
                          <xsl:for-each select="dim:field[@element='subject'][@qualifier='keyword']">
                          <xsl:if test="position() >= 5">
                                  <xsl:copy-of select="node()"/>
                              <xsl:text>; </xsl:text>
                          </xsl:if>
                          </xsl:for-each>
                          </span>
                       </div>
                  </xsl:if>
                      <xsl:if test="count(following-sibling::dim:field[@element='subject'][@qualifier='keyword']) &lt;= 5">
                                              <xsl:for-each select="dim:field[@element='subject'][@qualifier='keyword']">
                                                  <span>
                                                      <xsl:copy-of select="node()"/>
                                                  </span>
                                                  <xsl:text>; </xsl:text>
                                          </xsl:for-each>
                      </xsl:if>

                          </div>
              </div>
          </xsl:if>
      </xsl:template>-->

    <xsl:template name="itemSummaryView-DIM-date-recorded">
         <xsl:if test="dim:field[@element='date' and @qualifier='created']">
             <div class="simple-item-view-date-recorded item-page-field-wrapper table">
                 <h5><i18n:text>xmlui.Shepherd.Daterecorded</i18n:text></h5>
                 <div>
                     <xsl:for-each select="dim:field[@element='date' and @qualifier='created']">
                           <xsl:call-template name="displayDate">
                               <xsl:with-param name="iso" select="./node()"/>
                           </xsl:call-template>
                           <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='created']) != 0">
                               <br/>
                           </xsl:if>
                       </xsl:for-each>
                   </div>
             </div>
          </xsl:if>
     </xsl:template>

      <xsl:template name="itemSummaryView-DIM-subject">
          <xsl:if test="dim:field[@element='subject']">
          <div class="simple-item-view-keyword item-page-field-wrapper table">
              <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-keyword</i18n:text></h5>
                  <div>

                      <xsl:variable name="cc" select="count(dim:field[@element='subject']/node())" />

                      <xsl:if test="$cc != 0">
                          <xsl:for-each select="dim:field[@element='subject']">
                          <xsl:if test="position() &lt;= 5">
                              <span>

                                  <xsl:copy-of select="node()"/>
                              <xsl:if test="position()!=last() ">
                                   <xsl:text>; </xsl:text>
                              </xsl:if>
                              </span>
                           </xsl:if>

                          </xsl:for-each>

                      <xsl:if test="$cc &gt; 5">
                                 <a class="showHide"
                                     data-toggle="collapse"
                                     data-target="#mk"
                                         onclick="$('.showHide').toggle();"> More... </a>

                            <span id="mk" class="collapse">
                                <xsl:for-each select="dim:field[@element='subject']">

                                    <xsl:if test="position() &gt; 5 ">
                                    <xsl:copy-of select="node()"/>

                                    <xsl:if test="position()!=last() ">
                                            <xsl:text>; </xsl:text>
                                       </xsl:if>
                                    </xsl:if>
                                </xsl:for-each>

                                 <a class=" showHide"
                                       style="display:none"
                                     data-toggle="collapse"
                                     data-target="#mk"
                                         onclick="$('.showHide').toggle();"> Less... </a>
                     </span>
                         </xsl:if>

                  </xsl:if>
                </div>
          </div>
        </xsl:if>

      </xsl:template>

    <xsl:template name="itemSummaryView-DIM-abstract">
         <xsl:if test="dim:field[@element='description' and @qualifier='abstract']">
             <div class="simple-item-view-description item-page-field-wrapper table">
                 <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text></h5>
                 <div>

                     <xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
                         <xsl:choose>
                             <xsl:when test="(contains(.,'http://') or contains(.,'https://') )">
                                <xsl:call-template name="makeLinkFromText"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."></xsl:value-of><xsl:text> </xsl:text>
                            </xsl:otherwise>
                         </xsl:choose>
                         <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
                             <div class="spacer">&#160;</div>
                         </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                         <div class="spacer">&#160;</div>
                     </xsl:if>
                 </div>
             </div>
         </xsl:if>
     </xsl:template>

    <xsl:template name="itemSummaryView-DIM-subject-keyword">
         <xsl:if test="dim:field[@element='subject' and @qualifier='keyword']">
             <div class="simple-item-view-subject-keyword item-page-field-wrapper table">
                 <h5><i18n:text>xmlui.Rice.Subject.Keywords</i18n:text></h5>
                 <div>
                     <xsl:for-each select="dim:field[@element='subject' and @qualifier='keyword']">
                         <xsl:value-of select="."/>
                         <xsl:if test="count(following-sibling::dim:field[@element='subject' and @qualifier='keyword']) != 0">
                             <xsl:text>; </xsl:text>
                         </xsl:if>
                     </xsl:for-each>
                 </div>
             </div>
         </xsl:if>
     </xsl:template>

    <xsl:template name="itemSummaryView-DIM-translator">
         <xsl:if test="dim:field[@element='contributor' and @qualifier='translator']">
             <div class="simple-item-view-performer item-page-field-wrapper table">
                 <h5><i18n:text>xmlui.Rice.Translator</i18n:text></h5>
                 <div>
                     <xsl:for-each select="dim:field[@element='contributor'][@qualifier='translator']">
                         <xsl:copy-of select="node()"/>
                         <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='translator']) != 0">
                             <xsl:text>; </xsl:text>
                         </xsl:if>
                      </xsl:for-each>
                  </div>
             </div>
          </xsl:if>
     </xsl:template>

    <xsl:template name="itemSummaryView-DIM-publisher">
         <xsl:if test="dim:field[@element='publisher' and not(@qualifier)]">
             <div class="simple-item-view-publisher item-page-field-wrapper table">
                 <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-publisher</i18n:text></h5>
                 <div>
                     <xsl:copy>
                         <xsl:call-template name="parse">
                             <xsl:with-param name="str" select="dim:field[@element='publisher' and not(@qualifier)][1]/node()"/>
                         </xsl:call-template>
                     </xsl:copy>
                 </div>
             </div>
         </xsl:if>
     </xsl:template>

        <xsl:template name="itemSummaryView-DIM-department">
         <xsl:if test="dim:field[@schema='thesis' and @element='degree' and @qualifier='department']">
             <div class="simple-item-view-department item-page-field-wrapper table">
                 <h5><i18n:text>xmlui.Rice.department</i18n:text></h5>
                 <div>
                     <xsl:copy>
                         <xsl:call-template name="parse">
                             <xsl:with-param name="str" select="dim:field[@schema='thesis' and @element='degree' and @qualifier='department']/node()"/>
                         </xsl:call-template>
                     </xsl:copy>
                 </div>
             </div>
         </xsl:if>
     </xsl:template>

    <xsl:template name="itemSummaryView-DIM-description">
         <xsl:if test="dim:field[@element='description' and not(@qualifier)][1]/node()">
             <div class="simple-item-view-description item-page-field-wrapper table">
                 <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-description</i18n:text></h5>
                 <div>
                     <xsl:for-each select="dim:field[@element='description' and not(@qualifier)]">
                        <xsl:choose>
                            <xsl:when test="(contains(.,'http://') or contains(.,'https://') )">
                                <xsl:call-template name="makeLinkFromText"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."></xsl:value-of><xsl:text> </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                     </xsl:for-each>
                 </div>
             </div>
         </xsl:if>
     </xsl:template>

    <xsl:template name="itemSummaryView-DIM-type">
         <xsl:if test="dim:field[@element='type' and not(@qualifier)]/child::node()">
             <div class="simple-item-view-type item-page-field-wrapper table">
                 <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-type</i18n:text></h5>
                 <div>
                     <xsl:copy-of select="dim:field[@element='type' and not(@qualifier)]/child::node()"/>
                 </div>
             </div>
         </xsl:if>
     </xsl:template>

    <xsl:template name="itemSummaryView-DIM-description-center">
         <xsl:if test="dim:field[@element='description' and @qualifier='center']">
             <div class="simple-item-view-description-center item-page-field-wrapper table">
                 <h5><i18n:text>xmlui.Rice.Description.Center</i18n:text></h5>
                 <div>
        <xsl:if test="dim:field[@element='description' and @qualifier='center']">
            <xsl:variable name="dim" select="."/>
            <tr class="ds-table-row">
                <th><span class="bold"><i18n:text>xmlui.Rice_ECE.Center</i18n:text>:</span></th>
                <td>
                    <xsl:for-each select="dim:field[@element='description' and @qualifier='center']">
                        <xsl:variable name="center" select="." />
                        <xsl:choose>
                            <xsl:when test="contains($center, '(')">
                                <a>
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="substring-before(substring-after($center, ' ('), ')')"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="substring-before($center, ' (')"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <!-- Ying (via MMS): if Center==DSP, include DSP subcategory -->
                        <xsl:if test="contains($center, 'DSP') and $dim/dim:field[@element='subject' and @qualifier='other']">
                            <xsl:text> (</xsl:text>
                            <!-- i18n: Subcategory: -->
                            <i18n:text>xmlui.Rice_ECE.Subcategory</i18n:text>
                            <xsl:text> </xsl:text>
                            <xsl:for-each select="$dim/dim:field[@element='subject' and @qualifier='other']">
                                <xsl:copy-of select="."/>
                                <xsl:if test="count(following-sibling::dim:field[@element='subject' and @qualifier='other']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                        <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='center']) != 0">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
        </xsl:if>
                 </div>
             </div>
         </xsl:if>
     </xsl:template>
    <xsl:template name="itemSummaryView-DIM-alternative-title">
      <xsl:if test="dim:field[@element='title' and @qualifier='alternative']">
          <div class="simple-item-view-alternative-title item-page-field-wrapper table">
              <h5><i18n:text>xmlui.Rice.Alttitle</i18n:text></h5>
              <div>
                  <xsl:copy-of select="dim:field[@element='title'][@qualifier='alternative']"/>
              </div>
          </div>
      </xsl:if>
  </xsl:template>

    <xsl:template name="itemSummaryView-DIM-date">
        <xsl:choose>

            <xsl:when test="dim:field[@element='date' and @qualifier='note' and descendant::text()]">
                <div class="simple-item-view-date word-break item-page-field-wrapper table">
                    <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>
                    </h5>
                    <xsl:for-each select="dim:field[@element='date' and @qualifier='note']">
                        <xsl:copy-of select="node()"/>
                        <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='note']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </div>
            </xsl:when>
            <xsl:when test="dim:field[@element='date' and @qualifier='original' and descendant::text()]">
                <div class="simple-item-view-date word-break item-page-field-wrapper table">
                    <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>
                    </h5>
                    <xsl:for-each select="dim:field[@element='date' and @qualifier='original']">
                        <xsl:copy-of select="node()"/>
                        <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='original']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </div>
            </xsl:when>
            <xsl:when test="dim:field[@element='date' and @qualifier='issued' and descendant::text()]">
                <div class="simple-item-view-date word-break item-page-field-wrapper table">
                    <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>
                    </h5>
                    <xsl:for-each select="dim:field[@element='date' and @qualifier='issued']">
                        <xsl:copy-of select="substring(./node(),1,10)"/>
                        <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='issued']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </div>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-format-extent">
      <xsl:if test="dim:field[@element='format' and @qualifier='extent']">
          <div class="simple-item-view-format-extent item-page-field-wrapper table">
              <h5><i18n:text>xmlui.Rice.FormatExtent</i18n:text></h5>
              <div>
                  <xsl:copy-of select="dim:field[@element='format'][@qualifier='extent']"/>
              </div>
          </div>
      </xsl:if>
  </xsl:template>

    <xsl:template name="itemSummaryView-DIM-inventor">
      <xsl:if test="dim:field[@element='creator']">
          <div class="simple-item-inventor item-page-field-wrapper table">
              <h5><i18n:text>xmlui.Rice.Inventor</i18n:text></h5>
              <div>
                  <xsl:copy-of select="dim:field[@element='creator']"/>
              </div>
          </div>
      </xsl:if>
  </xsl:template>

        <xsl:template name="itemSummaryView-DIM-subtitle">
      <xsl:if test="dim:field[@element='title' and @qualifier='subtitle']">
          <div class="simple-item-view-subtitle item-page-field-wrapper table">
              <h5><i18n:text>xmlui.Rice.Subtitle</i18n:text></h5>
              <div>
                  <xsl:copy-of select="dim:field[@element='title'][@qualifier='subtitle']"/>
              </div>
          </div>
      </xsl:if>
  </xsl:template>

 <xsl:template name="itemSummaryView-DIM-subject-lcsh">
     <xsl:if test="dim:field[@element='subject' and @qualifier='lcsh']">
         <div class="simple-item-view-subject-lcsh item-page-field-wrapper table">
             <h5><i18n:text>xmlui.Rice.Subject.LCSH</i18n:text></h5>
             <div>
                 <xsl:for-each select="dim:field[@element='subject'][@qualifier='lcsh']">
                      <xsl:copy-of select="."/>
                      <xsl:if test="following::dim:field[@element='subject'][@qualifier='lcsh']">
                          <br/>
                      </xsl:if>
                  </xsl:for-each>
                </div>
         </div>
      </xsl:if>
 </xsl:template>

    <!-- 'composer' row in simple item record -->
     <xsl:template name="itemSummaryView-DIM-composer">
         <xsl:if test="dim:field[@element='contributor' and @qualifier='composer']">
             <div class="simple-item-view-composer item-page-field-wrapper table">
                 <xsl:choose>
                      <xsl:when test="count(dim:field[@element='contributor'][@qualifier='composer']) &gt; 0">
                          <!-- i18n: Composers -->
                          <h5><i18n:text>xmlui.Shepherd.Composers</i18n:text></h5>
                      </xsl:when>
                      <xsl:otherwise>
                          <!-- i18n: Composer -->
                          <h5><i18n:text>xmlui.Shepherd.Composer</i18n:text></h5>
                      </xsl:otherwise>
                  </xsl:choose>
                 <div>
                   <xsl:for-each select="dim:field[@element='contributor'][@qualifier='composer']">
                      <xsl:copy-of select="node()"/>
                      <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='composer']) != 0">
                          <xsl:text>; </xsl:text>
                      </xsl:if>
                   </xsl:for-each>
                 </div>
             </div>
          </xsl:if>
     </xsl:template>



    <!-- Ying (via MMS): 'Advisor' row in simple item record -->
    <xsl:template name="itemSummaryView-DIM-advisor">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='advisor']">
             <div class="simple-item-view-advisor item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-advisor</i18n:text></h5>
                <div>
                   <xsl:for-each select="dim:field[@element='contributor'][@qualifier='advisor']">
                        <xsl:copy-of select="node()"/>
                        <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='advisor']) != 0">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <!-- Ying (via MMS): 'Degree' row in simple item record -->
    <xsl:template name="itemSummaryView-DIM-degree">
        <xsl:if test="dim:field[@element='degree'][@qualifier='name']">
              <div class="simple-item-view-degree item-page-field-wrapper table">
                 <h5><i18n:text>xmlui.Rice_ETD.Degree</i18n:text></h5>
                 <div>
                    <xsl:for-each select="dim:field[@element='degree' and @qualifier='name']">
                        <xsl:copy-of select="./node()"/>

                        <xsl:if test="count(following-sibling::dim:field[@element='degree' and @qualifier='name']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>


     <!-- 'Preformed by' row in simple item record -->
     <xsl:template name="itemSummaryView-DIM-performer">
         <xsl:if test="dim:field[@element='contributor' and @qualifier='performer']">
             <div class="simple-item-view-performer item-page-field-wrapper table">
                 <h5><i18n:text>xmlui.Shepherd.Performedby</i18n:text></h5>
                 <div>

                     <xsl:variable name="cc" select="count(dim:field[@element='contributor' and @qualifier='performer']/node())" />

                     <xsl:if test="$cc != 0">
                         <xsl:for-each select="dim:field[@element='contributor' and @qualifier='performer']">
                             <xsl:if test="position() &lt;= 5">
                                 <span>

                                     <xsl:copy-of select="node()"/>
                                     <xsl:if test="position()!=last() ">
                                         <xsl:text>; </xsl:text>
                                     </xsl:if>
                                 </span>
                             </xsl:if>

                         </xsl:for-each>

                         <xsl:if test="$cc &gt; 5">
                             <a class="showHide"
                                data-toggle="collapse"
                                data-target="#mk"
                                onclick="$('.showHide').toggle();"> More... </a>

                             <span id="mk" class="collapse">
                                 <xsl:for-each select="dim:field[@element='contributor' and @qualifier='performer']">

                                     <xsl:if test="position() &gt; 5 ">
                                         <xsl:copy-of select="node()"/>

                                         <xsl:if test="position()!=last() ">
                                             <xsl:text>; </xsl:text>
                                         </xsl:if>
                                     </xsl:if>
                                 </xsl:for-each>

                                 <a class=" showHide"
                                    style="display:none"
                                    data-toggle="collapse"
                                    data-target="#mk"
                                    onclick="$('.showHide').toggle();"> Less... </a>
                             </span>
                         </xsl:if>

                     </xsl:if>
                 </div>
                 <!--div>
                   <xsl:for-each select="dim:field[@element='contributor'][@qualifier='performer']">
                                 <xsl:copy-of select="node()"/>
                                 <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='performer']) != 0">
                                     <br />
                                 </xsl:if>
                     </xsl:for-each>
                 </div-->
             </div>
          </xsl:if>
     </xsl:template>

     <xsl:template name="itemSummaryView-DIM-performance-type">
         <xsl:if test="dim:field[@element='subject' and @qualifier='performancetype']">
             <div class="simple-item-view-performance-type item-page-field-wrapper table">
                 <h5><i18n:text>xmlui.Shepherd.Performancetype</i18n:text></h5>
                 <div>
                   <xsl:for-each select="dim:field[@element='contributor'][@qualifier='performer']">
                     <xsl:choose>
                         <xsl:when test="dim:field[@element='subject'][@qualifier='performancetype']">
                             <xsl:for-each select="dim:field[@element='subject'][@qualifier='performancetype']">
                                 <xsl:copy-of select="node()"/>
                                 <xsl:if test="count(following-sibling::dim:field[@element='subject'][@qualifier='performancetype']) != 0">
                                     <xsl:text>; </xsl:text>
                                 </xsl:if>
                             </xsl:for-each>
                         </xsl:when>
                         <xsl:otherwise>
                             <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                         </xsl:otherwise>
                     </xsl:choose>
                     </xsl:for-each>
                 </div>
             </div>
          </xsl:if>
     </xsl:template>

    <xsl:template name="itemSummaryView-DIM-relation-ispartof">
        <xsl:if test="dim:field[@element='relation' and @qualifier='ispartof']">
            <div class="simple-item-view-relation-ispartof item-page-field-wrapper table">
                <h5><i18n:text>xmlui.Rice.isPartOf</i18n:text></h5>
                <div>
                     <xsl:for-each select="dim:field[@element='relation' and @qualifier='ispartof']">
                        <xsl:copy-of select="node()"/>
                     </xsl:for-each>
                </div>
            </div>
         </xsl:if>
    </xsl:template>

    <xsl:template name="displayDate">
         <xsl:param name="iso"/>
         <xsl:variable name="firstChar" select="substring($iso,1,1)" />
         <xsl:choose>
             <xsl:when test="$firstChar = '-'">
                 <xsl:call-template name="displayDate">
                     <xsl:with-param name="iso">
                         <xsl:value-of select="number(substring-before(substring(concat($iso,'-'),2),'-'))+1"/>
                         <xsl:if test="substring-after(substring($iso,2),'-') != ''">
                             <xsl:text>-</xsl:text>
                             <xsl:value-of select="substring-after(substring($iso,2),'-')"/>
                         </xsl:if>
                     </xsl:with-param>
                 </xsl:call-template>
                 <xsl:text> BCE</xsl:text>
             </xsl:when>
             <xsl:when test="$firstChar = '0'">
                 <xsl:call-template name="displayDate">
                     <xsl:with-param name="iso" select="substring($iso,2)"/>
                 </xsl:call-template>
             </xsl:when>
             <xsl:otherwise>
                 <xsl:value-of select="substring($iso,1,10)"/>
             </xsl:otherwise>
         </xsl:choose>
     </xsl:template>


    <!-- ============================================
              Item record page (full record table)
         ============================================ -->
    
    <!-- MMS: copied from DIM-Handler.xsl for special handling of certain fields in the "Full item record" table, and for removal of the language column. 
         Like fields are combined under a single header instead of of each getting their own row, since the tables were getting too tall.  
         Remove odd/even class determination (let JS do that instead). -->
    <xsl:template match="dim:field" mode="itemDetailView-DIM">
        <!-- Ying: Set field name as a variable for easy retrieval in tests below. -->
        <xsl:variable name="metadatafieldname">
            <xsl:value-of select="./@mdschema"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="./@element"/>
            <xsl:if test="./@qualifier">
                <xsl:text>.</xsl:text>
                <xsl:value-of select="./@qualifier"/>
            </xsl:if>
        </xsl:variable>
        <xsl:choose>
            <!-- Ying (via MMS): If this is the provenance field, set classes that make its value initially hidden, but expandable with JS on -->
            <xsl:when test="$metadatafieldname='dc.description.provenance'">
                <tr class="ds-table-row">
                    <th>
                        <div class="hiddenfield">
                            <xsl:copy-of select="$metadatafieldname" />
                        </div>
                    </th>
                    <td>
                        <div class="hiddenvalue">
                            <xsl:copy-of select="./node()"/>
                            <!--xsl:if test="./@authority and ./@confidence">
                                <xsl:call-template name="authorityConfidenceIcon">
                                    <xsl:with-param name="confidence" select="./@confidence"/>
                                </xsl:call-template>
                            </xsl:if-->
                        </div>
                    </td>
                </tr>
            </xsl:when>
            <!-- Ying (via MMS): If this field is a URL, turn it into a link -->
            <xsl:when test="$metadatafieldname='dc.rights.uri' or $metadatafieldname='dc.identifier.uri' or $metadatafieldname='dc.relations'">
                <tr class="ds-table-row">
                    <th>
                        <xsl:copy-of select="$metadatafieldname" />
                    </th>
                    <td>
                        <a>
                            <xsl:attribute name="href">
                                <xsl:copy-of select="./node()"/>
                            </xsl:attribute>
                            <xsl:copy-of select="./node()"/>
                        </a>
                        <!--xsl:if test="./@authority and ./@confidence">
                            <xsl:call-template name="authorityConfidenceIcon">
                                <xsl:with-param name="confidence" select="./@confidence"/>
                            </xsl:call-template>
                        </xsl:if-->
                    </td>
                </tr>
            </xsl:when>
            <!-- MMS: Put like fields together to take up less space. -->
            <xsl:when test="$metadatafieldname='dc.contributor.author' or 
                            $metadatafieldname='dc.contributor.translator' or 
                            $metadatafieldname='dc.subject.keyword' or 
                            $metadatafieldname='dc.subject.lcsh' or 
                            $metadatafieldname='dc.subject.local' or 
                            $metadatafieldname='dc.subject.other' or 
                            $metadatafieldname='dc.description.funder' or 
                            $metadatafieldname='dc.coverage.spatial' or 
                            $metadatafieldname='dc.identifier.issn'">
                <tr class="ds-table-row">
                    <xsl:if test="not(preceding-sibling::dim:field[@element=current()/@element and @qualifier=current()/@qualifier])">
                        <th>
                            <xsl:copy-of select="$metadatafieldname" />
                        </th>
                        <td>
                            <xsl:for-each select="parent::dim:dim/dim:field[@element=current()/@element and @qualifier=current()/@qualifier]">
                                <xsl:copy-of select="./node()"/>
                                <!--xsl:if test="./@authority and ./@confidence">
                                    <xsl:call-template name="authorityConfidenceIcon">
                                        <xsl:with-param name="confidence" select="./@confidence"/>
                                    </xsl:call-template>
                                </xsl:if-->
                                <br/>
                            </xsl:for-each>
                        </td>
                    </xsl:if>
                </tr>
            </xsl:when>
            <!-- MMS: Put like fields together to take up less space.  These fields separate from the above due to the lack of @qualifier.  -->
            <xsl:when test="$metadatafieldname='dc.creator' or 
                            $metadatafieldname='dc.subject'">
                <xsl:if test="not(preceding-sibling::dim:field[@element=current()/@element and not(@qualifier)])">
                    <th>
                        <xsl:copy-of select="$metadatafieldname" />
                    </th>
                    <td>
                        <xsl:for-each select="parent::dim:dim/dim:field[@element=current()/@element and not(@qualifier)]">
                            <xsl:copy-of select="./node()"/>
                            <!--xsl:if test="./@authority and ./@confidence">
                                <xsl:call-template name="authorityConfidenceIcon">
                                    <xsl:with-param name="confidence" select="./@confidence"/>
                                </xsl:call-template>
                            </xsl:if-->
                            <br/>
                        </xsl:for-each>
                    </td>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <tr class="ds-table-row">
                    <th>
                        <xsl:copy-of select="$metadatafieldname" />
                    </th>
                    <!-- Ying (via MMS): Parse the values in all other fields to determine whether they contain URLs or mark-up. Turn any URLs into links and any mark-up into mark-up. -->
                    <td>
                        <xsl:choose>
                            <xsl:when test="(contains(.,'http://') or contains(.,'https://') ) and $metadatafieldname!='dc.identifier.citation'">
                                <xsl:call-template name="makeLinkFromText"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy>
                                    <xsl:call-template name="parse">
                                        <xsl:with-param name="str" select="./node()"/>
                                        <!-- MMS: Only display link text for citation, don't make it a link. -->
                                        <xsl:with-param name="omit-link">
                                            <xsl:choose>
                                                <xsl:when test="$metadatafieldname='dc.identifier.citation'">1</xsl:when>
                                                <xsl:otherwise>0</xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:copy>
                            </xsl:otherwise>
                        </xsl:choose>
                        <!--xsl:if test="./@authority and ./@confidence">
                            <xsl:call-template name="authorityConfidenceIcon">
                                <xsl:with-param name="confidence" select="./@confidence"/>
                            </xsl:call-template>
                        </xsl:if-->
                    </td>
                </tr>
            </xsl:otherwise>
        </xsl:choose>
        <!-- MMS: Don't output language column. It takes up space and is nearly always 'en' or 'en-US'. -->
    </xsl:template>

    <xsl:template match="dri:document/dri:body/dri:div/dri:div/dri:div[contains(@n,'community-browse') or contains(@n, 'collection-browse')]" priority="1">
     </xsl:template>


    <!-- The HTML head element contains references to CSS as well as embedded JavaScript code. Most of this
information is either user-provided bits of post-processing (as in the case of the JavaScript), or
references to stylesheets pulled directly from the pageMeta element. -->
<xsl:template name="buildHead">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>

        <!-- Use the .htaccess and remove these lines to avoid edge case issues.
         More info: h5bp.com/i/378 -->
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>

        <!-- Mobile viewport optimized: h5bp.com/viewport -->
        <meta name="viewport" content="width=device-width,initial-scale=1"/>

        <link rel="shortcut icon">
            <xsl:attribute name="href">
                <xsl:value-of select="$theme-path"/>
                <xsl:text>images/favicon.ico</xsl:text>
            </xsl:attribute>
        </link>
        <link rel="apple-touch-icon">
            <xsl:attribute name="href">
                <xsl:value-of select="$theme-path"/>
                <xsl:text>images/apple-touch-icon.png</xsl:text>
            </xsl:attribute>
        </link>

        <meta name="Generator">
            <xsl:attribute name="content">
                <xsl:text>DSpace</xsl:text>
                <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']"/>
                </xsl:if>
            </xsl:attribute>
        </meta>

        <!-- Add stylesheets -->

        <!--TODO figure out a way to include these in the concat & minify-->
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='stylesheet']">
            <link rel="stylesheet" type="text/css">
                <xsl:attribute name="media">
                    <xsl:value-of select="@qualifier"/>
                </xsl:attribute>
                <xsl:attribute name="href">
                    <xsl:value-of select="$theme-path"/>
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </link>
        </xsl:for-each>

        <link rel="stylesheet" href="{concat($theme-path, 'styles/main.css')}"/>

        <!-- Add syndication feeds -->
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']">
            <link rel="alternate" type="application">
                <xsl:attribute name="type">
                    <xsl:text>application/</xsl:text>
                    <xsl:value-of select="@qualifier"/>
                </xsl:attribute>
                <xsl:attribute name="href">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </link>
        </xsl:for-each>

        <!--  Add OpenSearch auto-discovery link -->
        <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']">
            <link rel="search" type="application/opensearchdescription+xml">
                <xsl:attribute name="href">
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='scheme']"/>
                    <xsl:text>://</xsl:text>
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName']"/>
                    <xsl:text>:</xsl:text>
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverPort']"/>
                    <xsl:value-of select="$context-path"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='context']"/>
                    <xsl:text>description.xml</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="title" >
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']"/>
                </xsl:attribute>
            </link>
        </xsl:if>

        <!-- The following javascript removes the default text of empty text areas when they are focused on or submitted -->
        <!-- There is also javascript to disable submitting a form when the 'enter' key is pressed. -->
        <script>
            //Clear default text of emty text areas on focus
            function tFocus(element)
            {
            if (element.value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){element.value='';}
            }
            //Clear default text of emty text areas on submit
            function tSubmit(form)
            {
            var defaultedElements = document.getElementsByTagName("textarea");
            for (var i=0; i != defaultedElements.length; i++){
            if (defaultedElements[i].value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){
            defaultedElements[i].value='';}}
            }
            //Disable pressing 'enter' key to submit a form (otherwise pressing 'enter' causes a submission to start over)
            function disableEnterKey(e)
            {
            var key;

            if(window.event)
            key = window.event.keyCode;     //Internet Explorer
            else
            key = e.which;     //Firefox and Netscape

            if(key == 13)  //if "Enter" pressed, then disable!
            return false;
            else
            return true;
            }
        </script>

        <xsl:text disable-output-escaping="yes">&lt;!--[if lt IE 9]&gt;
            &lt;script src="</xsl:text><xsl:value-of select="concat($theme-path, 'vendor/html5shiv/dist/html5shiv.js')"/><xsl:text disable-output-escaping="yes">"&gt;&#160;&lt;/script&gt;
            &lt;script src="</xsl:text><xsl:value-of select="concat($theme-path, 'vendor/respond/respond.min.js')"/><xsl:text disable-output-escaping="yes">"&gt;&#160;&lt;/script&gt;
            &lt;![endif]--&gt;</xsl:text>

        <!-- Modernizr enables HTML5 elements & feature detects -->
        <script src="{concat($theme-path, 'vendor/modernizr/modernizr.js')}">&#160;</script>

        <!-- Ying added jwplayer and customized scripts.js in the header -->
        <script src="{concat($theme-path, 'scripts/jwplayer/jwplayer.js')}">&#160;</script>
        <!--script src="{concat($theme-path, 'scripts/scripts.js')}">&#160;</script-->

        <!-- Add the title in -->
        <xsl:variable name="page_title" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title'][last()]" />
        <title>
            <xsl:choose>
                <xsl:when test="starts-with($request-uri, 'page/deposit')">
                    <xsl:text>Deposit Your Research in the Rice Digital Scholarship Archive</xsl:text>
                </xsl:when>
                <xsl:when test="not($page_title)">
                    <xsl:text>Deposit Your Research in the Rice Digital Scholarship Archive</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$page_title/node()" />
                </xsl:otherwise>
            </xsl:choose>
        </title>

        <!-- Head metadata in item pages -->
        <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']">
            <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']"
                          disable-output-escaping="yes"/>
        </xsl:if>

        <!-- Add all Google Scholar Metadata values -->
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[substring(@element, 1, 9) = 'citation_']">
            <meta content="{.}" name="{@element}"> </meta>
        </xsl:for-each>

        <!-- Add MathJAX JS library to render scientific formulas
              inlineMath: [['$','$'], ['\\(','\\)']],
                    processEscapes: true,

        -->
        <xsl:if test="confman:getProperty('webui.browse.render-scientific-formulas') = 'true'">
            <script type="text/x-mathjax-config">

                MathJax.Hub.Config({
                    "HTML-CSS": {
                        messageStyle: "normal",
                        linebreaks: {
                            automatic: false
                        }
                    },
                    tex2jax: {
                        ignoreClass: "detail-field-data|detailtable|exception",
                        inlineMath: [["\\(","\\)"]],
                        displayMath: [["$$","$$"],["\\[","\\]"]],
                        processEscapes: true
                        },
                    TeX: {
                        Macros: {
                           tr: "{\\scriptscriptstyle\\mathrm{T}}",
                            AA: '{\\mathring A}'
                        }
                    }
                });
                <!-- Original from DSpace 6.3
                MathJax.Hub.Config({
                  tex2jax: {
                    ignoreClass: "detail-field-data|detailtable|exception"
                  },
                  TeX: {
                    Macros: {
                      AA: '{\\mathring A}'
                    }
                  }
                });-->
            </script>
            <script type="text/javascript" src="//cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">&#160;</script>
        </xsl:if>

    </head>
</xsl:template>


   <!-- The header (distinct from the HTML head element) contains the title, subtitle, login box and various
    placeholders for header images -->
<xsl:template name="buildHeader">


    <header>
        <div class="navbar navbar-default navbar-static-top" role="navigation">
            <div class="container">
                <div class="navbar-header">

                    <button type="button" class="navbar-toggle" data-toggle="offcanvas">
                        <span class="sr-only">
                            <i18n:text>xmlui.mirage2.page-structure.toggleNavigation</i18n:text>
                        </span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>

                    <a href="{$context-path}/" class="navbar-brand">
                        <!--img src="{$theme-path}/images/DSpace-logo-line.svg" /-->
                        <img width="220px" height="84px" src="{$theme-path}/images/RDSA-logo.png" alt="Rice Univesrity Logo" />
                    </a>


                    <div class="navbar-header pull-right visible-xs hidden-sm hidden-md hidden-lg">
                    <ul class="nav nav-pills pull-left ">

                        <xsl:if test="count(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='supportedLocale']) &gt; 1">
                            <li id="ds-language-selection-xs" class="dropdown">
                                <xsl:variable name="active-locale" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='currentLocale']"/>
                                <button id="language-dropdown-toggle-xs" href="#" role="button" class="dropdown-toggle navbar-toggle navbar-link" data-toggle="dropdown">
                                    <b class="visible-xs glyphicon glyphicon-globe" aria-hidden="true"/>
                                </button>
                                <ul class="dropdown-menu pull-right" role="menu" aria-labelledby="language-dropdown-toggle-xs" data-no-collapse="true">
                                    <xsl:for-each
                                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='supportedLocale']">
                                        <xsl:variable name="locale" select="."/>
                                        <li role="presentation">
                                            <xsl:if test="$locale = $active-locale">
                                                <xsl:attribute name="class">
                                                    <xsl:text>disabled</xsl:text>
                                                </xsl:attribute>
                                            </xsl:if>
                                            <a>
                                                <xsl:attribute name="href">
                                                    <xsl:value-of select="$current-uri"/>
                                                    <xsl:text>?locale-attribute=</xsl:text>
                                                    <xsl:value-of select="$locale"/>
                                                </xsl:attribute>
                                                <xsl:value-of
                                                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='supportedLocale'][@qualifier=$locale]"/>
                                            </a>
                                        </li>
                                    </xsl:for-each>

                                </ul>
                            </li>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'">
                                <li class="dropdown">
                                    <button class="dropdown-toggle navbar-toggle navbar-link" id="user-dropdown-toggle-xs" href="#" role="button"  data-toggle="dropdown">
                                        <b class="visible-xs glyphicon glyphicon-user" aria-hidden="true"/>
                                    </button>
                                    <ul class="dropdown-menu pull-right" role="menu"
                                        aria-labelledby="user-dropdown-toggle-xs" data-no-collapse="true">
                                        <li>
                                            <a href="{/dri:document/dri:meta/dri:userMeta/
                        dri:metadata[@element='identifier' and @qualifier='url']}">
                                                <i18n:text>xmlui.EPerson.Navigation.profile</i18n:text>
                                            </a>
                                        </li>
                                        <li>
                                            <a href="{/dri:document/dri:meta/dri:userMeta/
                        dri:metadata[@element='identifier' and @qualifier='logoutURL']}">
                                                <i18n:text>xmlui.dri2xhtml.structural.logout</i18n:text>
                                            </a>
                                        </li>
                                    </ul>
                                </li>
                            </xsl:when>
                            <xsl:otherwise>
                                <li>
                                    <form style="display: inline" action="{/dri:document/dri:meta/dri:userMeta/
                        dri:metadata[@element='identifier' and @qualifier='loginURL']}" method="get">
                                        <button class="navbar-toggle navbar-link">
                                        <b class="visible-xs glyphicon glyphicon-user" aria-hidden="true"/>
                                        </button>
                                    </form>
                                </li>
                            </xsl:otherwise>
                        </xsl:choose>
                    </ul>
                          </div>
                </div>

                <div class="navbar-header pull-right hidden-xs">
                    <ul class="nav navbar-nav pull-left">
                          <xsl:call-template name="languageSelection"/>
                    </ul>

                    <ul class="nav navbar-nav pull-left">
                        <li>
                      <a href="http://bit.ly/RiceArchive-FAQ" ><span class="hidden-xs">FAQ</span></a>
                     </li>
                        <li> </li>

                    </ul>
                    <ul class="nav navbar-nav pull-left">
                        <li>
                            <!--a href="/page/deposit" ><span class="glyphicon glyphicon-import" aria-hidden="true"></span><span class="hidden-xs"> Deposit your work</span></a-->
                            <a href="https://library.rice.edu/submit-your-work" ><span class="glyphicon glyphicon-import" aria-hidden="true"></span><span class="hidden-xs"> Deposit your work</span></a>
                        </li>
                        <li> </li>

                    </ul>

                    <ul class="nav navbar-nav pull-left">


                        <xsl:choose>
                            <xsl:when test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'">
                                <li class="dropdown">
                                    <a id="user-dropdown-toggle" href="#" role="button" class="dropdown-toggle"
                                       data-toggle="dropdown">
                                        <span class="hidden-xs">
                                            <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                        dri:metadata[@element='identifier' and @qualifier='firstName']"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                        dri:metadata[@element='identifier' and @qualifier='lastName']"/>
                                            &#160;
                                            <b class="caret"/>
                                        </span>
                                    </a>
                                    <ul class="dropdown-menu pull-right" role="menu"
                                        aria-labelledby="user-dropdown-toggle" data-no-collapse="true">
                                        <li>
                                            <a href="{/dri:document/dri:meta/dri:userMeta/
                        dri:metadata[@element='identifier' and @qualifier='url']}">
                                                <i18n:text>xmlui.EPerson.Navigation.profile</i18n:text>
                                            </a>
                                        </li>
                                        <li>
                                            <a href="{/dri:document/dri:meta/dri:userMeta/
                        dri:metadata[@element='identifier' and @qualifier='logoutURL']}">
                                                <i18n:text>xmlui.dri2xhtml.structural.logout</i18n:text>
                                            </a>
                                        </li>
                                    </ul>
                                </li>
                            </xsl:when>
                            <xsl:otherwise>
                                <li>
                                    <a href="{/dri:document/dri:meta/dri:userMeta/
                        dri:metadata[@element='identifier' and @qualifier='loginURL']}">
                                        <span class="hidden-xs">
                                            <i18n:text>xmlui.dri2xhtml.structural.login</i18n:text>
                                        </span>
                                    </a>
                                </li>
                            </xsl:otherwise>
                        </xsl:choose>
                    </ul>

                    <button data-toggle="offcanvas" class="navbar-toggle visible-sm" type="button">
                        <span class="sr-only"><i18n:text>xmlui.mirage2.page-structure.toggleNavigation</i18n:text></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>
                </div>
            </div>
        </div>

    </header>

</xsl:template>

<!-- Like the header, the footer contains various miscellaneous text, links, and image placeholders -->
<xsl:template name="buildFooter">
    <footer>
            <div class="row">
                <hr/>
                <div class="col-xs-5 col-sm-6">
                    <div class="pull-left">
                        <div>

                         <a href="{$repositoryURL}">
                <!-- i18n: "Home" -->
                <i18n:text>xmlui.Rice.Home</i18n:text>
                    </a>
                           <xsl:text> | </xsl:text>
                         <a href="http://bit.ly/RiceArchive-FAQ">
                            <!-- i18n: "FAQ" -->
                            <i18n:text>xmlui.Rice.FAQ</i18n:text>
                        </a>
                        <xsl:text> | </xsl:text>
                        <!--a href="https://library.rice.edu/services/dss/contact-us-dss">
                            <i18n:text>xmlui.dri2xhtml.structural.contact-link</i18n:text>
                        </a-->
                            <a href="mailto:cds@rice.edu"> <i18n:text>xmlui.dri2xhtml.structural.contact-link</i18n:text> </a>
                            <xsl:text> | </xsl:text>
                            <a href="https://privacy.rice.edu/"> <xsl:text>Privacy Notice</xsl:text> </a>
                            </div>
                        <div>

            Managed by the <a href="http://library.rice.edu/dss">Digital Scholarship Services</a> at <a href="http://library.rice.edu">Fondren Library</a>, <a href="http://www.rice.edu">Rice University</a>

                        </div>
                    </div>

                </div>
                <div class="col-xs-7 col-sm-6 pull-right">
                    <div>
                        Physical Address: 6100 Main Street, Houston, Texas 77005
                    </div>
                    <div>
                        Mailing Address: MS-44, P.O.BOX 1892, Houston, Texas 77251-1892
                    </div>
                </div>
            </div>
            <!--Invisible link to HTML sitemap (for search engines) -->
            <a class="hidden">
                <xsl:attribute name="href">
                    <xsl:value-of
                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                    <xsl:text>/htmlmap</xsl:text>
                </xsl:attribute>
                <xsl:text>&#160;</xsl:text>
            </a>
        <p>&#160;</p>
    </footer>
</xsl:template>


    <!-- MMS: "Home | FAQ | Contact Us" links provided at both top and bottom of page -->
    <xsl:template name="quick-links">
        <ul class="ds-quick-links">
            <li class="first-link">
                <a href="{$repositoryURL}">
                    <!-- i18n: "Home" -->
                    <i18n:text>xmlui.Rice.Home</i18n:text>
                </a>
            </li>
            <li>
                <a href="http://bit.ly/RiceArchive-FAQ">
                    <!-- i18n: "FAQ" -->
                    <i18n:text>xmlui.Rice.FAQ</i18n:text>
                </a>
            </li>
            <li class="last-link">
                <a href="https://library.rice.edu/services/dss/contact-us-dss">
                    <!-- i18n: "Contact Us" -->
                    <i18n:text>xmlui.dri2xhtml.structural.contact-link</i18n:text>
                </a>
            </li>
        </ul>
    </xsl:template>

     <xsl:template match="mets:fileGrp[@USE='CONTENT']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
        <xsl:param name="xmlFile">
            <xsl:choose>
                <xsl:when test="mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/xml' and
                    $context/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='format' and @qualifier='xmlschema']">1</xsl:when>
                <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <!-- MMS: Adding wrapper here. -->
        <div class="file-wrapper row">


               <xsl:choose>
                <!-- If this is an XML text, present a special file table.
                     MMS: This customization originally put directly in General-Handler.xsl,
                     but that was not the correct place for it. -->
                <xsl:when test="$xmlFile='1'">
                    <xsl:apply-templates select="mets:file[@ID=$primaryBitstream]" mode="xml-text">
                        <xsl:with-param name="context" select="$context"/>
                        <xsl:with-param name="schema">tei</xsl:with-param>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- Normal item. -->
                <xsl:otherwise>
                <xsl:choose>
                        <xsl:when test="mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                            <xsl:apply-templates select="mets:file[@ID=$primaryBitstream]">
                                <xsl:with-param name="context" select="$context"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="mets:file">
                                <xsl:sort data-type="number" select="boolean(./@ID=$primaryBitstream)" order="descending" />
                                <xsl:sort select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                                <xsl:with-param name="context" select="$context"/>
                            </xsl:apply-templates>
                            <!--xsl:apply-templates select="mets:file">
                                <xsl:sort data-type="number" select="boolean(./@ID=$primaryBitstream)" order="descending" />
                                <xsl:sort data-type="number" select="substring-after('?sequence=', mets:FLocat[@LOCTYPE='URL']/@xlink:href)"/>
                                <xsl:with-param name="context" select="$context"/>
                            </xsl:apply-templates-->
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>


    <!-- Special handling for when there is an XML text item.
         MMS: This customization originally put directly in General-Handler.xsl,
         but that was not the correct place for it. -->
    <xsl:template match="mets:file" mode="xml-text">
        <xsl:param name="context"/>
        <xsl:param name="schema"/>
        <xsl:variable name="base" select="substring-after(mets:FLocat[@LOCTYPE='URL']/@xlink:href, 'handle/')" />
        <xsl:variable name="front" select="substring-before($base, '.xml')" />
        <xsl:variable name="seq1" select="substring-after($base, '?sequence=')" />
        <xsl:variable name="seq" select="substring-before($seq1, '&amp;isAllowed')" />
        <xsl:variable name="filename0" select="substring-after($front, '/')" />
        <xsl:variable name="filename" select="substring-after($filename0, '/')" />
        <xsl:variable name="handleslash" select="substring-before($front, $filename)" />
        <xsl:variable name="href">
            <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
            <xsl:text>/jsp/xml/</xsl:text>
            <xsl:value-of select="$handleslash"/>
            <xsl:value-of select="$seq"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="$filename"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="$schema"/>
            <xsl:text>.html</xsl:text>
        </xsl:variable>
        <div class="file-wrapper row">
             <div class="col-xs-6 col-sm-3">
                  <div class="thumbnail">
                <a href="{$href}">
                    <img src="/themes/Americas/a-images/icon_text.gif"/>
                </a>
                      </div>
        </div>
        <div class="col-xs-6 col-sm-7">
             <dl class="file-metadata">
                 <dt>

                    <a href="{$href}">
                        <!-- i18n: View Online -->
                        <i18n:text>xmlui.Rice.ViewOnline</i18n:text>
                    </a>
                    <xsl:text> </xsl:text>
                    <!-- i18n: (witih pages images) -->
                    <i18n:text>xmlui.Rice.WithPageImages</i18n:text>
                    </dt>
        </dl>
        </div>
        <div class="file-link col-xs-6 col-xs-offset-6 col-sm-2 col-sm-offset-0">


                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                    </xsl:attribute>
                    <!-- i18n: View Markup -->
                    <i18n:text>xmlui.Rice.ViewMarkup</i18n:text>
                </a>
        </div>
        </div>
    </xsl:template>

    <xsl:template match="mets:fileSec" mode="artifact-preview">
        <xsl:param name="href"/>
        <xsl:param name="type"/>
        <div class="thumbnail artifact-preview">
            <a class="image-link" href="{$href}">
                <xsl:choose>
                    <xsl:when test="mets:fileGrp[@USE='THUMBNAIL']">
                        <img class="img-responsive" alt="xmlui.mirage2.item-list.thumbnail" i18n:attr="alt">
                            <xsl:attribute name="src">
                                <xsl:value-of
                                        select="mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:attribute>
                        </img>
                    </xsl:when>
                    <xsl:when test="$type='music'">
                        <img alt="xmlui.mirage2.item-list.thumbnail" i18n:attr="alt" src="{concat($theme-path,'/images/40px-High-contrast-audio-volume-high.svg.png')}">
                             </img>
                            </xsl:when>
                          <xsl:otherwise>
                        <img alt="xmlui.mirage2.item-list.thumbnail" i18n:attr="alt" src="{concat($theme-path,'/images/Text_Page_Icon.png')}">
                            <!--xsl:attribute name="data-src">
                                <xsl:text>holder.js/100%x</xsl:text>
                                <xsl:value-of select="$thumbnail.maxheight"/>
                                <xsl:text>/text:No Thumbnail</xsl:text>
                            </xsl:attribute-->
                        </img>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
        </div>
    </xsl:template>


</xsl:stylesheet>
