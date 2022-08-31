<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:su="com.spinque.tools.importStream.Utils"
    xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
    xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
    xmlns:ese="http://www.europeana.eu/schemas/ese/" xmlns:dc="http://purl.org/dc/elements/1.1"
    xmlns:dcterms="http://purl.org/dc/terms" xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:schema="http://schema.org/"
    xmlns:europeana="http://www.europeana.eu/schemas/ese" xmlns:delving="http://schemas.delving.eu"
    extension-element-prefixes="spinque">

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:template match="Records">
        <xsl:variable name="subject" select="su:replaceAll(europeana_isshownat, ' ', '%20')"/>
        <xsl:call-template name="record">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="record">
        <xsl:param name="subject"/>

        <!--spinque:attribute
            subject="{$subject}" attribute="schema:thumbnail"
            value="{su:replace(europeana_isshownby, 'http://', 'https://')}"
            type="string"/-->
        <spinque:attribute
            subject="{$subject}" attribute="schema:thumbnail"
            value="{concat('https://cc.museon.nl/imageproxy.aspx?server=localhost&amp;port=17512&amp;filename=images/', image, '&amp;Height=250&amp;Width=250')}"
            type="string"/>
        <!-- *** Link Publisher *** -->
        <spinque:relation
            subject="{$subject}"
            predicate="dc:publisher"
            object="niod:Organizations/28"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:publisher"
            value="Museon"
            type="string"/>
        <!-- end -->
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:language"
            value="nl"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="http://purl.org/dc/dcmitype/Collection"
            value="Museon collectie WOII"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="schema:disambiguatingDescription"
            value="In Oorlogsbronnen in set collectie_museon"
            type="string"/>
        <xsl:choose>
            <xsl:when test="(dc_title != '')">
                <xsl:variable name="titelTekst">
                    <xsl:choose>
                        <xsl:when test="contains(dc_title, 'officieuze titel')">
                            <xsl:value-of select="substring-before(dc_title, 'officieuze titel')"/>
                        </xsl:when>
                        <xsl:when test="contains(dc_title, 'titel')">
                            <xsl:value-of select="substring-before(dc_title, 'titel')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="dc_title"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="title">
                    <xsl:value-of select="$titelTekst"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="string-length($title) &gt; 21">
                        <xsl:variable name="titleLang"
                            select="substring($title, 20, string-length($title))"/>
                        <xsl:variable name="titleKort">
                            <xsl:choose>
                                <xsl:when test="contains($titleLang, ' ')">
                                    <xsl:value-of select="substring-before($titleLang, ' ')"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <spinque:attribute
                            subject="{$subject}"
                            attribute="dc:title"
                            value="{concat(substring($title, 1,19), $titleKort)}"
                            type="string"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <spinque:attribute
                            subject="{$subject}"
                            attribute="dc:title"
                            value="{$title}"
                            type="string"/>
                    </xsl:otherwise>
                </xsl:choose>
                <!--spinque:attribute subject="{$subject}"
                    attribute="dc:title" value="{$titelTekst}"
                    type="string"/-->
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="title">
                    <xsl:value-of select="dc_type"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="string-length($title) &gt; 21">
                        <xsl:variable name="titleLang"
                            select="substring($title, 20, string-length($title))"/>
                        <xsl:variable name="titleKort">
                            <xsl:choose>
                                <xsl:when test="contains($titleLang, ' ')">
                                    <xsl:value-of select="substring-before($titleLang, ' ')"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <spinque:attribute
                            subject="{$subject}"
                            attribute="dc:title"
                            value="{concat(substring($title, 1,19), $titleKort)}"
                            type="string"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <spinque:attribute
                            subject="{$subject}"
                            attribute="dc:title"
                            value="{dc_type}"
                            type="string"/>
                    </xsl:otherwise>
                </xsl:choose>
                <!--spinque:attribute subject="{$subject}"
                    attribute="dc:title" value="{dc_type}"
                    type="string"/-->
            </xsl:otherwise>
        </xsl:choose>

        <spinque:attribute
            subject="{$subject}"
            attribute="dc:description"
            value="{dc_description}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:source"
            value="{europeana_isshownat}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:identifier"
            value="{invnrobjnaam}"
            type="string"/>
        <spinque:relation
            subject="{$subject}"
            predicate="dc:rights"
            object="https://creativecommons.org/licenses/by/4.0/"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:rights"
            value="CC-BY"
            type="string"/>

        <xsl:apply-templates select="dc_creator">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="dc_format">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

 		<!--spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:CreativeWork"/-->
    	<spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Photograph"/>
    	<spinque:attribute subject="{$subject}" attribute="dc:type" value="voorwerp"  type="string"/>

        <xsl:apply-templates select="dc_date">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="dc_subject">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="dc_coverage">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="IsJapan">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

    </xsl:template>

    <!--*** ***-->
    <xsl:template match="dc_creator">
        <xsl:param name="subject"/>

        <xsl:choose>
            <xsl:when test="contains(., '(Vervaardiger)')">
                <spinque:attribute
                    subject="{$subject}"
                    attribute="dc:creator"
                    value="{substring-before(., '(Vervaardiger)')}"
                    type="string"/>
            </xsl:when>
            <xsl:otherwise>
                <spinque:attribute
                    subject="{$subject}"
                    attribute="dc:contributor"
                    value="{.}"
                    type="string"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="dc_date">
        <xsl:param name="subject"/>

        <xsl:choose>
            <xsl:when test="string-length(.) = 4">
                <spinque:attribute
                    subject="{$subject}"
                    attribute="dc:date"
                    type="date"
                    value="{su:parseDate(.,'yyyy')}"/>
                <spinque:attribute
                    subject="{$subject}"
                    attribute="schema:startDate"
                    type="date"
                    value="{su:parseDate(.,'yyyy')}"/>
                <spinque:attribute
                    subject="{$subject}"
                    attribute="schema:endDate"
                    type="date"
                    value="{su:parseDate(.,'yyyy')}"/>
            </xsl:when>
            <xsl:otherwise>
                <spinque:attribute
                    subject="{$subject}"
                    attribute="dc:date"
                    type="string"
                    value="{.}"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="dc_format">
        <xsl:param name="subject"/>

        <spinque:attribute
            subject="{$subject}"
            attribute="dc:format"
            type="string"
            value="{.}"/>

    </xsl:template>

    <xsl:template match="dc_subject">
        <xsl:param name="subject"/>

        <spinque:attribute
            subject="{$subject}"
            attribute="dc:subject"
            type="string"
            value="{.}"/>

    </xsl:template>

    <xsl:template match="dc_coverage">
        <xsl:param name="subject"/>

        <xsl:choose>
            <xsl:when test="contains(., '(')">
                <spinque:attribute
                    subject="{$subject}"
                    attribute="schema:contentLocation"
                    value="{substring-before(., '(')}"
                    type="string"/>
            </xsl:when>
            <xsl:when test="contains(., '(herkomst)')">
                <spinque:attribute
                    subject="{$subject}"
                    attribute="schema:contentLocation"
                    value="{substring-before(., '(herkomst)')}"
                    type="string"/>
            </xsl:when>
            <xsl:when test="contains(su:lowercase(.), 'kamp')">
                <!-- bij kampen doe je niks. Mannenkamp is een trefwoord -->
            </xsl:when>
            <xsl:otherwise>
                <spinque:attribute
                    subject="{$subject}"
                    attribute="schema:contentLocation"
                    value="{.}"
                    type="string"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="IsJapan">
        <xsl:param name="subject"/>

        <spinque:attribute
            subject="{$subject}"
            attribute="schema:contentLocation"
            value="Nederlands-Indië"
            type="string"/>

    </xsl:template>
</xsl:stylesheet>
