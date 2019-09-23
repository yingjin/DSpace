<?xml version="1.0" encoding="UTF-8"?>

<!-- 

    TIMEA.xsl
    
    Stylesheet for the Travelers in the Middle East Archive (TIMEA) theme.
    
    Authors: Sid Byrd, Lisa Spiro, et al.?

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
    
    <!--xsl:import href="../dri2xhtml.xsl"/-->
    <xsl:output indent="yes"/>


        <!-- MMS: Add extra zero-item CSS hook, and add clearing div under certain circumstances. -->
    <!-- Ying add structMap section to external mets object -->
   <xsl:template match="dri:reference" mode="summaryList">
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="@url"/>
            <!-- Since this is a summary only grab the descriptive metadata, and the thumbnails -->
            <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL,structMap</xsl:text>
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

	<!-- override structural.xsl to change id of main body div -->
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
                        <div class="container">
                            <xsl:call-template name="buildHeader"/>
                            <xsl:apply-templates/>
                            <xsl:call-template name="buildFooter"/>
                            
                        </div>
                    </body>
                </xsl:otherwise>
            </xsl:choose>
        </html>
    </xsl:template-->

    <!-- override structural.xsl to add "TIMEA: " prefix to page title -->
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
         <link rel="stylesheet" href="{concat($theme-path, 't-styles/timea.css')}"/>

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

        <!-- TIMEA content header is completely different from standard manakin content header -->
    <xsl:template name="buildHeader">
        <div class="header">
			<a href="http://timea.rice.edu">
				<img alt=" TIMEA  Spelled Out:  TIMEA (Travelers in the Middle East Archive) Home"
					class="timeaLogoText"
					id="TimeaLogoText">
					<xsl:attribute name="src">
						<xsl:value-of
							select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
						<xsl:text>/themes/</xsl:text>
						<xsl:value-of
							select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
						<xsl:text>/t-images/timeaheader.gif</xsl:text>
					</xsl:attribute>
				</img>
			</a>
			<a href="http://timea.rice.edu">
				<img alt="TIMEA Logo: TIMEA (Travelers in the Middle East Archive) Home"
					class="timeaLogo">
					<xsl:attribute name="src">
						<xsl:value-of
							select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
						<xsl:text>/themes/</xsl:text>
						<xsl:value-of
							select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
						<xsl:text>/t-images/logo.jpg</xsl:text>
					</xsl:attribute>
				</img>
			</a>

			<span id="mainMenu" class="mainMenu">
				<a href="http://timea.rice.edu/index.html">Home </a>
				<a href="http://timea.rice.edu/browse.jsp">Browse </a>
				<a href="http://timea.rice.edu/about.html">About </a>
				<a href="http://timea.rice.edu/contact.html"> Contact </a>
				<a href="http://timea.rice.edu/help.html">Help</a>
			</span>

			<div class="searchForm" id="searchbox">
				<form name="search" action="http://timea.rice.edu/results.jsp"
					method="get">
					<div>
						<input type="text" name="query" maxlength="1000" size="18"/>
						<input type="submit" name="submit" value="Search"/>
					</div>
					<div class="advancedSearch">
						<a href="http://timea.rice.edu/advancedsearch.jsp"
							class="submit">Advanced Search</a>
					</div>
				</form>
			</div>
        </div>
    </xsl:template>

     <xsl:template name="buildHeader--m2">


        <header>
            <div class="navbar navbar-default navbar-static-top" role="navigation">
                <div class="container">
                    <div class="navbar-header">
                        <div class="header">
			<a href="http://timea.rice.edu">
				<img alt=" TIMEA  Spelled Out:  TIMEA (Travelers in the Middle East Archive) Home"
					class="timeaLogoText"
					id="TimeaLogoText">
					<xsl:attribute name="src">
						<xsl:value-of
							select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
						<xsl:text>/themes/</xsl:text>
						<xsl:value-of
							select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
						<xsl:text>/images/timeaheader.gif</xsl:text>
					</xsl:attribute>
				</img>
			</a>
			<a href="http://timea.rice.edu">
				<img alt="TIMEA Logo: TIMEA (Travelers in the Middle East Archive) Home"
					class="timeaLogo">
					<xsl:attribute name="src">
						<xsl:value-of
							select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
						<xsl:text>/themes/</xsl:text>
						<xsl:value-of
							select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
						<xsl:text>/images/logo.jpg</xsl:text>
					</xsl:attribute>
				</img>
			</a>

			<span id="mainMenu" class="mainMenu">
				<a href="http://timea.rice.edu/index.html">Home </a>
				<a href="http://timea.rice.edu/browse.jsp">Browse </a>
				<a href="http://timea.rice.edu/about.html">About </a>
				<a href="http://timea.rice.edu/contact.html"> Contact </a>
				<a href="http://timea.rice.edu/help.html">Help</a>
			</span>

			<div class="searchForm" id="searchbox">
				<form name="search" action="http://timea.rice.edu/results.jsp"
					method="get">
					<div>
						<input type="text" name="query" maxlength="1000" size="18"/>
						<input type="submit" name="submit" value="Search"/>
					</div>
					<div class="advancedSearch">
						<a href="http://timea.rice.edu/advancedsearch.jsp"
							class="submit">Advanced Search</a>
					</div>
				</form>
			</div>
        </div>
                        <!--button type="button" class="navbar-toggle" data-toggle="offcanvas">
                            <span class="sr-only">
                                <i18n:text>xmlui.mirage2.page-structure.toggleNavigation</i18n:text>
                            </span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                        </button>

                        <a href="{$context-path}/" class="navbar-brand">

                            <img width="" height="" src="{$theme-path}/t-images/timeaheader.gif" />
                        </a-->


                        <!--div class="navbar-header pull-right visible-xs hidden-sm hidden-md hidden-lg">
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
                          <a href="http://bit.ly/RDSA-FAQ" ><span class="hidden-xs">FAQ</span></a>
                         </li>
                            <li> </li>

                        </ul>
                        <ul class="nav navbar-nav pull-left">
                            <li>
                          <a href="http://openaccess.rice.edu/ir-submission-process/" ><span class="glyphicon glyphicon-import" aria-hidden="true"></span><span class="hidden-xs"> Deposit your work</span></a>
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
                        </button-->
                    </div>
                </div>
            </div>

        </header>

    </xsl:template>

    <!-- The header (distinct from the HTML head element) contains the title, subtitle, login box and various
        placeholders for header images -->
    <xsl:template name="buildTrail">  </xsl:template>

   <xsl:template match="dri:options">
        <div id="ds-options" class="word-break">

            <xsl:apply-templates/>
            <!-- DS-984 Add RSS Links to Options Box -->
            <xsl:if test="count(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']) != 0">
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


	<!-- TIMEA footer is completely different -->
    <xsl:template name="buildFooter">
    	<div class="footer">
			<p>TIMEA is supported by the <a href="http://www.imls.gov">Institute of
			    Museum and Library Services</a>, <a href="http://citi.rice.edu">CITI</a>,
			    and <a href="http://www.rice.edu">Rice University</a>.
			</p>
			<p>
				<!--Creative Commons License-->
				<a rel="license" href="http://creativecommons.org/licenses/by/2.5/">
					<img alt="Creative Commons License" border="0"
						src="http://creativecommons.org/images/public/somerights20.png"
					/>
				</a>
				<br/>
				This work is licensed under a
				<a rel="license" href="http://creativecommons.org/licenses/by/2.5/">
					Creative Commons Attribution 2.5 License
				</a>.
			</p>
		</div>
    </xsl:template>
    
    <!-- Overriding from structural.xsl to remove the header resizing tricks being done there. 
         MMS: This had been done in structural.xsl, but that file is not an appropriate place to put customizations. -->
    <xsl:template match="dri:div/dri:head" priority="3">
        <xsl:variable name="head_count" select="count(ancestor::dri:div)"/>
        <xsl:element name="h{$head_count}">
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">ds-div-head</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>
    
    <!-- don't show top link to full/detail view on item pages -->
    <!--xsl:template match="dri:p[@rend='item-view-toggle item-view-toggle-top']"/-->
    
    <!-- Overridden to remove publisher metadata -->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM"> 
        <div class="artifact-description">
            <div class="artifact-title">
                <a href="{ancestor::mets:METS/@OBJID}">
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title']">
                            <xsl:value-of select="dim:field[@element='title'][1]/child::node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
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
                                <xsl:copy-of select="."/>
                                <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='contributor']">
                            <xsl:for-each select="dim:field[@element='contributor']">
                                <xsl:copy-of select="."/>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
                <xsl:text> </xsl:text>
                <span class="publisher-date">
                    <xsl:text>(</xsl:text>
                    <span class="date">
                        <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/child::node(),1,10)"/>
                    </span>
                    <xsl:text>)</xsl:text>
                </span>
            </div>
        </div>
    </xsl:template>
    
    <!-- Override to remove license info.
         Also, the file section now comes before the metadata section. -->
    <xsl:template name="itemSummaryView-DIM">
        <!-- Generate the bitstream information from the file section -->
        <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT']" mode="itemSummaryView-DIM">
            <xsl:with-param name="context" select="."/>
            <xsl:with-param name="primaryBitream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
        </xsl:apply-templates>

        <h3 class="heading">
            About this item
        </h3>
        
        <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
            mode="itemSummaryView-DIM"/>
     </xsl:template>
    
    <!-- Generate the info about the item from the metadata section -->
    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
        <table id="metadata" class="textreg">
            <tr class="ds-table-row odd">
                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-title</i18n:text>:</span></td>
                <td>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title']">
                            <xsl:value-of select="dim:field[@element='title'][1]/child::node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
            <tr class="ds-table-row even">
                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text>:</span></td>
                <td>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='creator']">
                            <xsl:for-each select="dim:field[@element='creator']">
                                <xsl:copy-of select="."/>
                                <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
            <tr class="ds-table-row odd">
                <td><span class="bold"><i18n:text>Summary</i18n:text>:</span></td>
                <td><xsl:copy-of select="dim:field[@element='description' and @qualifier='abstract']/child::node()"/></td>
            </tr>
            <tr class="ds-table-row even">
                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text>:</span></td>
                <td>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:copy-of select="dim:field[@element='identifier' and @qualifier='uri'][1]/child::node()"/>
                        </xsl:attribute>
                        <xsl:copy-of select="dim:field[@element='identifier' and @qualifier='uri'][1]/child::node()"/>
                    </a>
                </td>
            </tr>
            <tr class="ds-table-row odd">
                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>:</span></td>
                <td><xsl:copy-of select="substring(dim:field[@element='date' and @qualifier='issued']/child::node(),1,10)"/></td>
            </tr>
            <tr class="ds-table-row even">
                <td><span class="bold"><i18n:text>Original Source</i18n:text></span></td>
                <td><xsl:copy-of select="dim:field[@element ='source' and @qualifier = 'original']/child::node()"/></td>
            </tr>
            <!--include multiple subject terms if necessary-->
            <tr class="ds-table-row odd">
                <td><span class="bold"><i18n:text>Subject</i18n:text></span></td>
                <td>
                <xsl:for-each select="dim:field[@element='subject' and @qualifier='lcsh']">
                    <xsl:copy-of select="."/>
                    <xsl:if test="count(following-sibling::dim:field[@element='subject'][@qualifier='lcsh']) != 0">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </xsl:for-each>
                </td>
            </tr>
            <xsl:for-each select="dim:field[@element='relation'][@qualifier='isreferencedby']
                | dim:field[@element='relation'][@qualifier='ispartof']">
                <xsl:variable name="linkname" select="substring-before(.,  ' at ')"/>
                <xsl:variable name="url" select="substring-after(.,  ' at ')"/>
                <xsl:if test="starts-with($url, 'http://')">
                    <!-- TODO fix odd/even -->
                    <tr class="ds-table-row even">
                        <td><span class="bold"><i18n:text>Related Resource</i18n:text></span></td>
                        <td>
                            <a target="_new">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="$url"/>
                                </xsl:attribute>
                                <xsl:value-of select="$linkname"/>
                            </a>
                        </td>
                    </tr>
                </xsl:if>
            </xsl:for-each>
            <!-- TODO fix odd/even -->
            <tr class="ds-table-row odd">
                <td><span class="bold"><i18n:text>About This Resource</i18n:text>:</span></td>
                <td>
                    <xsl:copy-of select="dim:field[@element='relation'][@qualifier='ispartofseries'][1]/child::node()"/>
                </td>
            </tr>
        </table>
        <xsl:call-template name="citation">
            <xsl:with-param name="dim" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="citation">
        <xsl:param name="dim"/>
        
        <h3 class="heading">Citation</h3>
        <div class="textreg">
            <span class="author"><xsl:value-of select="$dim/dim:field[@element='creator']/child::node()"/></span>
            <span class="titleital">
                <xsl:choose>
                    <xsl:when test="$dim/dim:field[@element='title']">
                        <xsl:copy-of select="$dim/dim:field[@element='title'][1]/child::node()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
            <span class="date">
                <xsl:text>(</xsl:text>
                <xsl:copy-of select="$dim/dim:field[@element='date'][@qualifier='issued']/child::node()"/>
                <xsl:text>). </xsl:text>
            </span>
            <br />
            <xsl:text>From </xsl:text>
            <a>
                <xsl:attribute name="href">http://timea.rice.edu</xsl:attribute>
                <xsl:text>Travelers in the Middle East Archive (TIMEA)</xsl:text>
            </a>
            <xsl:text>. </xsl:text>
            <span class="citation-link">
                <a>
                    <xsl:attribute name="href">
                        <xsl:copy-of select="$dim/dim:field[@element='identifier'][@qualifier='uri'][1]/child::node()"/>
                    </xsl:attribute>
                    <xsl:copy-of select="$dim/dim:field[@element='identifier'][@qualifier='uri'][1]/child::node()"/>
                </a>
                <br />
                <xsl:text>For more on properly formatting citations, see </xsl:text>
                <a href="http://timea.rice.edu/citations.html">Citing TIMEA Resources</a>
                <xsl:text>.</xsl:text>
            </span>
        </div>
    </xsl:template>
    
    <!-- Generate the bitstream information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='CONTENT']" mode="itemSummaryView-DIM">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitream" select="-1"/>
        
        <h3 class="heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h3>
        <table class="textreg">
            <xsl:choose>
                <!-- if this is an XML text, present a special file table -->
                <xsl:when test="mets:file[@ID=$primaryBitream]/@MIMETYPE='text/xml' and 
                    $context/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='format' and @qualifier='xmlschema']">
                    <xsl:apply-templates select="mets:file[@ID=$primaryBitream]" mode="xml-text">
                        <xsl:with-param name="context" select="$context"/>
                        <xsl:with-param name="schema">tei-timea</xsl:with-param>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- normal TIMEA file table -->
                <xsl:otherwise>
                    <tr>
                        <th>File</th>
                        <th>Description</th>
                    </tr>
                    <xsl:apply-templates select="mets:file" mode="itemSummaryView-DIM">
                        <xsl:sort select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/> 
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                    <!-- add help link -->
                    <tr>
                        <xsl:attribute name="class">ds-table-row"</xsl:attribute>
                        <td><a href="/help/index.html">Need help?</a></td>
                        <td></td>
                    </tr>
                </xsl:otherwise>
            </xsl:choose>
        </table>
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
                    <!-- i18n: View Online -->
                    <i18n:text>xmlui.Rice.ViewOnline</i18n:text>
                </a>
                <xsl:text> </xsl:text>
                <!-- i18n: (witih pages images) -->
                <i18n:text>xmlui.Rice.WithPageImages</i18n:text>
            </td>
        </tr>
        <tr class="mark-up even">
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
    
    
    <!-- Build a single row in the bitsreams table of the item view page -->
    <xsl:template match="mets:file" mode="itemSummaryView-DIM">
        <xsl:param name="context" select="."/>
        <tr>
            <xsl:attribute name="class">
                <xsl:text>ds-table-row </xsl:text>
                <xsl:if test="(position() mod 2 = 0)">even </xsl:if>
                <xsl:if test="(position() mod 2 = 1)">odd </xsl:if>
            </xsl:attribute>
            <td>
                <xsl:choose>
                    <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                        <a class="image-link">
                            <xsl:attribute name="href">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:attribute>
                            <img alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                        mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                </xsl:attribute>
                            </img>
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
            </td>
            <td>
                <xsl:value-of select="mets:FLocat/@xlink:label"/>
            </td>
        </tr>
    </xsl:template>
    
    <!-- overridden to provide a separate dim:dim mode="itemDetailView" for the file table. Normally this
        template just calls the dim:dim mode="itemSummaryView" template.
        Also, the file section now comes before the metadata section. -->
    <xsl:template name="itemDetailView-DIM">
        
        <!-- Generate the bitstream information from the file section -->
        <!-- SWB this is the line that changed -->
        <xsl:apply-templates select="mets:fileSec/mets:fileGrp[@USE='CONTENT']" mode="itemDetailView-DIM">
            <xsl:with-param name="context" select="."/>
            <xsl:with-param name="primaryBitream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
        </xsl:apply-templates>
        
        <h3 class="heading">
            About this item
        </h3>
        
        <!-- Output all of the metadata about the item from the metadata section -->
        <xsl:apply-templates select="mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
            mode="itemDetailView-DIM"/>
        
        <!-- Generate the license information from the file section -->
        <!--<xsl:apply-templates select="mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']" mode="itemSummaryView-DIM"/>-->
        
    </xsl:template>
    

    <!-- SWB added header row, skip junk metadata -->
    <xsl:template match="dim:dim" mode="itemDetailView-DIM">
        <table class="textreg">
            <tr>
                <th>
                    <a href="http://dublincore.org/">Dublin Core Field</a>
                </th>
                <th>Metadata</th>
            </tr>
            <xsl:apply-templates select="dim:field[not (@element='contributor' and @qualifier='author')
                                               and not (@element='description' and @qualifier='provenance')
                                               and not (@element='format' and @qualifier='extent')
                                               and not (@element='format' and @qualifier='mimetype')]"
                mode="itemDetailView-DIM"/>
        </table>
        <xsl:call-template name="citation">
            <xsl:with-param name="dim" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- make .isreferencedby data into links -->
    <xsl:template match="dim:field" mode="itemDetailView-DIM">
        <tr>
            <xsl:attribute name="class">
                <xsl:text>ds-table-row </xsl:text>
                <xsl:if test="(position() mod 2 = 0)">even </xsl:if>
                <xsl:if test="(position() mod 2 = 1)">odd </xsl:if>
            </xsl:attribute>
            <td>
                <xsl:value-of select="./@element"/>
                <xsl:if test="./@qualifier">
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="./@qualifier"/>
                </xsl:if>
            </td>
            <!--LMS: Added so that links render properly-->
            <td>
                <xsl:choose>
                    <xsl:when test="@qualifier='isreferencedby' or @qualifier='ispartof'">
                        <xsl:variable name="linkname" select="substring-before(.,  ' at ')"/>
                        <xsl:variable name="url" select="substring-after(.,  ' at ')"/>
                        <xsl:if test="starts-with($url, 'http://')">
                            <a target="new">
                            <xsl:attribute name="href">
                                <xsl:value-of select="$url"/>
                            </xsl:attribute>
                            <xsl:value-of select="$linkname"/>
                            </a>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="./child::node()"/>
                    </xsl:otherwise>
                </xsl:choose> 
            </td>
            <!-- omit language display -->
        </tr>
    </xsl:template>
 
    <!-- Generate the bitstream information from the file section -->
    <!-- the original version didn't have a separate itemDetailView template here, instead using itemSummeryView for both. -->
    <xsl:template match="mets:fileGrp[@USE='CONTENT']" mode="itemDetailView-DIM">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitream" select="-1"/>
        
        <h3 class="heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h3>
        <table class="textreg">
            <xsl:choose>
                <!-- if this is an XML text, present a special file table -->
                <xsl:when test="mets:file[@ID=$primaryBitream]/@MIMETYPE='text/xml' and 
                    $context/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='format' and @qualifier='xmlschema']">
                    <xsl:apply-templates select="mets:file[@ID=$primaryBitream]" mode="xml-text">
                        <xsl:with-param name="context" select="$context"/>
                        <xsl:with-param name="schema">tei-timea</xsl:with-param>
                    </xsl:apply-templates>
                </xsl:when>
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
                    <xsl:apply-templates select="mets:file" mode="itemDetailView-DIM">
                        <xsl:sort select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/> 
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </table>
    </xsl:template>
    
    <!-- Build a single row in the bitsreams table of the item view page -->
    <!-- SWB this is the original (not TIMEA) itemSummaryView version unmodified. 
         In the original version, there wasn't a separate itemDetailView of this. -->
    <xsl:template match="mets:file" mode="itemDetailView-DIM">
        <xsl:param name="context" select="."/>
        <tr>
            <xsl:attribute name="class">
                <xsl:text>ds-table-row </xsl:text>
                <xsl:if test="(position() mod 2 = 0)">even </xsl:if>
                <xsl:if test="(position() mod 2 = 1)">odd </xsl:if>
            </xsl:attribute>
            <td>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                    </xsl:attribute>
                    <xsl:attribute name="title">
                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="string-length(mets:FLocat[@LOCTYPE='URL']/@xlink:title) > 50">
                            <xsl:variable name="title_length" select="string-length(mets:FLocat[@LOCTYPE='URL']/@xlink:title)"/>
                            <xsl:value-of select="substring(mets:FLocat[@LOCTYPE='URL']/@xlink:title,1,15)"/>
                            <xsl:text> ... </xsl:text>
                            <xsl:value-of select="substring(mets:FLocat[@LOCTYPE='URL']/@xlink:title,$title_length - 25,$title_length)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
            </td>
            <!-- File size always comes in bytes and thus needs conversion --> 
            <td>
                <xsl:choose>
                    <xsl:when test="@SIZE &lt; 1000">
                        <xsl:value-of select="@SIZE"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="@SIZE &lt; 1000000">
                        <xsl:value-of select="substring(string(@SIZE div 1000),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="@SIZE &lt; 1000000000">
                        <xsl:value-of select="substring(string(@SIZE div 1000000),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(string(@SIZE div 1000000000),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <!-- Currently format carries forward the mime type. In the original DSpace, this 
                would get resolved to an application via the Bitstream Registry, but we are
                constrained by the capabilities of METS and can't really pass that info through. -->
            <td><xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
            </td>
            <td>
                <xsl:choose>
                    <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                        <a class="image-link">
                            <xsl:attribute name="href">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:attribute>
                            <img alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                        mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                </xsl:attribute>
                            </img>
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
            </td>
            <!-- Display the contents of 'Description' as long as at least one bitstream contains a description -->
            <xsl:if test="$context/mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat/@xlink:label != ''">
                <td>
                    <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                </td>
            </xsl:if>
        </tr>
    </xsl:template>
    
    <!-- oerridden to remove copyright display -->
    <xsl:template match="dim:dim" mode="collectionDetailView-DIM"> 
        <xsl:if test="string-length(dim:field[@element='description'][not(@qualifier)])&gt;0">
            <p class="intro-text">
                <xsl:copy-of select="dim:field[@element='description'][not(@qualifier)]/node()"/>
            </p>
        </xsl:if>
    </xsl:template>
    
    <!-- oerridden to remove copyright display -->
    <xsl:template match="dim:dim" mode="communityDetailView-DIM"> 
        <xsl:if test="string-length(dim:field[@element='description'][not(@qualifier)])&gt;0">
            <p class="intro-text">
                <xsl:copy-of select="dim:field[@element='description'][not(@qualifier)]/node()"/>
            </p>
        </xsl:if>
    </xsl:template>
    
    
    
    
    
    
    
    
    
    
    <!-- Special template to remove the old search box if the TDL filter search one is present -->
    <xsl:template match="dri:div[@n = 'collection-search'][following-sibling::dri:div[@n =
        'collection-filter-search']]">
        <!-- Match the special case and do nothing -->
    </xsl:template>
    <!-- Special template to remove the old search box if the TDL filter search one is present -->
    <xsl:template match="dri:div[@n = 'community-search'][following-sibling::dri:div[@n =
        'community-filter-search']]">
        <!-- Match the special case and do nothing -->
    </xsl:template>
    
</xsl:stylesheet>
