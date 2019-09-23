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
	<xsl:key name="issues-by-vol" match="cds:issue" use="@vol"/>
	
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
        <xsl:apply-templates select="//cds:issue[generate-id(.) = generate-id(key('issues-by-vol', @vol)[1])]"/>
    </xsl:template>


    <!-- Iterate over the <cds:issue> tags and group using the Muenchian method -->
    <xsl:template match="cds:issue">
        <xsl:variable name="search_path" select="$document/dri:meta/dri:pageMeta/dri:metadata[@element='search' and @qualifier='simpleURL']"/>
        <xsl:variable name="query_string" select="$document/dri:meta/dri:pageMeta/dri:metadata[@element='search' and @qualifier='queryField']"/>
        <xsl:variable name="context_path" select="$document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>
        <xsl:variable name="collection_handle" select="substring-after($document/dri:meta/dri:pageMeta/dri:metadata[@element='focus' and @qualifier='container'], ':')"/>
        
        <div class="journal-volume-group">
            <div>
                <div><!-- class="hiddenfield"-->
                        <!-- i18n: Volume N -->
                    <xsl:variable name="volnum" select="substring-before(@vol, '(')"/>
                    <xsl:choose>
                        <xsl:when test="contains(@vol,'Index')">
                            <strong>
                            <a href="{$context_path}/handle/{@handle}">
                                <!-- i18n: Download Complete Issue -->
                                <i18n:translate>
                                    <i18n:text>xmlui.Periodicals.VolumeNumber</i18n:text>
                                    <i18n:param>
                                        <xsl:value-of select="@vol"/>
                                    </i18n:param>
                                </i18n:translate>
                            </a>
                            </strong>
                        </xsl:when>
                        <xsl:otherwise>
                            <strong>
                            <i18n:translate>
                                <i18n:text>xmlui.Periodicals.VolumeNumber</i18n:text>
                                <i18n:param>
                                    <xsl:value-of select="@vol"/>
                                </i18n:param>
                                <xsl:text>    </xsl:text>
                            </i18n:translate>
                            </strong>
                        <xsl:for-each select="key('issues-by-vol', @vol)">
                            <xsl:choose>
                                <xsl:when test="contains(@num, 'Index') or contains(@num, 'Supplement')">

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
                                </xsl:when>
                                <xsl:when test="contains(@num, 'Special Issue')">

                                    <a href="{$context_path}/handle/{$collection_handle}/discover?filtertype_1=volumenum&amp;filter_relational_operator_1=equals&amp;filter_1={$volnum}&amp;filtertype_2=issuenum&amp;filter_relational_operator_2=euqals&amp;filter_2={@num}&amp;submit_apply_filter=&amp;query=">
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
                                </xsl:when>
                                <!--xsl:when test=" contains(@num, 'Supplement')">

                                    |
                                    <a href="{$context_path}/handle/{$collection_handle}/search?{$query_string}=series:%22Volume%20{$volnum},%20Issue {@num}%22">

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


                                </xsl:when-->
                                <xsl:when test="contains($volnum, '-')">

                                    <a href="{$context_path}/handle/{$collection_handle}/discover?filtertype_1=volumenum&amp;filter_relational_operator_1=equals&amp;filter_1={$volnum}&amp;filtertype_2=issuenum&amp;filter_relational_operator_2=euqals&amp;filter_2={@num}&amp;submit_apply_filter=&amp;query=">
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

                                </xsl:when>
                                <xsl:otherwise>
                                    <a href="{$context_path}/handle/{$collection_handle}/discover?filtertype_1=volumenum&amp;filter_relational_operator_1=equals&amp;filter_1={$volnum}&amp;filtertype_2=issuenum&amp;filter_relational_operator_2=euqals&amp;filter_2={@num}&amp;submit_apply_filter=&amp;query=">
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

                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
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
    
    <!-- Overriding from reusable-overrides.xsl to add the "Series" and "Issue" rows and rearrange several of the later rows. -->

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


    <!-- Don't display "Unknown author" if none exists. Prevent COinS tooltip when hovering title link. Add "issue date" text before date. -->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM">
        <xsl:variable name="itemWithdrawn" select="@withdrawn" />
        <div class="artifact-description">
            <div class="artifact-title">
                <!-- Moved the COinS span outside of the <a> so that the "title" tooltip text doesn't show up when hovering over the title link. -->
                <xsl:call-template name="COinS" />
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
            <div class="artifact-info">
                <span class="author">
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                <xsl:copy-of select="./node()"/>
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
                            <xsl:for-each select="dim:field[@element='contributor']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <!-- If no author was found, don't output "Unknown author". -->
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
                            <!-- Insert "issue date" text here. -->
                            <i18n:translate>
                                <i18n:text>xmlui.Periodicals.issuedate</i18n:text>
                                <i18n:param>
                                    <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                                </i18n:param>
                            </i18n:translate>
                        </span>
                        <xsl:text>)</xsl:text>
                    </span>
                </xsl:if>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="dri:document/dri:body/dri:div/dri:div[contains(@rend,'recent-submission')]" priority="1">
    </xsl:template>

</xsl:stylesheet>
