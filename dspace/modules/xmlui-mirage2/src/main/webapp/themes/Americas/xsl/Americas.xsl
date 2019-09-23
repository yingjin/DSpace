<?xml version="1.0" encoding="UTF-8"?>

<!--

    Rice_Centennial.xsl

    This file pulls in the Rice look-and-feel while overriding certain templates as noted in comments below.

    Authors: Sid Byrd, Ying Jin, Max Starkenburg

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

    <xsl:output indent="yes"/>

    <!-- MMS: COinS change.  Ying (via MMS): Instead of author/publisher info, display full citation.  -->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM">
        <xsl:variable name="itemWithdrawn" select="@withdrawn" />
        <div class="artifact-description">
            <div class="artifact-title">
                <!-- MMS: Moved the COinS span outside of the <a> so that the "title" tooltip text doesn't show up when hovering over the title link. -->
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
            <!-- Ying (via MMS): Instead of displaying the author and publisher information, display a full citation. -->
            <xsl:if test="dim:field[@element='identifier'][@qualifier='citation']">
                <div class="artifact-common">
                    <xsl:copy>
                        <xsl:call-template name="parse">
                            <xsl:with-param name="str" select="dim:field[@element='identifier'][@qualifier='citation'][1]/node()"/>
                            <xsl:with-param name="omit-link">1</xsl:with-param>
                        </xsl:call-template>
                    </xsl:copy>
                </div>
            </xsl:if>
        </div>
    </xsl:template>

    <!-- Ying: Updated this for our new theme -->
    <xsl:template name="simple-item-record-rows">
  <!--                    <xsl:call-template name="itemSummaryView-DIM-URI"/-->
                      <xsl:call-template name="itemSummaryView-DIM-alternative-title"/>
                      <xsl:call-template name="itemSummaryView-DIM-subtitle"/>
                      <xsl:call-template name="itemSummaryView-DIM-series"/>
                      <xsl:call-template name="itemSummaryView-DIM-authors"/>
                      <xsl:call-template name="itemSummaryView-DIM-translator"/>
                      <xsl:call-template name="itemSummaryView-DIM-abstract"/>
                      <xsl:call-template name="itemSummaryView-DIM-description"/>
                      <xsl:call-template name="itemSummaryView-DIM-date"/>
                      <xsl:call-template name="itemSummaryView-DIM-citation"/>

                      <xsl:call-template name="other-metadata"/>

                      <xsl:if test="$ds_item_view_toggle_url != ''">
                          <xsl:call-template name="itemSummaryView-show-full"/>
                      </xsl:if>
                      <xsl:call-template name="itemSummaryView-collections"/>
      </xsl:template>

        <!-- Customization for Americas: Related links -->
    <xsl:template name="other-metadata">
        <xsl:if test="descendant::dim:field[@element='relation'][@qualifier='isreferencedby' or @qualifier='isversionof' or @qualifier='isformatof' or @qualifier='isbasedon']">
        <h5>
            <!-- i18n: Related Links -->
            <i18n:text>xmlui.Rice.RelatedLinks</i18n:text>
        </h5>
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

     <!-- MMS: Give "Files in this item" table and header a CSS wrapper.  Change header size.  Change output if item is XML text.
         Copied from General-Handler.xsl with original comments removed. -->


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

       <!--
        The template to handle dri:options. Since it contains only dri:list tags (which carry the actual
        information), the only things than need to be done is creating the ds-options div and applying
        the templates inside it.

        In fact, the only bit of real work this template does is add the search box, which has to be
        handled specially in that it is not actually included in the options div, and is instead built
        from metadata available under pageMeta.
    -->
    <!-- TODO: figure out why i18n tags break the go button -->
    <xsl:template match="dri:options">
        <h1 style="margin-top: .4em; margin-bottom: 0em;">
            <a href="">Americas Archive</a>
        </h1>
        <div id="repository-link">In the <a href="/">Rice Digital Scholarship Archive</a>
        </div>
        <div id="ds-options" class="word-break">
            <xsl:if test="not(contains(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI'], 'discover'))">
                <div id="ds-search-option" class="ds-option-set">
                    <!-- The form, complete with a text box and a button, all built from attributes referenced
                 from under pageMeta. -->
                    <form id="ds-search-form" class="" method="post">
                        <xsl:attribute name="action">


                                            <xsl:text>/handle/</xsl:text><xsl:value-of select="substring-after(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='container'],':')"/>
                                            <xsl:value-of
                                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']"/>


                           </xsl:attribute>
                        <fieldset>
                            <div class="input-group">
                                <input class="ds-text-field form-control" type="text" placeholder="xmlui.general.search"
                                       i18n:attr="placeholder">
                                    <xsl:attribute name="name">
                                        <xsl:value-of
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='queryField']"/>
                                    </xsl:attribute>
                                </input>
                                <span class="input-group-btn">
                                    <button class="ds-button-field btn btn-primary" title="xmlui.general.go" i18n:attr="title">
                                        <span class="glyphicon glyphicon-search" aria-hidden="true"/>

                                    </button>
                                </span>
                            </div>

                        </fieldset>
                    </form>
                </div>
            </xsl:if>
            <xsl:apply-templates/>
            <!-- DS-984 Add RSS Links to Options Box -->
            <xsl:if test="count(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']) != 0 and count(/dri:document/dri:body/dri:div[@id='aspect.discovery.SiteRecentSubmissions.div.site-home']) = 0">
                <div>
                    <h6 class="ds-option-set-head">
                        <i18n:text>xmlui.feed.header</i18n:text>
                    </h6>
                    <div id="ds-feed-option" class="ds-option-set list-group">
                        <xsl:call-template name="addRSSLinks"/>
                    </div>
                </div>

            </xsl:if>

        </div>
    </xsl:template>

    <xsl:template name="buildHeader">


        <header>

        </header>

    </xsl:template>
        <!--xsl:template match="dri:document">
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
                            <div id="americas-main">
                                <xsl:if test="dri:body/dri:div[@n='item-view']">
                                    <xsl:attribute name="class">item-view</xsl:attribute>
                                </xsl:if>
                                <ul id="ds-trail-top">
                                    <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"/>
                                </ul>
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
    </xsl:template-->

       <!-- MMS: Footer (mostly recycled from old Rice.xsl). -->
    <xsl:template name="buildFooter">
        <div class="ds-footer">

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
                 <xsl:text>lib/images/favicon.ico</xsl:text>
             </xsl:attribute>
         </link>
         <link rel="apple-touch-icon">
             <xsl:attribute name="href">
                 <xsl:value-of select="$theme-path"/>
                 <xsl:text>lib/images/apple-touch-icon.png</xsl:text>
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
         <link rel="stylesheet" href="{concat($theme-path, 'a-styles/americas.css')}"/>

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
                 <xsl:when test="starts-with($request-uri, 'page/about')">
                     <i18n:text>xmlui.mirage2.page-structure.aboutThisRepository</i18n:text>
                 </xsl:when>
                 <xsl:when test="not($page_title)">
                     <xsl:text>  </xsl:text>
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
             <meta name="{@element}" content="{.}"></meta>
         </xsl:for-each>

     </head>
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

