<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:su="com.spinque.tools.importStream.Utils"
    xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
    xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:sdo="https://schema.org/"
    xmlns:europeana="h"
    xmlns:dc="h"
    xmlns:dcterms="h"
    xmlns:delving="h"
    extension-element-prefixes="spinque">

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:variable name="base">https://www.indischerfgoed.nl/</xsl:variable>

	<xsl:template match="oai:record/oai:metadata/oai:record">
        <xsl:variable name="id" select="su:replaceAll(dc:identifier, ' ', '-')"/>
        <xsl:variable name="organizationId">molukshistorisch</xsl:variable>
        <xsl:variable name="record" select="su:uri($base, $organizationId, 'record', $id)"/>

        <spinque:relation subject="{$record}" predicate="rdf:type" object="sdo:CreativeWork"/>
        <!-- Deze collectie bestaat uit foto's en krijgt daarom de klasse schema:ImageObject -->
        <spinque:relation subject="{$record}" predicate="rdf:type" object="sdo:ImageObject"/>

        <spinque:attribute subject="{$record}" attribute="sdo:url" value="{europeana:isShownAt}" type="string"/>
        <spinque:attribute subject="{$record}" attribute="sdo:image" value="{europeana:isShownBy}" type="string"/>
        <spinque:attribute subject="{$record}" attribute="sdo:identifier" value="{dc:identifier}" type="string"/>
        <spinque:attribute subject="{$record}" attribute="sdo:name" value="{dc:title}" type="string"/>
        <spinque:attribute subject="{$record}" attribute="sdo:abstract" value="{dc:description}"  lang="nl" type="string"/>
        <spinque:attribute subject="{$record}" attribute="sdo:creator" value="{dc:creator}" type="string"/>
        <spinque:attribute subject="{$record}" attribute="sdo:material" value="{dc:type}" type="string"/>
        <!-- Zolang geen onderscheid kan worden gemaakt tussen europeana:type en dc:type wordt schema:material niet opgenomen -->
        <!-- <spinque:attribute subject="{$record}" attribute="sdo:material" value="{dc:type}" type="string"/> -->
        <spinque:relation subject="{$record}" predicate="sdo:publisher" object="niod:Organizations/60"/>
        <!-- Zolang geen onderscheid kan worden gemaakt tussen europeana:rights en dc:rights wordt een apart template gebruikt om deze te scheiden -->
        <!-- <spinque:relation subject="{$record}" predicate="sdo:usageInfo" object="{europeana:rights}"/> -->
        <!-- <spinque:attribute subject="{$record}" attribute="sdo:usageInfo" value="{dc:rights}" type="string"/> -->
        <spinque:attribute subject="{$record}" attribute="sdo:inLanguage" value="nl" type="string"/>

        <!-- Hier worden zoveel mogelijk bruikbare data onttrokken aan het veld dcterms:created  -->
        <xsl:choose>
            <!-- jaar -->
            <xsl:when test="su:matches(dcterms:created, '\d{4}')">
                <spinque:attribute subject="{$record}" attribute="sdo:startDate" value="{dcterms:created}" type="integer"/>
            </xsl:when>
            <!-- jaar - jaar -->
            <xsl:when test="su:matches(dcterms:created, '\d{4}\s*-\s*\d{4}')">
              <spinque:attribute subject="{$record}" attribute="sdo:startDate" value="{substring(dcterms:created, 1,4)}" type="integer"/>
              <spinque:attribute subject="{$record}" attribute="sdo:endDate" value="{su:trim(substring(dcterms:created, string-length(dcterms:created)-4))}" type="integer"/>
            </xsl:when>
            <!-- dag maand (tekst) jaar -->
            <xsl:when test="su:matches(dcterms:created, '\d{1,2}\s\w+\s\d{4}')">
                <spinque:attribute subject="{$record}" attribute="sdo:startDate" value="{su:parseDate(dcterms:created, 'nl-nl', 'dd MMM yyyy')}" type="date"/>
            </xsl:when>
            <!-- Alle andere situaties -->
            <xsl:otherwise>
                <spinque:attribute subject="{$record}" attribute="sdo:temporal" value="{dcterms:created}" type="string"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:apply-templates select="dc:subject">
            <xsl:with-param name="record" select="$record"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="dcterms:spatial">
            <xsl:with-param name="record" select="$record"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="europeana:rights">
            <xsl:with-param name="record" select="$record"/>
        </xsl:apply-templates>

        </xsl:template>

        <xsl:template match="dc:subject">
            <xsl:param name="record"/>
            <spinque:attribute subject="{$record}" attribute="sdo:about" type="string" value="{.}"/>
        </xsl:template>

        <xsl:template match="dcterms:spatial">
            <xsl:param name="record"/>
            <spinque:attribute subject="{$record}" attribute="sdo:contentLocation" type="string" value="{.}"/>
        </xsl:template>

        <!-- mdat er geen onderscheid kan worden gemaakt tussen europeana:rights en dc:rights wordt hier gekeken naar de inhoud van die velden. Als er http in staat wordt het een relatie naar een URL en anders een text string -->
        <xsl:template match="europeana:rights">
            <xsl:param name="record"/>
            <xsl:choose>
                <xsl:when test="contains(.,'http')">
                    <spinque:relation subject="{$record}" predicate="sdo:license" object="{.}"/>
                    <spinque:debug message="Link: {.}"/>
                </xsl:when>
                <xsl:otherwise>
                    <spinque:attribute subject="{$record}" attribute="sdo:creditText" value="{.}" type="string"/>
                    <spinque:debug message="String: {.}"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:template>
</xsl:stylesheet>
