<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:su="com.spinque.tools.importStream.Utils"
    xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
    xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:sdo="https://schema.org/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:europeana="http://www.europeana.eu/schemas/ese/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    extension-element-prefixes="spinque">

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:variable name="base">https://www.indischerfgoed.nl/</xsl:variable>

  	<xsl:template match="oai:record/oai:metadata/europeana:record">
        <!-- De dataset wordt voor Indisch Erfgoed eerst gefilterd op creatiedata tussen 1930 en 1969 -->
        <xsl:if test="su:matches(dcterms:created, '.*19[3-6].*') and su:matches(dc:subject, 'Koninklijke|vlootdagen')">
            <xsl:variable name="id" select="dc:identifier"/>
            <xsl:variable name="organizationId">nimh-beeldbank</xsl:variable>
            <xsl:variable name="record" select="su:uri($base, $organizationId, 'record', $id)"/>

            <spinque:relation subject="{$record}" predicate="rdf:type" object="sdo:CreativeWork"/>
            <!-- Deze collectie bestaat uit foto's en krijgt daarom de klasse schema:ImageObject -->
            <spinque:relation subject="{$record}" predicate="rdf:type" object="sdo:ImageObject"/>

            <!-- De object URL's, of in ieder geval een deel daarvan resolven niet -->
            <spinque:attribute subject="{$record}" attribute="sdo:url" value="{europeana:isShownAt}" type="string"/>
            <!-- De image URL's resolven wel -->
            <spinque:attribute subject="{$record}" attribute="sdo:image" value="{europeana:isShownBy}" type="string"/>
            <spinque:attribute subject="{$record}" attribute="sdo:identifier" value="{dc:identifier}" type="string"/>
            <!-- Er is geen titel, daarom wordt de description hier de titel -->
            <spinque:attribute subject="{$record}" attribute="sdo:name" value="{su:stripTags(dc:description)}" type="string"/>
            <spinque:attribute subject="{$record}" attribute="sdo:creator" value="{dc:creator}" type="string"/>
            <spinque:attribute subject="{$record}" attribute="sdo:material" value="{dc:type}" type="string"/>
            <spinque:relation subject="{$record}" predicate="sdo:publisher" object="niod:Organizations/4"/>
            <spinque:relation subject="{$record}" predicate="sdo:license" object="{europeana:rights}"/>
            <spinque:attribute subject="{$record}" attribute="sdo:creditText" value="{dcterms:isPartOf}" type="string"/>
            <spinque:attribute subject="{$record}" attribute="sdo:inLanguage" value="nl" type="string"/>

            <!-- Hier worden zoveel mogelijk bruikbare data onttrokken aan het veld dcterms:created  -->
            <xsl:choose>
                <!-- jaar - jaar -->
                <xsl:when test="su:matches(dcterms:created, '\d{4}\s*/\s*\d{4}')">
                  <spinque:attribute subject="{$record}" attribute="sdo:startDate" value="{substring(dcterms:created, 1,4)}" type="integer"/>
                  <spinque:attribute subject="{$record}" attribute="sdo:endDate" value="{substring(dcterms:created, string-length(dcterms:created)-4)}" type="integer"/>
                </xsl:when>
                <!-- jaar-maand-dag / jaar-maand-dag -->
                <xsl:when test="su:matches(dcterms:created, '\d{4}\s*-\s*\d{2}\s*-\s*\d{2}\s*/\s*\d{4}\s*-\s*\d{2}\s*-\s*\d{2}')">
                  <spinque:attribute subject="{$record}" attribute="sdo:startDate" value="{substring(dcterms:created, 1,10)}" type="date"/>
                  <spinque:attribute subject="{$record}" attribute="sdo:endDate" value="{su:trim(substring(dcterms:created, string-length(dcterms:created)-10))}" type="date"/>
                </xsl:when>
                <!-- jaar:maand:dag / jaar:maand:dag -->
                <xsl:when test="su:matches(dcterms:created, '\d{4}\s*:\s*\d{2}\s*:\s*\d{2}\s*/\s*\d{4}\s*:\s*\d{2}\s*:\s*\d{2}')">
                  <spinque:attribute subject="{$record}" attribute="sdo:startDate" value="{substring(su:replaceAll(dcterms:created,':','-'), 1,10)}" type="date"/>
                  <spinque:attribute subject="{$record}" attribute="sdo:endDate" value="{su:trim(substring(su:replaceAll(dcterms:created,':','-'), string-length(dcterms:created)-10))}" type="date"/>
                </xsl:when>
                <!-- jaar-maand-dag / -->
                <xsl:when test="su:matches(dcterms:created, '\d{4}\s*-\s*\d{2}\s*-\s*\d{2}\s*/')">
                  <spinque:attribute subject="{$record}" attribute="sdo:startDate" value="{substring(dcterms:created, 1,10)}" type="date"/>
                </xsl:when>
                <!-- jaar *whatever* / -->
                <xsl:when test="su:matches(dcterms:created, '\d{4}.*/')">
                  <spinque:attribute subject="{$record}" attribute="sdo:startDate" value="{substring(dcterms:created, 1,4)}" type="integer"/>
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
        </xsl:if>
    </xsl:template>

    <xsl:template match="dc:subject">
        <!-- Meerdere termen in één veld, gescheiden door komma's worden hier als van elkaar gesplitst -->
        <xsl:param name="record"/>
        <xsl:for-each select="su:split(., ',')">
            <spinque:attribute subject="{$record}" attribute="sdo:about" type="string" value="{.}"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="dcterms:spatial">
        <!-- De locatie is in de data geformatteerd als plaats, provincie, land. Dit wordt hier van elkaar gesplitst, maar is dat een goed idee? -->
        <xsl:param name="record"/>
        <xsl:for-each select="su:split(., ',')">
            <spinque:attribute subject="{$record}" attribute="sdo:contentLocation" type="string" value="{.}"/>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
