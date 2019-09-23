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
    
    It differs from reusable-new-templates.xsl in that it contains overrides of templates that have 
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

    <xsl:param name="browser" />
    <xsl:variable name="request-uri" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI']"/>


        <!--
        The template to handle the dri:body element. It simply creates the ds-body div and applies
        templates of the body's child elements (which consists entirely of dri:div tags).
    -->
    <xsl:template match="dri:body">
        <div>
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']">
                <div class="alert">
                    <button type="button" class="close" data-dismiss="alert">&#215;</button>
                    <xsl:copy-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']/node()"/>
                </div>
            </xsl:if>

            <!-- Check for the custom pages -->
            <xsl:choose>
                <xsl:when test="starts-with($request-uri, 'page/deposit')">
                    <div class="hero-unit">
                        <h3>Deposit Your Research in the Rice Digital Scholarship Archive</h3>
                        <p>Rice faculty, graduate students and staff are encouraged to deposit research publications
                        (including articles, book chapters, conference presentations, and white papers) and research
                        data in the Rice Digital Scholarship Archive. Rice undergraduates may also deposit materials,
                        typically with the sponsorship of a faculty member.
                        </p>
                        <h4>How to deposit your research</h4>

                        <p>In order to deposit your research, you may either:
                        <ul>
                            <li>
                                <strong>Ask Fondren to handle the deposit: </strong> <a href="mailto:openaccess@rice.edu">Email your
                                article or data to us</a>, and we’ll create a metadata record, attach the file, provide
                                a link to the final published version (if applicable) and send you the stable URL for
                                the work. It’s easy!
                            </li>
                            <li>
                                <strong>Do it yourself: </strong> <a href="mailto:cds@rice.edu">Email us</a> to request that your account
                                be enabled to deposit the <a href="https://scholarship.rice.edu/">Rice Digital
                                Scholarship Archive</a>. Once you are granted the
                                appropriate deposit permissions, you can upload your work using a simple webform.
                            </li>
                        </ul>
                            If you have a large number of items you would like deposited, we can facilitate batch
                            deposits.

                        </p>
                        <h4>Licensing terms</h4>
                        <p>
                        In depositing your work, you will be agreeing to the archive’s
                        <a href="https://digitalriceprojects.pbworks.com/w/page/48518133/Non-Exclusive%20Deposit%20License">
                        Non-Exclusive Deposit License.</a> No transfer of copyright is involved.
                        </p>
                        <h4>What can be deposited in the RDSA?</h4>
                        <p>
                        Please consult the
                        <a href="https://digitalriceprojects.pbworks.com/w/page/86368345/RDSA%20Deposit%20Guidelines">
                        Rice Digital Scholarship Archive Deposit Guidelines</a> to learn about the scope
                        of our collections.
                        </p>
                        <h4>What version of a published article can be deposited?</h4>
                        <p>
                            Publishers have different policies for what version of the article can be deposited in an
                            institutional repository. Generally, publishers allow either a post-print or publisher’s
                            PDF:
                        </p>
                        <ul>
                            <li>
                                <p>
                                    <strong>Post-print:</strong> The final, peer-reviewed manuscript that is submitted
                                    to the publisher for publication. This is often a word processor document and is
                                    not yet formatted by the publisher.Even though the post-print looks very similar
                                    to the published version of the article, this manuscript is often treated
                                    differently than the published version when it comes to licensing and
                                    copyright issues.

                                </p>
                                <p>
                                    The post-print should not be confused with a “page proof.” Because the “page proof”
                                    is produced by the publisher, it can often not be deposited in an institutional
                                    repository.

                                </p>
                            </li>
                            <li>
                                <p>
                                    <strong>Publisher’s PDF/Version of Record:</strong> The final, published version of
                                    the article. This is often a PDF, formatted by the publisher, with complete citation
                                    information.

                                </p>
                                <p>
                                    Often, if you transferred your copyright to the publisher, you are only allowed to
                                    deposit the post-print. All open access journals (plus a few additional publishers)
                                    allow posting of the publisher’s PDF.

                                </p>
                            </li>

                        </ul>
                        <p>
                            Publishers may require an embargo period for any article in an institutional repository.
                            <a href="https://scholarship.rice.edu/">The Rice Digital
                                Scholarship Archive</a> is able to honor such embargoes.

                        </p>
                        <p>
                            <a href="http://www.sherpa.ac.uk/romeo/">SHERPA/RoMEO</a> is a useful resource for
                            identifying the publisher’s policy for a specific journal.
                            You can also <a href="mailto:openaccess@rice.edu">contact Fondren</a> for assistance.

                        </p>


                        <h4>Creative Commons</h4>
                        <p>
                        If you deposit work that has not been previously published (and you are the copyright holder),
                        you will have the option to assign a Creative Commons license to your work. Creative Commons
                        licenses allow authors to indicate how they want others to reuse their work. Creative Commons
                        licenses aren’t an alternative to copyright; rather, they give creators more control over how
                        their work is reused.
                        </p>
                        <h4>Need Help? Have Questions?</h4>
                        <p>
                            <a href="mailto:cds@rice.edu">Email us</a>, consult our
                            <a href="https://wiki.rice.edu/confluence/display/RDSAFAQ/Rice+Digital+Scholarship+Archive+FAQ+Home">
                                FAQ</a>, or call Lisa Spiro at 713-348-2480
                        </p>
                    </div>
                </xsl:when>
                <!-- Otherwise use default handling of body -->
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>

        </div>
    </xsl:template>

        <!--The Trail-->
    <xsl:template match="dri:trail">
        <!--put an arrow between the parts of the trail-->
        <li  role="presentation">
            <xsl:if test="position()=1">
                <i class="glyphicon glyphicon-home" aria-hidden="true"/>&#160;
            </xsl:if>
            <!-- Determine whether we are dealing with a link or plain text trail link -->
            <xsl:choose>
                <xsl:when test="./@target">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="./@target"/>
                        </xsl:attribute>
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                <xsl:when test="starts-with($request-uri, 'page/deposit')">
                    <a href="/"><i18n:text>xmlui.general.dspace_home</i18n:text></a>
                    <xsl:text> / </xsl:text>
                    <xsl:text>Deposit your work</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">active</xsl:attribute>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>



</xsl:stylesheet>
