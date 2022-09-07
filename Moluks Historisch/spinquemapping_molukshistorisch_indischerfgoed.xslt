<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:su="com.spinque.tools.importStream.Utils"
    xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
    xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:edm="http://www.europeana.eu/schemas/edm/"
    xmlns:nave="http://schemas.delving.eu/nave/terms/"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:niod="https://data.niod.nl/"
    xmlns:schema="https://schema.org/"
    extension-element-prefixes="spinque">

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:variable name="base">https://www.indischerfgoed.nl/</xsl:variable>

    <xsl:template match="rdf:RDF">
        <!-- De dataset wordt voor Indisch Erfgoed eerst gefilterd op creatiedata tussen 1930 en 1969 -->
        <!-- Filter staat uit voor testpurposes -->
        <!-- <xsl:if test="su:matches(edm:ProvidedCHO/dcterms:created, '.*19[3-6].*')"> -->
            <xsl:variable name="id" select="su:replaceAll(edm:ProvidedCHO/dc:identifier, ' ', '-')"/>
            <xsl:variable name="organizationId">molukshistorisch</xsl:variable>
            <xsl:variable name="record" select="su:uri($base, $organizationId, 'record', $id)"/>

            <spinque:relation subject="{$record}" predicate="rdf:type" object="sdo:CreativeWork"/>
            <!-- Deze collectie bestaat uit foto's en krijgt daarom de klasse schema:ImageObject -->
            <spinque:relation subject="{$record}" predicate="rdf:type" object="sdo:ImageObject"/>

            <spinque:attribute subject="{$record}" attribute="sdo:url" value="{edm:ProvidedCHO/@rdf:about}" type="string"/>
            <spinque:attribute subject="{$record}" attribute="sdo:image" value="{ore:Aggregation/edm:isShownBy/@rdf:resource}" type="string"/>
            <spinque:attribute subject="{$record}" attribute="sdo:identifier" value="{edm:ProvidedCHO/dc:identifier}" type="string"/>
            <spinque:attribute subject="{$record}" attribute="sdo:name" value="{edm:ProvidedCHO/dc:title}" type="string"/>
            <spinque:attribute subject="{$record}" attribute="sdo:abstract" value="{edm:ProvidedCHO/dc:description}"  lang="nl" type="string"/>
            <spinque:attribute subject="{$record}" attribute="sdo:creator" value="{edm:ProvidedCHO/dc:creator}" type="string"/>
            <spinque:attribute subject="{$record}" attribute="sdo:material" value="{edm:ProvidedCHO/dc:type}" type="string"/>
            <spinque:relation subject="{$record}" predicate="sdo:publisher" object="niod:Organizations/60"/>
            <spinque:relation subject="{$record}" predicate="sdo:license" object="{ore:Aggregation/edm:rights/@rdf:resource}"/>
            <spinque:attribute subject="{$record}" attribute="sdo:license" value="{ore:Aggregation/dc:rights}" type="string"/>
            <spinque:attribute subject="{$record}" attribute="sdo:inLanguage" value="nl" type="string"/>

            <!-- Hier worden zoveel mogelijk bruikbare data onttrokken aan het veld dcterms:created  -->
            <xsl:choose>
                <!-- jaar -->
                <xsl:when test="su:matches(edm:ProvidedCHO/dcterms:created, '\d{4}')">
                    <spinque:attribute subject="{$record}" attribute="sdo:startDate" value="{edm:ProvidedCHO/dcterms:created}" type="integer"/>
                </xsl:when>
                <!-- jaar - jaar -->
                <xsl:when test="su:matches(edm:ProvidedCHO/dcterms:created, '\d{4}\s*-\s*\d{4}')">
                  <spinque:attribute subject="{$record}" attribute="sdo:startDate" value="{substring(edm:ProvidedCHO/dcterms:created, 1,4)}" type="integer"/>
                  <spinque:attribute subject="{$record}" attribute="sdo:endDate" value="{su:trim(substring(edm:ProvidedCHO/dcterms:created, string-length(dcterms:created)-4))}" type="integer"/>
                </xsl:when>
                <!-- dag maand (tekst) jaar -->
                <xsl:when test="su:matches(edm:ProvidedCHO/dcterms:created, '\d{1,2}\s\w+\s\d{4}')">
                    <spinque:attribute subject="{$record}" attribute="sdo:startDate" value="{su:parseDate(edm:ProvidedCHO/dcterms:created, 'nl-nl', 'dd MMM yyyy')}" type="date"/>
                </xsl:when>
                <!-- Alle andere situaties -->
                <xsl:otherwise>
                    <spinque:attribute subject="{$record}" attribute="sdo:temporal" value="{edm:ProvidedCHO/dcterms:created}" type="string"/>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:apply-templates select="edm:ProvidedCHO/dc:subject">
                <xsl:with-param name="record" select="$record"/>
            </xsl:apply-templates>

            <xsl:apply-templates select="edm:ProvidedCHO/dcterms:spatial">
                <xsl:with-param name="record" select="$record"/>
            </xsl:apply-templates>
        <!-- </xsl:if> -->
    </xsl:template>

    <xsl:template match="edm:ProvidedCHO/dc:subject">
        <xsl:param name="record"/>
        <spinque:attribute subject="{$record}" attribute="sdo:keywords" type="string" value="{.}"/>
    </xsl:template>

    <xsl:template match="edm:ProvidedCHO/dcterms:spatial">
        <xsl:param name="record"/>
        <spinque:attribute subject="{$record}" attribute="sdo:contentLocation" type="string" value="{.}"/>
    </xsl:template>

</xsl:stylesheet>
