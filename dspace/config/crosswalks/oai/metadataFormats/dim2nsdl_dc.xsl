<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
                xmlns:xsi ="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:nsdl_dc="http://ns.nsdl.org/nsdl_dc_v1.02/"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:ieee="http://www.ieee.org/xsd/LOMv1p0"
                version="1.0">
        <xsl:output method="xml" omit-xml-declaration="yes"/>
        
        <!--<xsl:template match="@* | node()">
                <xsl:copy>
                        <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
        </xsl:template>-->
        
        <!-- http://wiki.dspace.org/DspaceIntermediateMetadata -->
        
        <xsl:template match="dim:dim">
                <nsdl_dc:nsdl_dc>
                        <xsl:attribute name="schemaVersion">1.02.020</xsl:attribute>
                        <xsl:attribute name="xsi:schemaLocation">http://ns.nsdl.org/nsdl_dc_v1.02/ http://ns.nsdl.org/schemas/nsdl_dc/nsdl_dc_v1.02.xsd</xsl:attribute>
                        
                        <!-- required element
                             dc:title : dc.title -->
                        <xsl:variable name="title" select="dim:field[@mdschema='dc'][@element ='title'][not(@qualifier)]"/>
                        <dc:title>
                                <xsl:choose>
                                        <xsl:when test="$title">
                                                <xsl:value-of select="$title"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                                <xsl:text>no title</xsl:text>
                                        </xsl:otherwise>
                                </xsl:choose>
                        </dc:title>

                        <!-- required element.
                             dc:identifier: nsdl.identifier.uri OR dc.identifier.uri -->
                        <dc:identifier xsi:type="dct:URI">
                            <xsl:variable name="nsdl_id" select="dim:field[@mdschema='nsdl'][@element ='identifier'][@qualifier='uri']"/>
                            <xsl:choose>
                                <xsl:when test="$nsdl_id != ''">
                                    <!-- nsdl.identifier.uri is the first choice if present -->
                                    <xsl:value-of select="$nsdl_id"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- fallback - guaranteed to be present in the source DIM -->
                                    <xsl:value-of select="dim:field[@mdschema='dc'][@element ='identifier'][@qualifier='uri']"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </dc:identifier>
                        
                        <!-- every other element is optional; just do it if it's present. -->
                        <xsl:apply-templates/>
                </nsdl_dc:nsdl_dc>
        </xsl:template>
        
        <!-- dct:alternative : dc.title.alternative -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='title'][@qualifier='alternative']">
                <dct:alternative><xsl:value-of select="text()"/></dct:alternative>
        </xsl:template>

        <!-- dc:subject : dc.subject.* (but not a more specific type below) -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='subject']">
                <dc:subject><xsl:value-of select="text()"/></dc:subject>
        </xsl:template>
        
        <!-- dc:subject(MESH) : dc.subject.mesh -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='subject'][@qualifier='mesh']">
                <dc:subject xsi:type="dct:MESH"><xsl:value-of select="text()"/></dc:subject>
        </xsl:template>
        
        <!-- dc:subject(LCSH) : dc.subject.lcsh -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='subject'][@qualifier='lcsh']">
                <dc:subject xsi:type="dct:LCSH"><xsl:value-of select="text()"/></dc:subject>
        </xsl:template>
        
        <!-- dc:subject(NSDL controlled vocabulary) : nsdl.subject.* -->
        <xsl:template match="dim:field[@mdschema='nsdl'][@element='subject']">
                <dc:subject xsi:type="nsdl_dc:GEM"><xsl:value-of select="text()"/></dc:subject>
        </xsl:template>
        
        <!-- dct:educationLevel(NSDL controlled vocabulary) : nsdl.educationLevel.* -->
        <xsl:template match="dim:field[@mdschema='nsdl'][@element='educationLevel']">
                <dct:educationLevel xsi:type="nsdl_dc:NSDLEdLevel"><xsl:value-of select="text()"/></dct:educationLevel>
        </xsl:template>
        
        <!-- dct:audience(NSDL controlled vocabulary) : nsdl.audience.* -->
        <xsl:template match="dim:field[@mdschema='nsdl'][@element='audience']">
                <dct:audience xsi:type="nsdl_dc:NSDLAudience"><xsl:value-of select="text()"/></dct:audience>
        </xsl:template>
        
        <!-- dct:mediator : nsdl.mediator.* -->
        <!--<xsl:template match="dim:field[@mdschema='nsdl'][@element='mediator']">
                <dct:mediator><xsl:value-of select="text()"/></dct:mediator>
        </xsl:template>-->
        
        <!-- dc:description : dc.description -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='description'][not(@qualifier)]">
                <dc:description><xsl:value-of select="text()"/></dc:description>
        </xsl:template>
        
        <!-- dc:type(DCMI) : dc.type -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='type'][not(@qualifier)]">
                <dc:type xsi:type="dct:DCMIType"><xsl:value-of select="text()"/></dc:type>
        </xsl:template>
        
        <!-- dc:type(NSDL controlled vocabulary) : nsdl.type.* -->
        <xsl:template match="dim:field[@mdschema='nsdl'][@element='type']">
                <dc:type xsi:type="nsdl_dc:NSDLType"><xsl:value-of select="text()"/></dc:type>
        </xsl:template>
        
        <!-- dc:rights : dc.rights.* (but dc.rights.uri is overridden below) -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='rights']">
                <dc:rights>
                        <xsl:if test="starts-with(text(), 'http://')">
                                <xsl:attribute name="xsi:type">dct:URI</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="text()"/>
                </dc:rights>
        </xsl:template>
        
        <!-- dct:accessRights(controlled vocabulary) : nsdl.accessRights.* -->
        <xsl:template match="dim:field[@mdschema='nsdl'][@element='accessRights']">
                <dct:accessRights xsi:type="nsdl_dc:NSDLAccess"><xsl:value-of select="text()"/></dct:accessRights>
        </xsl:template>
        
        <!-- dct:license(URI) : dc.rights.uri -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='rights'][@qualifier='uri']">
                <dct:license xsi:type="dct:URI"><xsl:value-of select="text()"/></dct:license>
        </xsl:template>
        
        <!-- dc:contributor : dc.contributor.* (but not dc.contributor.author) -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='contributor']">
                <dc:contributor><xsl:value-of select="text()"/></dc:contributor>
        </xsl:template>
        
        <!-- dc:creator : dc.creator.* or dc.contributor.author -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='creator'] | dim:field[@mdschema='dc'][@element='contributor'][@qualifier='author']">
                <dc:creator><xsl:value-of select="text()"/></dc:creator>
        </xsl:template>
        
        <!-- dc:publisher : dc.publisher.* -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='publisher']">
                <dc:publisher><xsl:value-of select="text()"/></dc:publisher>
        </xsl:template>
        
        <!-- dc:language(ISO639-2) : dc.langauge.iso -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='language'][@qualifier='iso']">
                <dc:language xsi:type="dct:ISO639-2"><xsl:value-of select="text()"/></dc:language>
        </xsl:template>
        
        <!-- dc:language : dc.langauge.* -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='language']">
                <dc:language><xsl:value-of select="text()"/></dc:language>
        </xsl:template>
        
        <!-- dc:coverage : dc.coverage.* -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='coverage']">
                <dc:coverage><xsl:value-of select="text()"/></dc:coverage>
        </xsl:template>
        
        <!-- dct:spatial : dc.coverage.spatial -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='coverage'][@qualifier='spatial']">
                <dct:spatial><xsl:value-of select="text()"/></dct:spatial>
        </xsl:template>
        
        <!-- dct:temporal : dc.coverage.temporal -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='coverage'][@qualifier='temporal']">
                <dct:temporal><xsl:value-of select="text()"/></dct:temporal>
        </xsl:template>
        
        <!-- dc:date : dc.date. Also dc.date.issued, but only if there is no dc.date -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='date'][not(@qualifier) or (@qualifier='issued' and not(parent::*/dim:field[@mdschema='dc'][@element='date'][not(@qualifier)]))]">
                <dc:date><xsl:value-of select="text()"/></dc:date>
        </xsl:template>
        
        <!-- dct:created : dc.date.created -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='date'][@qualifier='created']">
                <dct:created><xsl:value-of select="text()"/></dct:created>
        </xsl:template>
        
        <!-- dct:available : dc.date.available -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='date'][@qualifier='available']">
                <dct:available><xsl:value-of select="text()"/></dct:available>
        </xsl:template>
        
        <!-- dct:dateAccepted : dc.date.accessioned -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='date'][@qualifier='accessioned']">
                <dct:dateAccepted><xsl:value-of select="text()"/></dct:dateAccepted>
        </xsl:template>
        
        <!-- dct:dateCopyrighted : dc.date.copyright -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='date'][@qualifier='copyright']">
                <dct:dateCopyrighted><xsl:value-of select="text()"/></dct:dateCopyrighted>
        </xsl:template>
        
        <!-- dct:dateSubmitted : dc.date.submitted -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='date'][@qualifier='submitted']">
                <dct:dateSubmitted><xsl:value-of select="text()"/></dct:dateSubmitted>
        </xsl:template>
        
        <!-- dct:issued : dc.date.issued, but only if dc.date also exists -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='date'][@qualifier='issued'][parent::*/dim:field[@mdschema='dc'][@element='date'][not(@qualifier)]]">
                <dct:issued><xsl:value-of select="text()"/></dct:issued>
        </xsl:template>
        
        <!-- dct:modified : dc.date.modified -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='date'][@qualifier='modified']">
                <dct:modified><xsl:value-of select="text()"/></dct:modified>
        </xsl:template>
        
        <!-- dct:valid : dc.date.valid -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='date'][@qualifier='valid']">
                <dct:valid><xsl:value-of select="text()"/></dct:valid>
        </xsl:template>
        
        <!-- ieee:interactivityType : ieee.interactivityType.* -->
        <xsl:template match="dim:field[@mdschema='ieee'][@element='interactivityType']">
                <ieee:interactivityType><xsl:value-of select="text()"/></ieee:interactivityType>
        </xsl:template>
        
        <!-- ieee:interactivityLevel : ieee.interactivityLevel.* -->
        <xsl:template match="dim:field[@mdschema='ieee'][@element='interactivityLevel']">
                <ieee:interactivityLevel><xsl:value-of select="text()"/></ieee:interactivityLevel>
        </xsl:template>
        
        <!-- ieee:typicalLearningTime : ieee.typicalLearningTime.* -->
        <xsl:template match="dim:field[@mdschema='ieee'][@element='typicalLearningTime']">
                <ieee:typicalLearningTime><xsl:value-of select="text()"/></ieee:typicalLearningTime>
        </xsl:template>
        
        <!-- dc:format(MIMETYPE/IMT) : dc.format.mimetype -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='format'][@qualifier='mimetype']">
                <dc:format xsi:type="dct:IMT"><xsl:value-of select="text()"/></dc:format>
        </xsl:template>
        
        <!-- dc:format : dc.format -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='format'][not(@qualifier)]">
                <dc:format><xsl:value-of select="text()"/></dc:format>
        </xsl:template>
        
        <!-- dct:extent : dc.format.extent -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='format'][@qualifier='extent']">
                <dct:extent><xsl:value-of select="text()"/></dct:extent>
        </xsl:template>
        
        <!-- dct:medium : dc.format.medium -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='format'][@qualifier='medium']">
                <dct:medium><xsl:value-of select="text()"/></dct:medium>
        </xsl:template>
        
        <!-- dc:relation : dc.relation -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='relation'][not(@qualifier)]">
                <dc:relation><xsl:value-of select="text()"/></dc:relation>
        </xsl:template>
        
        <!-- dct:conformsTo : dc.relation.conformsto -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='relation'][@qualifier='conformsto']">
                <dct:conformsTo>
                        <xsl:if test="starts-with(text(), 'http://')">
                                <xsl:attribute name="xsi:type">dct:URI</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="text()"/>
                </dct:conformsTo>
        </xsl:template>
        
        
        <!-- dct:isFormatOf : dc.relation.isFormatOf -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='relation'][@qualifier='isformatof']">
                <dct:isFormatOf>
                        <xsl:if test="starts-with(text(), 'http://')">
                                <xsl:attribute name="xsi:type">dct:URI</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="text()"/>
                </dct:isFormatOf>
        </xsl:template>
        
        <!-- dct:hasFormat : dc.relation.hasFormat -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='relation'][@qualifier='hasformat']">
                <dct:hasFormat>
                        <xsl:if test="starts-with(text(), 'http://')">
                                <xsl:attribute name="xsi:type">dct:URI</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="text()"/>
                </dct:hasFormat>
        </xsl:template>
        
        <!-- dct:isPartOf : dc.relation.isPartOf -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='relation'][@qualifier='ispartof']">
                <dct:isPartOf>
                        <xsl:if test="starts-with(text(), 'http://')">
                                <xsl:attribute name="xsi:type">dct:URI</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="text()"/>
                </dct:isPartOf>
        </xsl:template>
        
        <!-- dct:hasPart : dc.relation.hasPart -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='relation'][@qualifier='haspart']">
                <dct:hasPart>
                        <xsl:if test="starts-with(text(), 'http://')">
                                <xsl:attribute name="xsi:type">dct:URI</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="text()"/>
                </dct:hasPart>
        </xsl:template>
        
        <!-- dct:isReferencedBy : dc.relation.isReferencedBy -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='relation'][@qualifier='isreferencedby']">
                <dct:isReferencedBy>
                        <xsl:if test="starts-with(text(), 'http://')">
                                <xsl:attribute name="xsi:type">dct:URI</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="text()"/>
                </dct:isReferencedBy>
        </xsl:template>
        
        <!-- dct:references : dc.relation.references -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='relation'][@qualifier='references']">
                <dct:references>
                        <xsl:if test="starts-with(text(), 'http://')">
                                <xsl:attribute name="xsi:type">dct:URI</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="text()"/>
                </dct:references>
        </xsl:template>
        
        <!-- dct:isReplacedBy : dc.relation.isReplacedBy -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='relation'][@qualifier='isreplacedby']">
                <dct:isReplacedBy>
                        <xsl:if test="starts-with(text(), 'http://')">
                                <xsl:attribute name="xsi:type">dct:URI</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="text()"/>
                </dct:isReplacedBy>
        </xsl:template>
        
        <!-- dct:replaces : dc.relation.replaces -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='relation'][@qualifier='replaces']">
                <dct:replaces>
                        <xsl:if test="starts-with(text(), 'http://')">
                                <xsl:attribute name="xsi:type">dct:URI</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="text()"/>
                </dct:replaces>
        </xsl:template>
        
        <!-- dct:isRequiredBy : dc.relation.isRequiredBy -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='relation'][@qualifier='isrequiredby']">
                <dct:isRequiredBy>
                        <xsl:if test="starts-with(text(), 'http://')">
                                <xsl:attribute name="xsi:type">dct:URI</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="text()"/>
                </dct:isRequiredBy>
        </xsl:template>
        
        <!-- dct:requires : dc.relation.requires -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='relation'][@qualifier='requires']">
                <dct:requires>
                        <xsl:if test="starts-with(text(), 'http://')">
                                <xsl:attribute name="xsi:type">dct:URI</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="text()"/>
                </dct:requires>
        </xsl:template>
        
        <!-- dct:isVersionOf : dc.relation.isVersionOf -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='relation'][@qualifier='isversionof']">
                <dct:isVersionOf>
                        <xsl:if test="starts-with(text(), 'http://')">
                                <xsl:attribute name="xsi:type">dct:URI</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="text()"/>
                </dct:isVersionOf>
        </xsl:template>
        
        <!-- dct:hasVersion : dc.relation.hasVersion -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='relation'][@qualifier='hasversion']">
                <dct:hasVersion>
                        <xsl:if test="starts-with(text(), 'http://')">
                                <xsl:attribute name="xsi:type">dct:URI</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="text()"/>
                </dct:hasVersion>
        </xsl:template>
        
        <!-- dct:abstract : dc.description.abstract -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='description'][@qualifier='abstract']">
                <dct:abstract><xsl:value-of select="text()"/></dct:abstract>
        </xsl:template>
        
        <!-- dct:tableOfContents : dc.description.tableofcontents -->
        <xsl:template match="dim:field[@mdschema='dc'][@element='description'][@qualifier='tableofcontents']">
                <dct:tableOfContents><xsl:value-of select="text()"/></dct:tableOfContents>
        </xsl:template>
        
        <!-- dct:bibliographicCitation : dc.identifier.citation -->
        <!--<xsl:template match="dim:field[@mdschema='dc'][@element='identifier'][@qualifier='citation']">
                <dct:bibliographicCitation><xsl:value-of select="text()"/></dct:bibliographicCitation>
        </xsl:template>-->
        
        <!-- dct:instructionalMethod : nsdl.instructionalMethod.* -->
        <xsl:template match="dim:field[@mdschema='nsdl'][@element='instructionalMethod']">
                <dct:instructionalMethod><xsl:value-of select="text()"/></dct:instructionalMethod>
        </xsl:template>
        
        <!-- dct:provenance : dc.description.provenance -->
        <!--<xsl:template match="dim:field[@mdschema='dc'][@element='description'][@qualifier='provenance']">
                <dct:provenance><xsl:value-of select="text()"/></dct:provenance>
                </xsl:template>-->
        
        <!-- dct:accrualMethod, dct:accrualPeriodicity, dct:accrualPolicy : rarely used -->
        
        <!-- every other dim field is unconfigured, so omit it. -->
        <xsl:template match="dim:field" />
        
</xsl:stylesheet>
