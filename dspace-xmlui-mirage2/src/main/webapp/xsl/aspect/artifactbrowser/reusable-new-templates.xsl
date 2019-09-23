<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns:dri="http://di.tamu.edu/DRI/1.0/" xmlns:mets="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/TR/xlink/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:dim="http://www.dspace.org/xmlns/dspace/dim" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc">

    <!--

    This stylesheet contains utility templates expected to be useful for all (or nearly all) Manakin themes
    in use in dspace.rice.edu. It currently contains:

        - 1 template for Context Objects in Spans (COinS)
        - 4 templates related to converting plain text to HTML mark-up
        
    It differs from reusable-overrides.xsl in that it contains new XSL templates (as opposed to overrides of 
    existing templates) and mostly contains named templates (as opposed to matching templates).  For those 
    reasons it should be safer for use in more Manakins.

    -->

    <xsl:template mode="COinS" name="COinS">
        <!-- This template creates a <span> element conforming to the Context Objects in Spans (COinS) specification.
             The OpenURL KEV value it produces conforms to the book template for items whose Dublin Core type is books 
             and book chapters, the journal template for articles, preprints, postprints, technical reports, and working
             papers, the dissertation template for items marked as theses, and the unqualified Dublin Core template for
             everything else. -DS
        -->
        <xsl:param name="dim"/>

        <xsl:variable name="type" select="dim:field[@element='type']"/>
        <xsl:variable name="isJournal">
            <xsl:choose>
                <xsl:when test="$type='Journal issue' or $type='Article' or $type='Preprint' or $type='Postprint' or $type='Working paper' or $type='Technical report'">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="isBook">
            <xsl:choose>
                <xsl:when test="$type='Book' or $type='Book chapter'">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="isDissertation">
            <xsl:choose>
                <xsl:when test="$type='Thesis'">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <span class="Z3988">
            <xsl:attribute name="title">
                <xsl:text>url_ver=Z39.88-2004</xsl:text>
                <xsl:choose>
                    <xsl:when test="$isBook='true'">&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook</xsl:when>
                    <xsl:when test="$isJournal='true'">&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal</xsl:when>
                    <xsl:otherwise>&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc</xsl:otherwise>
                </xsl:choose>
                <xsl:text>&amp;ctx_ver=Z39.88-2004</xsl:text>
                <!-- item's handle as URI -->
                <xsl:text>&amp;rft_id=</xsl:text>
                <xsl:value-of select="dim:field[@element='identifier'][@qualifier='uri']/child::node()"/>
                <!-- DOI if any -->
                <xsl:if test="dim:field[@element='identifier'][@qualifier='doi']">
                    <xsl:text>&amp;rft_id=</xsl:text>
                    <xsl:value-of select="dim:field[@element='identifier'][@qualifier='doi']/child::node()"/>
                </xsl:if>
                <!-- ISSN if any -->
                <xsl:if test="dim:field[@element='identifier'][@qualifier='issn']">
                    <xsl:text>&amp;rft.issn=</xsl:text>
                    <xsl:value-of select="dim:field[@element='identifier'][@qualifier='issn']/child::node()"/>
                </xsl:if>
                <!-- ISBN if any -->
                <xsl:if test="dim:field[@element='identifier'][@qualifier='isbn']">
                    <xsl:text>&amp;rft.isbn=</xsl:text>
                    <xsl:value-of select="dim:field[@element='identifier'][@qualifier='isbn']/child::node()"/>
                </xsl:if>
                <!-- publisher if any -->
                <xsl:if test="dim:field[@element='publisher'][not(@qualifier)]">
                    <xsl:text>&amp;rft.pub=</xsl:text>
                    <xsl:value-of select="dim:field[@element='publisher'][not(@qualifier)]/child::node()"/>
                </xsl:if>
                <!-- title -->
                <xsl:choose>
                    <xsl:when test="$isBook='true'">
                        <xsl:choose>
                            <xsl:when test="$type='Book chapter'">
                                <xsl:text>&amp;rft.atitle=</xsl:text>
                                <xsl:value-of select="dim:field[@element='title'][not(@qualifier)]/child::node()"/>
                            </xsl:when>
                            <xsl:when test="$type='Book'">
                                <xsl:text>&amp;rft.title=</xsl:text>
                                <xsl:value-of select="dim:field[@element='title'][not(@qualifier)]/child::node()"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$isJournal='true'">
                        <xsl:choose>
                            <xsl:when test="$type='Journal issue'">
                                <xsl:text>&amp;rft.jtitle=</xsl:text>
                                <xsl:value-of select="dim:field[@element='title'][not(@qualifier)]/child::node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&amp;rft.atitle=</xsl:text>
                                <xsl:value-of select="dim:field[@element='title'][not(@qualifier)]/child::node()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>&amp;rft.title=</xsl:text>
                        <xsl:value-of select="dim:field[@element='title'][not(@qualifier)]/child::node()"/>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- date -->
                <xsl:if test="dim:field[@element='date'][@qualifier='issued']">
                    <xsl:text>&amp;rft.date=</xsl:text>
                    <xsl:value-of select="dim:field[@element='date'][@qualifier='issued']/child::node()"/>
                </xsl:if>
                <!-- series membership -->
                <xsl:if test="$isBook='true' and dim:field[@element='relation'][qualifier='ispartofseries']">
                    <xsl:text>&amp;rft.series=</xsl:text>
                    <xsl:value-of select="dim:field[@element='relation'][qualifier='ispartofseries']/child::node()"/>
                </xsl:if>
                <!-- "genre" -->
                <xsl:choose>
                    <xsl:when test="$isJournal='true'">
                        <xsl:choose>
                            <xsl:when test="$type='Journal issue'">
                                <xsl:text>&amp;rft.genre=issue</xsl:text>
                            </xsl:when>
                            <xsl:when test="$type='Article'">
                                <xsl:text>&amp;rft.genre=article</xsl:text>
                            </xsl:when>
                            <xsl:when test="$type='Preprint' or $type='Postprint' or $type='Working paper'">
                                <xsl:text>&amp;rft.genre=preprint</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&amp;rft.genre=unknown</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$isBook='true'">
                        <xsl:choose>
                            <xsl:when test="$type='Book'">
                                <xsl:text>&amp;rft.genre=book</xsl:text>
                            </xsl:when>
                            <xsl:when test="$type='Book chapter'">
                                <xsl:text>&amp;rft.genre=bookitem</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$isDissertation='true'"><!-- do nothing? --></xsl:when>
                    <xsl:otherwise>&amp;rft.genre=unknown</xsl:otherwise>
                </xsl:choose>
                <!-- authors -->
                <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                    <xsl:text>&amp;rft.au=</xsl:text>
                    <xsl:value-of select="./child::node()"/>
                </xsl:for-each>
            </xsl:attribute>
            <!-- non-breaking space to keep Firefox from screwing up layouts -DS -->
            <xsl:text>​</xsl:text>
        </span>
    </xsl:template>


    <!-- Ying (via MMS): This template and its following two helper templates take a string
         that contains literal HTML text and converts it into actual mark-up. -->
    <xsl:template name="parse">
        <xsl:param name="str" select="."/>
        <!-- MMS: omit-link prevents the <a> tag from being produced while still processing any children. -->
        <xsl:param name="omit-link">0</xsl:param>
        <xsl:choose>
            <xsl:when test="contains($str,'&lt;i') or contains($str, '&lt;b') or contains($str, '&lt;a') or contains($str, '&lt;p') or contains($str, '&lt;link') or contains($str, '&lt;meta')">
                <xsl:variable name="tag" select="substring-before(substring-after($str,'&lt;'),'&gt;')"/>
                <xsl:variable name="endTag">
                    <xsl:choose>
                        <xsl:when test="contains($tag,' ')">
                            <xsl:value-of select="substring-before($tag,' ')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$tag"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:message>
                    <xsl:text>tag:</xsl:text> <xsl:copy-of select="$tag"/> 
                    <xsl:text> -- end tag:</xsl:text> <xsl:copy-of select="$endTag"/>
                </xsl:message>
                <xsl:call-template name="parse">
                    <xsl:with-param name="str" select="substring-before($str,concat('&lt;',$tag,'&gt;'))"/>
                    <xsl:with-param name="omit-link" select="$omit-link"/>
                </xsl:call-template>
                <!-- MMS: if omit-link is true and the tag in question is an anchor, just parse the text inside, otherwise parse the entire tag. -->
                <xsl:choose>
                    <xsl:when test="$omit-link='1' and $endTag='a'">
                        <xsl:call-template name="parse">
                            <xsl:with-param name="str" select="substring-before(substring-after($str,concat('&lt;',$tag,'&gt;')),concat('&lt;/',normalize-space($endTag),'&gt;'))"/>
                            <xsl:with-param name="omit-link" select="$omit-link"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="parseTag">
                            <xsl:with-param name="tag" select="$tag"/>
                            <xsl:with-param name="endTag" select="normalize-space($endTag)"/>
                            <xsl:with-param name="value" select="substring-before(substring-after($str,concat('&lt;',$tag,'&gt;')),concat('&lt;/',normalize-space($endTag),'&gt;'))"/>
                            <xsl:with-param name="omit-link" select="$omit-link"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="parse">
                    <xsl:with-param name="str" select="substring-after($str,concat('&lt;/',normalize-space($endTag),'&gt;'))"/>
                    <xsl:with-param name="omit-link" select="$omit-link"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$str"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Ying (via MMS): called by template "parse" above. -->
    <xsl:template name="parseTag">
        <xsl:param name="tag" select="''"/>
        <xsl:param name="endTag" select="''"/>
        <xsl:param name="value" select="''"/>
        <xsl:param name="omit-link">0</xsl:param>
        <xsl:element name="{$endTag}">
            <xsl:call-template name="attribs">
                <xsl:with-param name="attrlist" select="substring-after(normalize-space($tag),' ')"/>
            </xsl:call-template>
            <xsl:call-template name="parse">
                <xsl:with-param name="str" select="$value"/>
                <xsl:with-param name="omit-link" select="$omit-link"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>
    
    <!-- Ying (via MMS): called by template "parseTag" above. -->
    <xsl:template name="attribs">
        <xsl:param name="attrlist" select="''"/>
        <xsl:variable name="name" select="normalize-space(substring-before($attrlist,'='))"/>
        <xsl:message>
            <xsl:text>Attr Name: </xsl:text><xsl:copy-of select="$name"></xsl:copy-of>
        </xsl:message>
        <xsl:if test="$name">
            <xsl:variable name="value">
                <xsl:choose>
                    <xsl:when test="substring-before($attrlist,'=&quot;')">
                        <xsl:value-of select="substring-before(substring-after($attrlist,'=&quot;'),'&quot;')"/>
                    </xsl:when>
                    <xsl:when test="substring-before($attrlist,'= &quot;')">
                        <xsl:value-of select="substring-before(substring-after($attrlist,'= &quot;'),'&quot;')"/>
                    </xsl:when>
                    <xsl:when test="substring-before($attrlist,&quot;=&apos;&quot;)">
                        <xsl:value-of select="substring-before(substring-after($attrlist,&quot;=&apos;&quot;),&quot;&apos;&quot;)"/>
                    </xsl:when>
                    <xsl:when test="substring-before($attrlist,&quot;= &apos;&quot;)">
                        <xsl:value-of select="substring-before(substring-after($attrlist,&quot;=&apos;&quot;),&quot;&apos;&quot;)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>      
            <xsl:message>
                <xsl:text>Attr Value: </xsl:text><xsl:copy-of select="$value"></xsl:copy-of>
            </xsl:message>      
            <xsl:attribute name="{$name}">
                <xsl:value-of select="$value"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="contains($attrlist,' ')">
                <xsl:call-template name="attribs">
                    <xsl:with-param name="attrlist" select="substring-after($attrlist,' ')"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- MMS: This turns text starting with 'http://' into a link -->
    <!-- Ying: updated to parse https also -->
    <!-- TODO make this handle https as well -->
    <xsl:template name="makeLinkFromText">
        <xsl:variable name="url-protocol">
            <xsl:if test="contains(., 'https://')">
                <xsl:text>https://</xsl:text>
            </xsl:if>
            <xsl:if test="contains(., 'http://')">
                <xsl:text>http://</xsl:text>
            </xsl:if>
        </xsl:variable>

        <xsl:variable name="url-body" select="substring-after(.,$url-protocol)"/>
        <xsl:variable name="url">
            <xsl:value-of select="$url-protocol"/>
            <xsl:choose>
                <!-- MMS: If we've hit a space, it's very unlikely that it's supposed to be part of the link. -->
                <xsl:when test="contains($url-body, ' ')">
                    <xsl:value-of select="substring-before($url-body, ' ')"/>
                </xsl:when>
                <!-- MMS: If it there is a closing paren before the end of a string, we can probably be fairly certain that
                     it's not supposed to be part of the link (e.g. "DSP (http://dsp.rice.edu)"). -->
                <xsl:when test="contains($url-body, ')')">
                    <xsl:value-of select="substring-before($url-body, ')')"/>
                </xsl:when>
                <!-- MMS: If there is a space preceded by a period, we can probably be fairly certain that it's not supposed
                     to be part of the link. -->
                <xsl:when test="contains($url-body, '. ')">
                    <xsl:value-of select="substring-before($url-body, '. ')"/>
                </xsl:when>
                <!-- MMS: Ditto for a comma preceded by a period.  -->
                <xsl:when test="contains($url-body, ', ')">
                    <xsl:value-of select="substring-before($url-body, ', ')"/>
                </xsl:when>
                <!-- MMS: If none of the above cases are met and the last character is a period, it's more likely to be the
                     end of a sentence than the end of the link. -->
                <xsl:when test="substring($url-body, string-length($url-body)) = '.'">
                    <xsl:value-of select="substring($url-body, 1, string-length($url-body) - 1)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$url-body"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="substring-before(.,$url)"/>
        <a href="{$url}">
            <xsl:value-of select="$url"/>
        </a>
        <xsl:value-of select="substring-after(.,$url)"/>
    </xsl:template>
	
 
</xsl:stylesheet>
