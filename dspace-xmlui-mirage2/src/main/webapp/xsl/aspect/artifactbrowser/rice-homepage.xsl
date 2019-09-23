<?xml version="1.0" encoding="UTF-8"?>

<!--
    
    rice-homepage.xsl
    
    Description: This file contains our customized theme for the home page.
    
    Author: Ying Jin

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

    <xsl:param name="browser" />

     <xsl:variable name="repositoryURL" select="dri:document/dri:meta/dri:pageMeta/dri:trail[1]/@target"/>

    <xsl:template name="disable_frontpage_browse" match="dri:div[@id='aspect.artifactbrowser.CommunityBrowser.div.comunity-browser']">
    <xsl:if test="not(//dri:body/dri:div[@id='file.news.div.news'])">
        <xsl:apply-templates/>
    </xsl:if>
    </xsl:template>

    <!--xsl:template name="disable_front-page-search" match="dri:div[@id='aspect.discovery.SiteViewer.div.front-page-search']"-->
    <!-- Lets put all our home page customizations here !!! -->
<xsl:template match="dri:div[@id='aspect.discovery.SiteRecentSubmissions.div.site-home']">
     <script type="text/javascript">
  $('.carousel').carousel({
   interval: 10000
  });
 </script>
  <div class="bs-example col-md-12">
    <div id="carousel-example-generic" class="carousel slide" data-ride="carousel">
      <ol class="carousel-indicators">
        <li data-target="#carousel-example-generic" data-slide-to="0" class="active"></li>
        <li data-target="#carousel-example-generic" data-slide-to="1"></li>
        <li data-target="#carousel-example-generic" data-slide-to="2"></li>
          <li data-target="#carousel-example-generic" data-slide-to="3"></li>
          <li data-target="#carousel-example-generic" data-slide-to="4"></li>
          <li data-target="#carousel-example-generic" data-slide-to="5"></li>
          <!--li data-target="#carousel-example-generic" data-slide-to="6"></li>
          <li data-target="#carousel-example-generic" data-slide-to="7"></li>
          <li data-target="#carousel-example-generic" data-slide-to="8"></li>
          <li data-target="#carousel-example-generic" data-slide-to="9"></li>
          <li data-target="#carousel-example-generic" data-slide-to="10"></li-->
      </ol>
      <div class="carousel-inner" role="listbox">
        <div class="item active">
          <a href="http://openaccess.rice.edu/"><img src="{$theme-path}/images/Dspace-slide-01.png" alt="Open Access Policy"/>  </a>
        </div>
        <div class="item">
            <a href="http://bit.ly/RiceArchive-FAQ"><img src="{$theme-path}/images/Dspace-slide-02.png" alt="FAQ"/>  </a>
        </div>
        <div class="item">
            <a href="{$repositoryURL}/handle/1911/75172"><img src="{$theme-path}/images/Dspace-slide-03.png" alt="Recent Faculty Work"/>   </a>
        </div>
          <div class="item">
              <a href="{$repositoryURL}/handle/1911/9219"><img src="{$theme-path}/images/Dspace-slide-04.png" alt="Americas"/>  </a>
              <!--div class="carousel-caption">
        <h3>Flowers</h3>
        <p>Beatiful flowers in Kolymbari, Crete.</p>
      </div-->
          </div>
          <!--div class="item">
              <a href="{$repositoryURL}/handle/1911/9219"><img src="{$theme-path}/images/Dspace-slide-05.png" alt=""/>  </a>
          </div>
          <div class="item">
              <a href="{$repositoryURL}/handle/1911/9219 "><img src="{$theme-path}/images/Dspace-slide-06.png" alt=""/>   </a>
          </div>
          <div class="item">
              <a href="{$repositoryURL}/handle/1911/9219"><img src="{$theme-path}/images/Dspace-slide-07.png" alt=""/>  </a>
          </div>
          <div class="item">
              <a href="{$repositoryURL}/handle/1911/61548"><img src="{$theme-path}/images/Dspace-slide-08.png" alt=""/>  </a>
          </div>
          <div class="item">
              <a href="{$repositoryURL}/handle/1911/12394"><img src="{$theme-path}/images/Dspace-slide-09.png" alt=""/>   </a>
          </div-->
          <div class="item">
              <a href="{$repositoryURL}/handle/1911/43628"><img src="{$theme-path}/images/Dspace-slide-05.png" alt="Shepherd Music"/>  </a>
          </div>
          <div class="item">
              <a href="http://openaccess.rice.edu/"><img src="{$theme-path}/images/Dspace-slide-06.png" alt="open access"/>  </a>
          </div>
      </div>
      <a class="left carousel-control" href="#carousel-example-generic" role="button" data-slide="prev">
        <span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>
        <span class="sr-only">Previous</span>
      </a>
      <a class="right carousel-control" href="#carousel-example-generic" role="button" data-slide="next">
        <span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span>
        <span class="sr-only">Next</span>
      </a>
    </div>
  </div>

       <br />  <br />
        <h2 class="ds-div-head page-header first-page-header">Welcome to Rice University's digital scholarship archive</h2>
        <div id="file.news.div.news" class="ds-static-div primary">

			<p>This is Rice's institutional repository, a web site where the university's intellectual output
				is shared, managed, searched, and preserved. Most materials come from Rice faculty members'
				research, electronic theses and dissertations, and digitized collections of rare or unique books,
				images, musical performances, and manuscripts. The archive runs on DSpace, an open source software package.</p>
			<p>Do you have questions about this archive?  Read our
				<a href="http://bit.ly/RiceArchive-FAQ">FAQ</a>.</p>
        </div>



