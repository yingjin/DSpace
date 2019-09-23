<?xml version="1.0" encoding="UTF-8"?>

<!--
    Americas.xsl
    Skin for the Americas Archive made to match the look and feel of the Our Americas Archive Partnership.
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
    xmlns:atom="http://www.w3.org/2005/Atom">
    
    <xsl:import href="../dri2xhtml.xsl"/>
    <xsl:import href="../Rice/reusable-new-templates.xsl"/>
    <xsl:import href="../Rice/reusable-overrides.xsl"/>

    <xsl:output indent="yes"/>

    <!-- MMS: Variables defined once for use in multiple places -->
    <xsl:variable name="communityTitle" select="dri:document/dri:meta/dri:pageMeta/dri:trail[2]/text()"/>
    <xsl:variable name="communityURL" select="dri:document/dri:meta/dri:pageMeta/dri:trail[2]/@target"/>

    <!-- MMS: Don't output list that formerly started with 'Browse', just process its "Collection" child list, but with the same mark-up as its parent would have had. -->
    <xsl:template match="dri:options/dri:list[@n='browse']" priority="4">
      <!-- MMS: Only do the "Collection" list, since the "Community" one is hard-coded in the dri:options template -->
      <xsl:for-each select="dri:list[@n='context'][dri:head/node()!='xmlui.ArtifactBrowser.Navigation.head_this_community']">
        <xsl:apply-templates select="dri:head" mode="nested"/>
        <div>
          <xsl:call-template name="standardAttributes">
            <xsl:with-param name="class">ds-option-set</xsl:with-param>
          </xsl:call-template>
          <ul class="ds-simple-list">
            <xsl:apply-templates select="*[not(self::dri:head)]" mode="nested"/>
          </ul>
        </div>
      </xsl:for-each>
    </xsl:template>

    
    <!-- MMS: Instead of <h4>This Collection</h4>, use <h3>Browse Collection: [Collection Title]</h3>. -->
    <xsl:template match="dri:list/dri:list/dri:head[node()='xmlui.ArtifactBrowser.Navigation.head_this_collection']" priority="3" mode="nested">
      <h3>
        <xsl:call-template name="standardAttributes">
           <xsl:with-param name="class">ds-option-set-head</xsl:with-param>
        </xsl:call-template>
        <i18n:text>xmlui.Americas.BrowseCollection</i18n:text>
        <xsl:text> </xsl:text>
        <!--a href="{ancestor::dri:document/dri:meta/dri:pageMeta/dri:trail[3]/@target}">
          <xsl:apply-templates select="ancestor::dri:document/dri:meta/dri:pageMeta/dri:trail[3]/text()"/>
        </a-->
          <a href="/{dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI']}">
            <xsl:apply-templates select="ancestor::dri:document/dri:meta/dri:pageMeta/dri:trail[3]/text()"/>
          </a>
      </h3>
    </xsl:template>

    <!-- MMS: See ../dri2xhtml/structural.xsl for full extensive comments on this template -->
    <xsl:template match="dri:document">
        <html>
            <xsl:call-template name="buildHead"/>
            <xsl:choose>
                <xsl:when test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='framing'][@qualifier='popup']">
                    <xsl:apply-templates select="dri:body/*"/>
                    <xsl:if test="dri:body/dri:div[@n='lookup']">
                        <xsl:call-template name="choiceLookupPopUpSetup"/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <body>
                        <div id="ds-main">
                            <!-- MMS: don't call buildHeader template (breadcrumbs, logo, etc., now done elsewhere or not at all) -->
                            <!-- MMS: wrap another CSS hook around the non-header, non-footer part -->
                            <div id="americas-main">
                                <xsl:if test="dri:body/dri:div[@n='item-view']">
                                    <xsl:attribute name="class">item-view</xsl:attribute>
                                </xsl:if>
                                <!-- MMS: output breadcrumbs here -->
                                <ul id="ds-trail-top">
                                    <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"/>
                                </ul>
                                <!-- MMS: yet another CSS hook -->
                                <div id="americas-contents">
                                    <xsl:apply-templates/>
                                </div>
                                <xsl:call-template name="buildFooter"/>
                            </div>
                        </div>
                    </body>
                </xsl:otherwise>
            </xsl:choose>
        </html>
    </xsl:template>
    
    <!-- MMS: Footer (mostly recycled from old Rice.xsl). -->
    <xsl:template name="buildFooter">
        <div>
            <xsl:attribute name="id">ds-footer</xsl:attribute>
            <ul id="ds-trail-bottom">
                <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"/>
            </ul>
            <p>
                Managed by the <a href="http://library.rice.edu/about/departments/CDS/digital-library-initiative">Center for Digital Scholarship</a> at <a href="http://library.rice.edu">Fondren Library</a>, <a href="http://www.rice.edu">Rice University</a>
            </p>
            <p>
                <a class="contact-us">
                    <!-- i18n: "Contact Us" -->
                    <i18n:text>xmlui.dri2xhtml.structural.contact-link</i18n:text>
                </a>
            </p>
        </div>
    </xsl:template>

    <!-- MMS: Use a different file than that "TEXT" image from TIMEA (copied from Rice.xsl with comments removed) -->
    <xsl:template match="mets:fileSec" mode="artifact-preview">
        <xsl:variable name="pfid" select="/mets:METS/mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID" />
        <xsl:choose>
            <xsl:when test="mets:fileGrp/mets:file[@ID=$pfid]/@MIMETYPE='text/xml' and
                /mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='format' and @qualifier='xmlschema']">
                <div class="artifact-preview">
                    <a href="{ancestor::mets:METS/@OBJID}">
                        <img alt="TEI Thumbnail" src="/themes/Americas/images/icon_text.gif" />
                    </a>
                </div>
            </xsl:when>
            <xsl:when test="mets:fileGrp[@USE='THUMBNAIL']">
                <div class="artifact-preview">
                    <xsl:apply-templates select="mets:fileGrp[@USE='THUMBNAIL']/mets:file" mode="thumbnail">
                        <xsl:sort select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"  order="ascending"/>
                    </xsl:apply-templates>
                </div>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- MMS: Put the preview/icon before the item's info (copied from DIM-Handler.xsl with comments removed) -->
    <xsl:template name="itemSummaryList-DIM">
        <xsl:apply-templates select="./mets:fileSec" mode="artifact-preview"/>
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
            mode="itemSummaryList-DIM"/>
    </xsl:template>

    <!-- MMS: put "clear"ing <div> at bottom (copied from structural.xsl with comments removed) -->
    <xsl:template match="dri:reference" mode="summaryList">
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="@url"/>
            <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL,structMap</xsl:text>
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
            <!-- MMS: only difference here -->
            <div class="clear"><xsl:text> </xsl:text></div>
        </li>
    </xsl:template>

    <!-- MMS: Overridden to add title and search, remove respository navigation, make community navigation permanent and collection navigation contextual, and style everything differently. -->
    <xsl:template match="dri:options">
        <div id="ds-options">
            <div id="community-options">
                <h1 style="margin-top: 0; margin-bottom: .2em;">
                    <a href="{$communityURL}">
                        <xsl:value-of select="$communityTitle"/>
                    </a>
                </h1>
                <div id="repository-link">
                    <!-- i18n: In the -->
                    <i18n:text>xmlui.Americas.Inthe</i18n:text>
                    <xsl:text> </xsl:text>
                    <a href="/">
                        <!-- i18n: Rice Digital Scholarhip Archive -->
                        <i18n:text>xmlui.Americas.RiceDigitalScholarshipArchive</i18n:text>
                    </a>
                </div>
                <div class="search-wrapper">
                    <div class="ds-search-option">
                        <form action="{$communityURL}{../dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']}" method="post" onsubmit="javascript:tSubmit(this);">
                            <input class="ds-text-field " 
                                type="text" 
                                value="xmlui.Americas.SearchThisCommunity" 
                                onfocus="this.value='';" 
                                onclick="this.value='';" 
                                i18n:attr="value">
                                <!-- i18n: Search this community ... -->
                                <xsl:attribute name="name">
                                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='queryField']"/>
                                </xsl:attribute>
                            </input>
                            <input class="ds-button-field" 
                                name="submit" 
                                type="image" 
                                alt="xmlui.general.go"
                                i18n:attr="alt"
                                src="{$theme-path}/images/search_submit_lg.jpg" />
                        </form>
                    </div>
                    <div class="advanced-search">
                        <a href="{$communityURL}{../dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='advancedURL']}">
                            <!-- i18n: Advanced Search Within This Community -->
                            <i18n:text>xmlui.ArtifactBrowser.CommunityViewer.advanced_search_link</i18n:text>
                        </a>
                    </div>
                    <!-- MMS: Always show the community browse options. -->
                    <h3 class="ds-option-set-head">
                        <!-- i18n: Browse -->
                        <i18n:text>xmlui.ArtifactBrowser.Navigation.head_browse</i18n:text>
                        <xsl:text> </xsl:text>
                        <!-- i18n: Community -->
                        <i18n:text>xmlui.Americas.Community</i18n:text>
                        <xsl:text>: </xsl:text>
                        <a href="{$communityURL}">
                            <xsl:value-of select="$communityTitle"/>
                        </a>
                    </h3>
                    <div id="aspect_artifactbrowser_Navigation_list_community" class="ds-option-set">
                        <ul class="ds-simple-list">
                            <!-- MMS: Hard code a "Collections" link that just goes back to community home page. -->
                            <li>
                                <a href="{$communityURL}">
                                    <!-- i18n: Collections -->
                                    <i18n:text>xmlui.administrative.collection.general.collection_trail</i18n:text>
                                </a>
                            </li>
                            <!-- MMS: Recycle the contextual links instead of hard-coding them. Hopefully they're always the same for community level vs. collection level. -->
                            <xsl:for-each select="dri:list/dri:list[@n='context']/dri:item">
                                <li>
                                    <xsl:if test="../dri:head[node()='xmlui.ArtifactBrowser.Navigation.head_this_collection']">
                                        <a href="{ancestor::dri:document/dri:meta/dri:pageMeta/dri:trail[2]/@target}/browse{substring-after(dri:xref/@target,'browse')}">
                                            <xsl:choose>
                                                <!-- MMS: For browsing, use label of "Dates" instead of "By Issue Date" -->
                                                <xsl:when test="dri:xref/i18n:text/node()='xmlui.ArtifactBrowser.Navigation.browse_dateissued'">
                                                    <!-- i18n: Dates -->
                                                    <i18n:text>xmlui.ArtifactBrowser.CommunityViewer.browse_dates</i18n:text>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:copy-of select="dri:xref"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </a>
                                    </xsl:if>
                                    <xsl:if test="../dri:head[node()!='xmlui.ArtifactBrowser.Navigation.head_this_collection']">
                                        <a href="{dri:xref/@target}">
                                            <xsl:choose>
                                                <!-- MMS: For browsing, use label of "Dates" instead of "By Issue Date" -->
                                                <xsl:when test="dri:xref/i18n:text/node()='xmlui.ArtifactBrowser.Navigation.browse_dateissued'">
                                                    <!-- i18n: Dates -->
                                                    <i18n:text>xmlui.ArtifactBrowser.CommunityViewer.browse_dates</i18n:text>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:copy-of select="dri:xref"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </a>
                                    </xsl:if>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                    <!-- MMS: output any collection-level browse lists here in this div (will exclude community-level lists in the applied template) -->
                    <xsl:apply-templates select="dri:list[@n='browse']"/>
                </div>
            </div>
            <!-- Max: output non-browse options (account, editing, admin) here in different div, but only if logged in. -->
            <xsl:if test="not(dri:list/dri:item/dri:xref[@target='/login'])">
                <div id="repository-options">
                    <xsl:apply-templates select="dri:list[@n!='browse']"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>

    <!-- MMS: For browsing, use label of "Dates" instead of "By Issue Date" -->
    <xsl:template match="dri:item/dri:xref[contains(@target,'dateissued')]">
        <a>
            <xsl:if test="@target">
                <xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="@rend">
                <xsl:attribute name="class"><xsl:value-of select="@rend"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="@n">
                <xsl:attribute name="name"><xsl:value-of select="@n"/></xsl:attribute>
            </xsl:if>
            <!-- i18n: Dates -->
            <i18n:text>xmlui.ArtifactBrowser.CollectionViewer.browse_dates</i18n:text>
        </a>
    </xsl:template>

    <!-- MMS: Remove the "Browse by" in the body (since this is doubled up in the contextual options at left). -->
    <xsl:template match="dri:div[@n='community-browse' or @n='collection-browse']" priority="1" />
    
    <!-- MMS: Need CSS hook around recent submission (copied from structural.xsl) -->
    <xsl:template match="dri:div[contains(@rend,'recent-submission')]" priority="1">
        <div id="recent-submissions">
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
        <xsl:apply-templates select="@pagination">
            <xsl:with-param name="position">bottom</xsl:with-param>
        </xsl:apply-templates>
        </div>
    </xsl:template>
    
    <!-- MMS: Hide the "Show [full/simple] item record" links at the beginning and end of the page and hard-code them in closer to the table. -->
    <xsl:template match="dri:p[contains(@rend,'item-view-toggle')]"/>
    
    <!-- MMS: Add record expander link, as well as "Related links" section if applicable (copied from DIM-Handler.xsl with comments removed) -->
    <xsl:template name="itemSummaryView-DIM">
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']">
                    <xsl:with-param name="context" select="."/>
                    <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']"/>
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
        <!-- MMS: Put the "Show full item record" link here at the top of the table instead at the top and bottom of everything. -->
        <p class="ds-paragraph item-view-toggle item-view-toggle-top">
            <a href="?show=full"><i18n:text>xmlui.ArtifactBrowser.ItemViewer.show_full</i18n:text></a>
        </p>
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
            mode="itemSummaryView-DIM"/>
        <!-- MMS: Other metadata displayed below the table. -->
        <xsl:call-template name="other-metadata"/>
    </xsl:template>
    
    <!-- MMS: As above, add record expander link, as well as "Related links" section if applicable (copied from DIM-Handler.xsl with comments removed) -->
    <xsl:template name="itemDetailView-DIM">
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']">
                    <xsl:with-param name="context" select="."/>
                    <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']"/>
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
        <!-- MMS: Put the "Show simple item record" link here at the top of the table instead at the top and bottom of everything. -->
        <p class="ds-paragraph item-view-toggle item-view-toggle-top">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="@OBJID"/>
                </xsl:attribute>
                <i18n:text>xmlui.ArtifactBrowser.ItemViewer.show_simple</i18n:text>
            </a>
        </p>
        <xsl:apply-templates select="mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
            mode="itemDetailView-DIM"/>
        <!-- MMS: Other metadata displayed below the table. -->
        <xsl:call-template name="other-metadata"/>
    </xsl:template>
    
    <!-- MMS: List the "Usage and Rights", "Related Links", and other license stuff here after the metadata tables -->
    <xsl:template name="other-metadata">
        <!-- MMS: Displays the "Creative Commons License" (hide DSPace deposit license), but should maybe eventually only rely on dc.rights fields. -->
        <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE']"/>
        <!-- Add "Rights and Usage" section for any dc.rights and dc.rights.uri fields -->
        <xsl:if test="descendant::dim:field[@element='rights']">
            <h3>
                <!-- i18n: Rights and Usage -->
                <i18n:text>xmlui.Rice.RightsAndUsage</i18n:text>
            </h3>
            <ul>
                <li>
                    <xsl:for-each select="descendant::dim:field[@element='rights']">
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
                </li>
            </ul>
        </xsl:if>
        <!-- MMS: Add section for any "Related links" if they are any pointers to translations, the translated original, a Connexions module, or an "isformatof" field -->
        <xsl:if test="descendant::dim:field[@element='relation'][@qualifier='isreferencedby' or @qualifier='isversionof' or @qualifier='isformatof' or @qualifier='isbasedon']">
        <h3>
            <!-- i18n: Related Links -->
            <i18n:text>xmlui.Rice.RelatedLinks</i18n:text>
        </h3>
            <ul>
                <xsl:for-each select="descendant::dim:field[@element='relation'][@qualifier='isreferencedby' or @qualifier='isversionof' or @qualifier='isformatof' or @qualifier='isbasedon']">
                    <li>
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
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:if>
    </xsl:template>
        
    <!-- MMS: Doing Zotero/COinS change another way on "Full item record" table.
         Also reconfiguring things to output the header here instead of in template that applies this one. -->
    <xsl:template match="dim:dim" mode="itemDetailView-DIM">
        <!-- MMS: Give the table a header. -->
        <h3>
            <!-- i18n: Item Metadata -->
            <i18n:text>xmlui.administrative.item.general.option_metadata</i18n:text>
        </h3>
        <table class="ds-includeSet-table">
            <xsl:apply-templates mode="itemDetailView-DIM"/>
        </table>
        <!-- Ying (via MMS): -->
        <xsl:call-template name="COinS" />
    </xsl:template>
    
    <!-- MMS: Give "Files in this item" table and header a CSS wrapper.  Change header size.  Change output if item is XML text.  
         Copied from General-Handler.xsl with original comments removed. -->
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
        <div>
            <xsl:attribute name="class">
                <xsl:text>files-in-item</xsl:text>
                <xsl:if test="$xmlFile='1'">
                    <xsl:text> xml-file</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <h3>
                <!-- i18n: Files in this item -->
                <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text>
            </h3>
        <table class="ds-table file-list">
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
                    <tr class="ds-table-header-row">
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                        <!-- Display header for 'Description' only if at least one bitstream contains a description -->
                        <xsl:if test="mets:file/mets:FLocat/@xlink:label != ''">
                            <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text></th>
                        </xsl:if>
                    </tr>
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
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </table>
        </div>
    </xsl:template>
    
    <!-- MMS: Give "Files in this item" table and header a CSS wrapper.  Change header size.  Copied from DIM-Handler.xsl -->
    <xsl:template match="mets:fileGrp[@USE='ORE']">
        <xsl:variable name="AtomMapURL" select="concat('cocoon:/',substring-after(mets:file/mets:FLocat[@LOCTYPE='URL']//@*[local-name(.)='href'],$context-path))"/>
        <!-- MMS: Add CSS wrapper here. -->
        <div class="files-in-item">
            <!-- MMS: Make this an <h3> instead of <h2>. -->
            <h3>
                <!-- i18n: Files in this item -->
                <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text>
            </h3>
            <table class="ds-table file-list">
                <thead>
                    <tr class="ds-table-header-row">
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:apply-templates select="document($AtomMapURL)/atom:entry/atom:link[@rel='http://www.openarchives.org/ore/terms/aggregates']">
                        <xsl:sort select="@title"/>
                    </xsl:apply-templates>
                </tbody>
            </table>
        </div>
    </xsl:template>
    
    <!-- Special handling for when there is an XML text item. 
         MMS: This customization originally put directly in General-Handler.xsl, 
         but that was not the correct place for it. -->
    <xsl:template match="mets:file" mode="xml-text">
        <xsl:param name="context"/>
        <xsl:param name="schema"/>
        <tr class="full-book odd">
            <td>
                <xsl:variable name="base" select="substring-after(mets:FLocat[@LOCTYPE='URL']/@xlink:href, 'handle/')" />
                <xsl:variable name="front" select="substring-before($base, '.xml')" />
                <xsl:variable name="seq" select="substring-after($base, '?sequence=')" />
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
                <a href="{$href}">
                    <img src="/themes/Americas/images/icon_text.gif"/>
                </a>
                <a href="{$href}">
                    <!-- i18n: View Online -->
                    <i18n:text>xmlui.Rice.ViewOnline</i18n:text>
                </a>
                <xsl:text> </xsl:text>
                <!-- i18n: (witih pages images) -->
                <i18n:text>xmlui.Rice.WithPageImages</i18n:text>
            </td>
        </tr>
        <tr class="even">
            <td>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                    </xsl:attribute>
                    <!-- i18n: View Markup -->
                    <i18n:text>xmlui.Rice.ViewMarkup</i18n:text>
                </a>
            </td>
        </tr>
    </xsl:template>
    
    <!-- MMS: Overriding from reusable-overrides.xsl to add the "Subtitle" and "Series" rows and suppress the "Date" row. -->
    <xsl:template name="simple-item-record-rows">
        <xsl:apply-templates select="." mode="title"/>
        <xsl:apply-templates select="." mode="subtitle"/>
        <xsl:apply-templates select="." mode="alternative-title"/>
        <xsl:apply-templates select="." mode="series"/>
        <xsl:apply-templates select="." mode="author"/>
        <xsl:apply-templates select="." mode="translator"/>
        <xsl:apply-templates select="." mode="abstract"/>
        <xsl:apply-templates select="." mode="description"/>
        <xsl:apply-templates select="." mode="citation"/>
        <!-- MMS: Don't output the "URI" row since that information is already in the "Citation". -->
        <!-- MMS: Don't output the "Date" row since that information is already in the "Citation". -->
    </xsl:template>
    <!-- MMS: 'Subtitle' row in simple item record -->
    <xsl:template match="dim:dim" mode="subtitle">
        <xsl:if test="dim:field[@element='title'][@qualifier='subtitle']">
            <tr class="ds-table-row">
                <th><span class="bold"><i18n:text>xmlui.Americas.Subtitle</i18n:text>:</span></th>
                <td>
                    <xsl:copy-of select="dim:field[@element='title'][@qualifier='subtitle']"/>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
    <!-- MMS: 'Series' row in simple item record -->
    <xsl:template match="dim:dim" mode="series">
        <xsl:if test="dim:field[@element='title'][@qualifier='series']">
            <tr class="ds-table-row">
                <th><span class="bold"><i18n:text>xmlui.ArtifactBrowser.AdvancedSearch.type_series</i18n:text>:</span></th>
                <td>
                    <xsl:copy-of select="dim:field[@element='title'][@qualifier='series']"/>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
        
    <!-- MMS: copied over for the COinS change, to show subtitles, and to prevent "Unknown author" 
         from displaying if none of the supported creator/contributor fields are found -->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM"> 
        <xsl:variable name="itemWithdrawn" select="@withdrawn" />
        <div class="artifact-description">
            <div class="artifact-title">
                <!-- MMS: Moved the COinS span outside of the <a> so that the "title" tooltip text doesn't show up when hovering over the title link. -->
                <xsl:call-template name="COinS"/>
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
                            <!-- MMS: If there is a subtitle, display it. -->
                            <xsl:if test="dim:field[@element='title' and @qualifier='subtitle']">
                                <xsl:text>: </xsl:text>
                                <xsl:value-of select="dim:field[@element='title' and @qualifier='subtitle']"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </div>
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
                        <!-- MMS: Prevent 'funder' or 'translator' from being counted as an author -->
                        <xsl:when test="dim:field[@element='contributor'][@qualifier!='funder' and @qualifier!='translator']">
                            <xsl:for-each select="dim:field[@element='contributor'][@qualifier!='funder' and @qualifier!='translator']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier!='funder' and @qualifier!='translator']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <!-- MMS: Don't display "Unknown Author" if none of the above fields are found. -->
                        <xsl:otherwise/>
                    </xsl:choose>
                </span>
                <xsl:text> </xsl:text>
                <xsl:if test="dim:field[@element='date' and @qualifier='issued'] or dim:field[@element='publisher']">
                    <span class="publisher-date">
                        <xsl:text>(</xsl:text>
                        <xsl:if test="dim:field[@element='publisher']">
                            <span class="publisher">
                                <xsl:copy-of select="dim:field[@element='publisher']/node()"/>
                            </span>
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                        <span class="date">
                            <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                        </span>
                        <xsl:text>)</xsl:text>
                    </span>
                </xsl:if>
            </div>
        </div>
    </xsl:template>
    
    <!-- MMS: Add subtitle to item metadata pages -->
    <xsl:template match="dri:div[@n='item-view']/dri:head" priority="3">
        <xsl:variable name="subtitle">
            <xsl:value-of select="document(concat('cocoon:/',parent::dri:div/dri:referenceSet/dri:reference/@url))/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='title' and @qualifier='subtitle']"/>
        </xsl:variable>
        <xsl:element name="h1">
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">ds-div-head</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates />
            <xsl:if test="$subtitle!=''">
                <xsl:text>: </xsl:text>
                <xsl:value-of select="$subtitle"/>
            </xsl:if>
        </xsl:element>
    </xsl:template>   
    
    <!-- MMS: Don't output lists that have no children nodes (was showing up in Advanced Search and making some browsers look off). -->
    <xsl:template match="dri:list[@type='form'][not(*)]" />
    
</xsl:stylesheet>
