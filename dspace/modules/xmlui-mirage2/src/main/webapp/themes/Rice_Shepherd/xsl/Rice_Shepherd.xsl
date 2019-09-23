<?xml version="1.0" encoding="UTF-8"?>

<!--

    Rice_Shepherd.xsl

    XSLT overrides for the "Shepherd School of Music" community in Rice DSpace, mostly 
    related to changes to the simple item record page, since most of the items in this 
    community are audio recordings and thus need to feature different metadata.

    Ying adapted this for the Mirage2
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
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:jstring="java.lang.String"
    xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights confman">

    <xsl:output indent="yes"/>
    <xsl:variable name="baseURL" select="confman:getProperty('dspace.baseUrl')"/>
    
    <!-- Utility function for use by other templates below. -->
    <xsl:template name="substring-after-last">
        <xsl:param name="string" />
        <xsl:param name="delimiter" />
        <xsl:choose>
            <xsl:when test="contains($string, $delimiter)">
                <xsl:call-template name="substring-after-last">
                    <xsl:with-param name="string"
                        select="substring-after($string, $delimiter)" />
                    <xsl:with-param name="delimiter" select="$delimiter" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$string" /></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Split out a relation.x link into an HTML link with a pretty label -->
    <xsl:template name="relationLink">
        <xsl:param name="field"/>
        <xsl:param name="composer"/>
        <!-- extract whatever's after the last instance of ' (' -->
        <xsl:variable name="rest">
            <xsl:call-template name="substring-after-last">
                <xsl:with-param name="string" select="$field"/>
                <xsl:with-param name="delimiter"><xsl:text> (</xsl:text></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <!-- If the link is an id, make a query -->
            <xsl:when test="starts-with($rest, 'ssm')">
                <a>
                    <xsl:attribute name="href">
                        <xsl:text>/search?query='</xsl:text>
                        <xsl:copy-of select="substring-before($rest, ')')"/>
                        <xsl:text>'</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="substring-before($field, concat(' (', $rest))"/>
                </a>
            </xsl:when>
            <!-- If the link is a handle, direct link -->
            <xsl:when test="starts-with($rest, 'http://hdl.handle.net/1911/')">
                <a>
                    <xsl:attribute name="href">
                        <xsl:text>/handle/1911/</xsl:text>
                        <xsl:value-of select="substring-before(substring-after($rest, 'http://hdl.handle.net/1911/'), ')')"/>
                    </xsl:attribute>
                    <xsl:value-of select="substring-before($field, concat(' (', $rest))"/>
                </a>
            </xsl:when>
            <!-- Otherwise, just show it the whole unaltered field as text -->
            <xsl:otherwise>
                <xsl:value-of select="$field" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Instead of the typical simple item record ("Item Metadata" table), if we're on the item page for a "piece", 
         provide a link back to the "performance" that it was from, followed by a table of "Information about this piece".
         If we're on the item page for a "performance", show a table of "Information about this performance", followed by
         links to each of the component "pieces" in the performance (if available). -->
    <xsl:template name="simple-item-record-rows">
        
        <!-- The most important part is whether this item is a performace or a piece. -->
        <xsl:variable name="itemtype">
            <xsl:choose>
                <xsl:when test="//dim:field[@element='coverage']">
                    <xsl:text>performance</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>piece</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <h3>
            <xsl:choose>
                <xsl:when test="$itemtype='performance'">
                    <!-- i18n: Information about this performance: -->
                    <i18n:text>xmlui.Shepherd.InformationAboutPerformance</i18n:text>
                </xsl:when>
                <xsl:otherwise>
                    <!-- i18n: Information about this piece: -->
                    <i18n:text>xmlui.Shepherd.InformationAboutPiece</i18n:text>
                </xsl:otherwise>
            </xsl:choose>
        </h3>

        <xsl:call-template name="itemSummaryView-DIM-authors"/>
        <xsl:call-template name="itemSummaryView-DIM-date"/>
        <xsl:call-template name="itemSummaryView-DIM-citation"/>
        <xsl:call-template name="itemSummaryView-DIM-doi"/>
        <xsl:call-template name="itemSummaryView-DIM-subject-keyword"/>
        <xsl:call-template name="itemSummaryView-DIM-abstract"/>
        <xsl:call-template name="itemSummaryView-DIM-performer"/>
        <xsl:call-template name="itemSummaryView-DIM-composer"/>
        <xsl:call-template name="itemSummaryView-DIM-performance-type"/>
        <xsl:call-template name="itemSummaryView-DIM-date-recorded"/>
        <xsl:call-template name="itemSummaryView-DIM-subject-lcsh"/>
                   <xsl:if test="$ds_item_view_toggle_url != ''">
            <xsl:call-template name="itemSummaryView-show-full"/>
        </xsl:if>
        <xsl:call-template name="itemSummaryView-collections"/>

        <!-- Ying (via MMS): Create a <span> element conforming to the Context Objects in Spans (COinS) specification. -->
        <xsl:call-template name="COinS"/>
        
        
        <!-- Parent performance -->
        <xsl:if test="$itemtype='piece'">
            <h3 class="ds-list-head">
                <!-- i18n: Forms part of the performance: -->
                <i18n:text>xmlui.Shepherd.FormsPartPerformance</i18n:text>
            </h3>
            <ul class="ds-referenceSet-list">
                <xsl:for-each select="dim:field[@element='relation' and @qualifier='ispartof']">
                    <li>
                        <xsl:call-template name="relationLink">
                            <xsl:with-param name="field" select="./node()"/>
                        </xsl:call-template>
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:if>
        
        <!-- Component pieces of the performance. -->
        <xsl:if test="dim:field[@element='relation' and @qualifier='haspart']">
            <h3 class="ds-list-head">
                <xsl:choose>
                    <xsl:when test="count(dim:field[@element='relation' and @qualifier='haspart']) &gt; 0">
                        <!-- i18n: This performance includes the following musical pieces: -->
                        <i18n:text>xmlui.Shepherd.PerformanceIncludesFollowingPieces</i18n:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- i18n: This performance includes the following musical piece: -->
                        <i18n:text>xmlui.Shepherd.PerformanceIncludesFollowingPiece</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </h3>
            <ul class="ds-referenceSet-list">
                <xsl:for-each select="dim:field[@element='relation' and @qualifier='haspart']">
                    <li>
                        <xsl:call-template name="relationLink">
                            <xsl:with-param name="field" select="./node()"/>
                        </xsl:call-template>
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:if>
    </xsl:template>


    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
        <xsl:variable name="repositoryURL" select="dri:document/dri:meta/dri:pageMeta/dri:trail[1]/@target"/>
        <xsl:variable name="bitstreamurl1" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
        <xsl:variable name="bitstreamurl" select="substring-before($bitstreamurl1, '&amp;isAllowed')"/>
        <xsl:variable name="streamingfilename">
            <xsl:value-of select="@ID"/>_<xsl:value-of select="mets:FLocat/@xlink:title"/>
        </xsl:variable>
        <xsl:variable name="filename">
            <xsl:value-of select="mets:FLocat/@xlink:title"/>
        </xsl:variable>
        <!-- The most important part is whether this item is a performace or a piece. -->
        <xsl:variable name="itemtype">
            <xsl:choose>
                <xsl:when test="//dim:field[@element='coverage']">
                    <xsl:text>performance</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>piece</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>


        <div>
            <div class="col-xs-6 col-sm-4">
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
                                                file: "<xsl:value-of select="$baseURL"/>/streaming/<xsl:value-of select='$streamingfilename'/>"
                                                },{
                                                file: "rtmp://fldp.rice.edu/fondren/mp4:<xsl:value-of select='$streamingfilename'/>"
                                                }],
                                                tracks: [{
                                                file: "<xsl:value-of select="$baseURL"/>/streaming/<xsl:value-of
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
                                                file: "<xsl:value-of select="$baseURL"/>/streaming/<xsl:value-of select='$streamingfilename'/>"
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
                                            file: "<xsl:value-of select="$baseURL"/>/streaming/<xsl:value-of select="$streamingfilename"/>"
                                            },{
                                            file: "rtmp://fldp.rice.edu/fondren/mp3:<xsl:value-of select='$streamingfilename'/>"
                                            }],
                                            tracks: [{
                                            file: "<xsl:value-of select="$baseURL"/>/streaming/<xsl:value-of
                                                select='$vtt_filename'/>",
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
                                            file: "<xsl:value-of select="$baseURL"/>/streaming/<xsl:value-of select="$streamingfilename"/>"
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
                                        <img alt="Thumbnail">
                                            <xsl:attribute name="data-src">
                                                <xsl:text>holder.js/100%x</xsl:text>
                                                <xsl:value-of select="$thumbnail.maxheight"/>
                                                <xsl:text>/text:No Thumbnail</xsl:text>
                                            </xsl:attribute>
                                        </img>
                                    </xsl:otherwise>
                                </xsl:choose>
                                </a>
                          </xsl:otherwise>
                        </xsl:choose>
                </div>
            </div>

            <div class="col-xs-6 col-sm-6">
                <dl class="file-metadata dl-horizontal">
                    <xsl:choose>
                        <xsl:when test="$itemtype='piece'">
                            <xsl:variable name="filelabel">
                            <xsl:choose>
                                <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:label, '(')">
                                    <xsl:value-of select="substring-before(mets:FLocat[@LOCTYPE='URL']/@xlink:label, ' (')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                         <!-- Get the duration text for use below. -->
                        <xsl:variable name="fileduration">
                            <xsl:choose>
                                <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:label, '(')">
                                    <xsl:variable name="raw">
                                        <xsl:call-template name="substring-after-last">
                                            <xsl:with-param name="string" select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                                            <xsl:with-param name="delimiter"><xsl:text> (</xsl:text></xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:value-of select="substring-before($raw, ')')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>--:--</xsl:text>/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <dl>
                            <dt>
                                <i18n:text>xmlui.Shepherd.Movement</i18n:text>
                                <xsl:text>:</xsl:text>
                            </dt>
                            <dd class="word-break">
                                <xsl:choose>
                                    <!-- If filesize is 0, that means this is a placeholder file whose only purpose is to provide
                                         a place to put descriptive text about why there isn't a real file here instead. -->
                                    <xsl:when test="@SIZE='0'">
                                        <p>
                                            <xsl:value-of select="$filelabel"/>
                                        </p>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                            </xsl:attribute>
                                            <xsl:attribute name="title">
                                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                                            </xsl:attribute>
                                            <xsl:value-of select="$filelabel"/>
                                        </a>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </dd>
                        <!-- File size always comes in bytes and thus needs conversion -->
                            <dt>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
                                <xsl:text>:</xsl:text>
                            </dt>
                            <dd class="word-break">
                                <!-- If filesize is 0, that means this is a placeholder file,
                                      and fill the rest of the cells with the duration info. -->
                                 <xsl:if test="@SIZE='0'">
                                     <xsl:attribute name="colspan">
                                         <xsl:text>3</xsl:text>
                                     </xsl:attribute>
                                 </xsl:if>
                             <!-- "Size" -->
                             <xsl:if test="@SIZE &gt; 0">

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
                                </xsl:if>
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

                            <xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
                                    <dt>
                                        <i18n:text>xmlui.Shepherd.Duration</i18n:text>
                                        <xsl:text>:</xsl:text>
                                    </dt>
                                    <dd class="word-break">
                                        <xsl:value-of select="$fileduration"/>
                                    </dd>
                            </xsl:if>


                        </dl>
                        </xsl:when>
                        <xsl:otherwise>
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
                                        <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:label, 30, 5)"/>
                                    </dd>
                            </xsl:if>

                            </xsl:otherwise>
                        </xsl:choose>

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
    
</xsl:stylesheet>