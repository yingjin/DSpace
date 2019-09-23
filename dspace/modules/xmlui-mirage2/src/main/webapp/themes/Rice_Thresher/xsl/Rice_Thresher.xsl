<?xml version="1.0" encoding="UTF-8"?>
<!--
	Periodicals.xsl
	Adapted from Adam Mikeal's Periodicals.xsl ((c) 2007 TAMU Libraries) with permission.
	Edited by Max Starkenburg et al.
-->
<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                xmlns:dri="http://di.tamu.edu/DRI/1.0/"
                xmlns:mets="http://www.loc.gov/METS/"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/TR/xlink/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cds="http://www.rice.edu/CDS"
                version="1.0">

    <xsl:output indent="yes"/>

	<!-- Set up the key for the Muenchian grouping -->
	<xsl:key name="issues-by-vol" match="cds:issue" use="@groupingvol"/>
	
	<!--
        The document variable is a reference to the top of the original DRI 
        document. This can be useful in situations where the XSL has left
        the original document's context such as after a document() call and 
        would like to retrieve information back from the base DRI document.
    -->
    <xsl:variable name="document" select="/dri:document"/>


	<!-- A collection rendered in the detailView pattern; default way of viewing a collection. -->
    <xsl:template name="collectionDetailView-DIM">
        <div class="detail-view"> 
            <!-- Generate the logo, if present, from the file section -->
            <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='LOGO']"/>
            <!-- Generate the info about the collections from the metadata section -->
            <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim" mode="collectionDetailView-DIM"/>
        </div>
        <!-- List all the volumes and their issues here. -->

        <div class="panel-group" id="accordion">
        <xsl:apply-templates select="//cds:issue[generate-id(.) = generate-id(key('issues-by-vol', @groupingvol)[1])]"/>
        </div>
    </xsl:template>


    <!-- Iterate over the <cds:issue> tags and group using the Muenchian method -->
    <xsl:template match="cds:issue">
        <xsl:variable name="search_path" select="$document/dri:meta/dri:pageMeta/dri:metadata[@element='search' and @qualifier='simpleURL']"/>
        <xsl:variable name="query_string" select="$document/dri:meta/dri:pageMeta/dri:metadata[@element='search' and @qualifier='queryField']"/>
        <xsl:variable name="context_path" select="$document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>
        <xsl:variable name="collection_handle" select="substring-after($document/dri:meta/dri:pageMeta/dri:metadata[@element='focus' and @qualifier='container'], ':')"/>

        <xsl:variable name="volnum" select="substring-before(@vol, ' (')"/>
        <xsl:variable name="volyear" select="substring-before(substring-after(@vol, ' ('), ')')"/>

            <!--  data-target="#v{$volnum}" -->
        <div class="journal-volume-group panel panel-default">
                <!-- i18n: Volume N -->
            <div class="Vol-group panel-heading">
                 <h4 class="panel-title">
                     <a
                     data-toggle="collapse"
                     href="#v{$volnum}{$volyear}">

                     <i18n:translate>
                         <i18n:text>xmlui.Periodicals.VolumeNumber</i18n:text>
                         <i18n:param>
                             <xsl:value-of select="@vol"/>
                         </i18n:param>
                     </i18n:translate>
                     </a>
                 </h4>
            </div>
            <div id="v{$volnum}{$volyear}" class="panel-collapse collapse">
                <div class="panel-body">
                    <xsl:for-each select="key('issues-by-vol', @groupingvol)">
                         <a href="{$context_path}/handle/{@handle}">
                        <!-- i18n: Issue N (YYYY-MM-DD) -->
                                <i18n:translate>
                                    <i18n:text>xmlui.Periodicals.IssueNumberAndDate</i18n:text>
                                    <i18n:param>
                                        <xsl:value-of select="@num"/>
                                    </i18n:param>
                                    <i18n:param>
                                        <xsl:value-of select="@year"/>
                                    </i18n:param>
                                </i18n:translate>
                                <xsl:if test="@name != ''">
                                    <xsl:text> :: </xsl:text>
                                    <xsl:value-of select="@name"/>
                                </xsl:if>
                        </a>
                        |

                    </xsl:for-each>
                </div>
            </div>
        </div>


    </xsl:template>

    <!-- Group of templates to hide the search forms and disguise the search results as a browse list (if the search query starts with "series:") -->
    <xsl:template match="dri:div[@n='general-query'][starts-with(/dri:document//dri:value[@type='raw'],'series:')]"/>
    <xsl:template match="dri:p[@n='result-query'][starts-with(/dri:document//dri:value[@type='raw'],'series:')]"/>    
    <xsl:template match="dri:div[@id='aspect.artifactbrowser.SimpleSearch.div.search'][starts-with(/dri:document//dri:value[@type='raw'],'series:')]/dri:head/i18n:text">
        <i18n:text>xmlui.Periodicals.BrowseIssue</i18n:text>
    </xsl:template>
    <xsl:template match="dri:div[@id='aspect.artifactbrowser.SimpleSearch.div.search-results'][/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search' and @qualifier='hideForm']]/dri:head"/>
    

    <!-- Ying: Updated this for our new theme -->
    <xsl:template name="simple-item-record-rows">
 <!--                    <xsl:call-template name="itemSummaryView-DIM-URI"/-->
                     <xsl:call-template name="itemSummaryView-DIM-authors"/>
                     <xsl:call-template name="itemSummaryView-DIM-date"/>
                     <xsl:call-template name="itemSummaryView-DIM-citation"/>
                     <xsl:call-template name="itemSummaryView-DIM-doi"/>
                     <xsl:call-template name="itemSummaryView-DIM-subject-keyword"/>
                     <xsl:call-template name="itemSummaryView-DIM-abstract"/>
                     <xsl:call-template name="itemSummaryView-DIM-series"/>
                     <xsl:call-template name="itemSummaryView-DIM-issue"/>
                     <xsl:if test="$ds_item_view_toggle_url != ''">
                         <xsl:call-template name="itemSummaryView-show-full"/>
                     </xsl:if>
                     <xsl:call-template name="itemSummaryView-collections"/>
     </xsl:template>

     <!-- 'Issue' row in simple item record -->
 <!--    <xsl:template name="itemSummaryView-DIM-issue">
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
     </xsl:template> -->

    <xsl:template match="dri:document/dri:body/dri:div/dri:div[contains(@rend,'recent-submission')]" priority="1">
    </xsl:template>



</xsl:stylesheet>