<div class="container-fluid">
  <div class="row">
    <div class="col-md-4"><a href="{$repositoryURL}/handle/1911/75172"><img src="{$theme-path}/images/Dspace-6tiles-ying-1.png" class="img-responsive" alt="Faculty and Staff Research" /></a></div>
    <div class="col-md-4"><a href="{$repositoryURL}/handle/1911/8299"><img src="{$theme-path}/images/Dspace-6tiles-ying-2.gif" class="img-responsive" alt="Rice Theses and Dissertations" /></a></div>
    <div class="col-md-4"><a href="{$repositoryURL}/handle/1911/64041"><img src="{$theme-path}/images/Dspace-6tiles-ying-3.gif" class="img-responsive" alt="University Archives and Rice History" /></a></div>
  </div>
   <br/>
  <div class="row">
    <div class="col-md-4"><a href="{$repositoryURL}/handle/1911/79049"><img src="{$theme-path}/images/Dspace-6tiles-ying-4.gif" class="img-responsive" alt="Publications and Performances" /></a></div>
    <div class="col-md-4"><a href="{$repositoryURL}/handle/1911/26795"><img src="{$theme-path}/images/Dspace-6tiles-ying-5.gif" class="img-responsive" alt="Graduate and Undergraduate Student Research" /></a></div>
    <div class="col-md-4"><a href="{$repositoryURL}/handle/1911/79050"><img src="{$theme-path}/images/Dspace-6tiles-ying-6.gif" class="img-responsive" alt="Cultural Heritage Collections" /></a></div>
  </div>
</div>
    </xsl:template>


     <!--xsl:template match="dri:div[@id='aspect.discovery.SiteRecentSubmissions.div.site-home']"> </xsl:template-->


     <!-- Disable Discovery facets on the home page -->
    <!--xsl:template match="dri:options/dri:list[@id='aspect.discovery.Navigation.list.discovery']" priority="5">
        <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request' and @qualifier='URI'] != ''">   -->
            <!-- Copied from the next rule (dri:options/dri:list[dri:list]). -->
   <!--         <xsl:apply-templates select="dri:head"/>
            <div>
                <xsl:call-template name="standardAttributes">
                    <xsl:with-param name="class">ds-option-set</xsl:with-param>
                </xsl:call-template>
                <ul class="ds-options-list">
                    <xsl:apply-templates select="*[not(name()='head')]" mode="nested"/>
                </ul>
            </div>
        </xsl:if>
    </xsl:template-->

    <xsl:template match="dri:options/dri:list[@id='aspect.discovery.Navigation.list.discovery']" priority="5">
        <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request' and @qualifier='URI'] != ''">
            <!-- Copied from the next rule (dri:options/dri:list[dri:list]). -->
            <xsl:apply-templates select="dri:head"/>
            <div>
                <xsl:call-template name="standardAttributes">
                    <xsl:with-param name="class">ds-option-set</xsl:with-param>
                </xsl:call-template>
                <div class="ds-option-set list-group">
                    <xsl:apply-templates select="*[not(name()='head')]"/>
                </div>
            </div>
        </xsl:if>
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
        <div id="ds-options" class="word-break">
            <xsl:if test="not(contains(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI'], 'discover'))">
                <div id="ds-search-option" class="ds-option-set">
                    <!-- The form, complete with a text box and a button, all built from attributes referenced
                 from under pageMeta. -->
                    <form id="ds-search-form" class="" method="post" title="search form">
                        <xsl:attribute name="action">
                            <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>
                            <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']"/>
                        </xsl:attribute>
                        <fieldset>
                            <legend>Searching scope</legend>
                            <div class="input-group">
                                <label for="query" class="visuallyhidden"><xsl:text>Search: </xsl:text></label>
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
                                        <xsl:attribute name="onclick">
                                                    <xsl:text>
                                                        var radio = document.getElementById(&quot;ds-search-form-scope-container&quot;);
                                                        if (radio != undefined &amp;&amp; radio.checked)
                                                        {
                                                        var form = document.getElementById(&quot;ds-search-form&quot;);
                                                        form.action=
                                                    </xsl:text>
                                            <xsl:text>&quot;</xsl:text>
                                            <xsl:value-of
                                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>
                                            <xsl:text>/handle/&quot; + radio.value + &quot;</xsl:text>
                                            <xsl:value-of
                                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']"/>
                                            <xsl:text>&quot; ; </xsl:text>
                                                    <xsl:text>
                                                        }
                                                    </xsl:text>
                                        </xsl:attribute>
                                    </button>
                                </span>
                            </div>

                            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='container']">
                                <div class="radio">
                                    <label>
                                        <input id="ds-search-form-scope-all" type="radio" name="scope" value=""
                                               checked="checked"/>
                                        <i18n:text>xmlui.dri2xhtml.structural.search</i18n:text>
                                    </label>
                                </div>
                                <div class="radio">
                                    <label>
                                        <input id="ds-search-form-scope-container" type="radio" name="scope">
                                            <xsl:attribute name="value">
                                                <xsl:value-of
                                                        select="substring-after(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='container'],':')"/>
                                            </xsl:attribute>
                                        </input>
                                        <xsl:choose>
                                            <xsl:when
                                                    test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='containerType']/text() = 'type:community'">
                                                <i18n:text>xmlui.dri2xhtml.structural.search-in-community</i18n:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <i18n:text>xmlui.dri2xhtml.structural.search-in-collection</i18n:text>
                                            </xsl:otherwise>

                                        </xsl:choose>
                                    </label>
                                </div>
                            </xsl:if>
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
</xsl:stylesheet>




