<xsl:template match="dri:options/dri:list//dri:list[@n='global']" priority="3">

    </xsl:template>

       <!--
        The starting point of any XSL processing is matching the root element. In DRI the root element is document,
        which contains a version attribute and three top level elements: body, options, meta (in that order).

        This template creates the html document, giving it a head and body. A title and the CSS style reference
        are placed in the html head, while the body is further split into several divs. The top-level div
        directly under html body is called "ds-main". It is further subdivided into:
            "ds-header"  - the header div containing title, subtitle, trail and other front matter
            "ds-body"    - the div containing all the content of the page; built from the contents of dri:body
            "ds-options" - the div with all the navigation and actions; built from the contents of dri:options
            "ds-footer"  - optional footer div, containing misc information

        The order in which the top level divisions appear may have some impact on the design of CSS and the
        final appearance of the DSpace page. While the layout of the DRI schema does favor the above div
        arrangement, nothing is preventing the designer from changing them around or adding new ones by
        overriding the dri:document template.
    -->
    <xsl:template match="dri:document">

        <xsl:choose>
            <xsl:when test="not($isModal)">


            <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;
            </xsl:text>
            <xsl:text disable-output-escaping="yes">&lt;!--[if lt IE 7]&gt; &lt;html class=&quot;no-js lt-ie9 lt-ie8 lt-ie7&quot; lang=&quot;en&quot;&gt; &lt;![endif]--&gt;
            &lt;!--[if IE 7]&gt;    &lt;html class=&quot;no-js lt-ie9 lt-ie8&quot; lang=&quot;en&quot;&gt; &lt;![endif]--&gt;
            &lt;!--[if IE 8]&gt;    &lt;html class=&quot;no-js lt-ie9&quot; lang=&quot;en&quot;&gt; &lt;![endif]--&gt;
            &lt;!--[if gt IE 8]&gt;&lt;!--&gt; &lt;html class=&quot;no-js&quot; lang=&quot;en&quot;&gt; &lt;!--&lt;![endif]--&gt;
            </xsl:text>

                <!-- First of all, build the HTML head element -->

                <xsl:call-template name="buildHead"/>

                <!-- Then proceed to the body -->
                <body>
                    <!-- Prompt IE 6 users to install Chrome Frame. Remove this if you support IE 6.
                   chromium.org/developers/how-tos/chrome-frame-getting-started -->
                    <!--[if lt IE 7]><p class=chromeframe>Your browser is <em>ancient!</em> <a href="http://browsehappy.com/">Upgrade to a different browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">install Google Chrome Frame</a> to experience this site.</p><![endif]-->
                    <xsl:choose>
                        <xsl:when
                                test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='framing'][@qualifier='popup']">
                            <xsl:apply-templates select="dri:body/*"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="buildHeader"/>
                            <xsl:call-template name="buildTrail"/>
                            <!--javascript-disabled warning, will be invisible if javascript is enabled-->
                            <div id="no-js-warning-wrapper" class="hidden">
                                <div id="no-js-warning">
                                    <div class="notice failure">
                                        <xsl:text>JavaScript is disabled for your browser. Some features of this site may not work without it.</xsl:text>
                                    </div>
                                </div>
                            </div>

                            <div id="main-container" class="container">

                                <div class="row row-offcanvas row-offcanvas-right">
                                    <div class="horizontal-slider clearfix">
                                        <div class="col-xs-12 col-sm-12 col-md-9 main-content">
                                            <xsl:apply-templates select="*[not(self::dri:options)]"/>

                                            <div class="visible-xs visible-sm">
                                                <xsl:call-template name="buildFooter"/>
                                            </div>
                                        </div>
                                        <div class="col-xs-6 col-sm-3 sidebar-offcanvas" id="sidebar" role="navigation">
                                            <xsl:apply-templates select="dri:options"/>
                                        </div>

                                    </div>
                                </div>

                                <!--
                            The footer div, dropping whatever extra information is needed on the page. It will
                            most likely be something similar in structure to the currently given example. -->
                            <div class="hidden-xs hidden-sm">
                            <xsl:call-template name="buildFooter"/>
                             </div>
                         </div>


                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- Javascript at the bottom for fast page loading -->
                    <xsl:call-template name="addJavascript"/>
                </body>
                <xsl:text disable-output-escaping="yes">&lt;/html&gt;</xsl:text>

            </xsl:when>
            <xsl:otherwise>
                <!-- This is only a starting point. If you want to use this feature you need to implement
                JavaScript code and a XSLT template by yourself. Currently this is used for the DSpace Value Lookup -->
                <xsl:apply-templates select="dri:body" mode="modal"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
