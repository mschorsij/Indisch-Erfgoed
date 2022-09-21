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
    xmlns:niod="https://data.niod.nl/"
    extension-element-prefixes="spinque">

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:variable name="base">https://www.indischerfgoed.nl/</xsl:variable>

  	<xsl:template match="europeana:record">
        <!-- De WOII Beeldbank van het NIOD gebruiken we alleen voor de volgende instellingen: Bronbeek, Fries Film Archief, Legermuseum, Maritiem Museum Rotterdam, Historisch Centrum Overijssel, NIOD. Overige instellingen halen we rechtstreeks bij de bron op -->
    		<xsl:if test="(dc:publisher = 'Bronbeek')
    			or (dc:publisher = 'Fries Film Archief')
    			or (dc:publisher= 'Legermuseum')
    			or (dc:publisher = 'Maritiem Museum Rotterdam')
          or (dc:publisher = 'Historisch Centrum Overijssel')
    			or (dc:publisher = 'NIOD')">

            <xsl:variable name="id" select="dc:identifier"/>
            <xsl:variable name="organizationId">beeldbankwo2</xsl:variable>
            <xsl:variable name="record" select="su:uri($base, $organizationId, 'record', $id)"/>

            <spinque:relation subject="{$record}" predicate="rdf:type" object="sdo:CreativeWork"/>
            <spinque:attribute subject="{$record}" attribute="sdo:url" value="{europeana:isShownAt}" type="string"/>
            <spinque:attribute subject="{$record}" attribute="sdo:identifier" value="{dc:identifier}" type="string"/>
            <spinque:attribute subject="{$record}" attribute="sdo:creator" value="{dc:creator}" type="string"/>
            <spinque:attribute subject="{$record}" attribute="sdo:contentUrl" value="{europeana:isShownBy}" type="string"/>
            <!-- Indien mogelijk naast de publisher nog iets doen met de collectie waar het object uit komt? -->
            <!-- <spinque:attribute subject="{$record}" attribute="sdo:creditText" value="{dcterms:isPartOf}" type="string"/> -->
            <spinque:attribute subject="{$record}" attribute="sdo:inLanguage" value="nl" type="string"/>

            <!-- Er is vaak geen titel, in dat geval wordt de description ingekort als titel gebruikt -->
            <xsl:choose>
                <xsl:when test="dc:title != ''">
                    <spinque:attribute subject="{$record}" attribute="sdo:name" value="{dc:title}" type="string"/>
                    <spinque:attribute subject="{$record}" attribute="sdo:abstract" value="{dc:description}" type="string"/>
                </xsl:when>
                <xsl:when test="string-length(dc:description)&gt;50">
                    <spinque:attribute subject="{$record}" attribute="sdo:name" value="{su:substringBeforeLast(substring(dc:description,1,50), '. ')}" type="string"/>
                    <spinque:attribute subject="{$record}" attribute="sdo:abstract" value="{dc:description}" type="string"/>
                </xsl:when>
                <xsl:otherwise>
                    <spinque:attribute subject="{$record}" attribute="sdo:name" value="{dc:description}" type="string"/>
                </xsl:otherwise>
            </xsl:choose>

            <!-- Als dc:rights leeg is: Rechten onbekend -->
            <xsl:choose>
                <xsl:when test="dc:rights != ''">
                    <spinque:attribute subject="{$record}" attribute="sdo:license" value="{dc:rights}"  type="string"/>
                </xsl:when>
                <xsl:otherwise>
                    <spinque:attribute subject="{$record}" attribute="sdo:license" value="Rechten onbekend"  type="string"/>
                </xsl:otherwise>
            </xsl:choose>

            <!-- type wordt vertaald naar juiste schema klasse en leesbare tekst: Foto / Film -->
            <xsl:choose>
                <xsl:when test="contains(dc:type, 'image')">
                    <spinque:attribute subject="{$record}" attribute="sdo:material" value="Foto" type="string"/>
                    <spinque:relation subject="{$record}" predicate="rdf:type" object="sdo:ImageObject"/>
                </xsl:when>
                <xsl:when test="contains(dc:type, 'video')">
                    <spinque:attribute subject="{$record}" attribute="sdo:material" value="Film" type="string"/>
                    <spinque:relation subject="{$record}" predicate="rdf:type" object="sdo:VideoObject"/>
                </xsl:when>
            </xsl:choose>

            <!-- Omdat de publisher wisselt en uit de data wordt gehaald is er niet een automatische link met de thesaurus -->
            <xsl:choose>
                <xsl:when test="contains(dc:publisher, 'NIOD')">
                    <spinque:relation subject="{$record}" predicate="sdo:publisher" object="niod:Organizations/116"/>
                </xsl:when>
                <xsl:when test="contains(dc:publisher, 'Fries')">
                    <spinque:relation subject="{$record}" predicate="sdo:publisher" object="niod:Organizations/7"/>
                </xsl:when>
                <xsl:when test="contains(dc:publisher, 'Bronbeek')">
                    <spinque:relation subject="{$record}" predicate="sdo:publisher" object="niod:Organizations/821"/>
                </xsl:when>
                <xsl:when test="contains(dc:publisher, 'Legermuseum')">
                    <spinque:relation subject="{$record}" predicate="sdo:publisher" object="niod:Organizations/21"/>
                </xsl:when>
                <xsl:when test="contains(dc:publisher, 'Maritiem')">
                    <spinque:relation subject="{$record}" predicate="sdo:publisher" object="niod:Organizations/97"/>
                </xsl:when>
                 <xsl:when test="contains(dc:publisher, 'Overijssel')">
                    <spinque:relation subject="{$record}" predicate="sdo:publisher" object="niod:Organizations/13"/>
                </xsl:when>
            </xsl:choose>

            <xsl:apply-templates select="dc:date">
                <xsl:with-param name="record" select="$record"/>
            </xsl:apply-templates>

            <xsl:apply-templates select="dcterms:temporal">
                <xsl:with-param name="record" select="$record"/>
            </xsl:apply-templates>

            <xsl:apply-templates select="dc:subject">
                <xsl:with-param name="record" select="$record"/>
            </xsl:apply-templates>

            <xsl:apply-templates select="dc:coverage">
                <xsl:with-param name="record" select="$record"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dc:date">
        <xsl:param name="record"/>
        <!-- Hier wordt waar nodig de datum in het veld dc:date omgedraaid. Een andere optie is om dan niets te doen, want volgens mij staat dc:date altijd in beide varianten in de data -->
        <xsl:choose>
            <!-- jaar-maand-dag -->
            <xsl:when test="su:matches(., '\d{4}-\d{2}-\d{2}') and not(contains(., '00-'))">
              <spinque:attribute subject="{$record}" attribute="sdo:date" value="{.}" type="date"/>
            </xsl:when>
            <!-- dag-maand-jaar -->
            <xsl:when test="su:matches(., '\d{2}-\d{2}-\d{4}') and not(contains(., '00-'))">
                <spinque:attribute subject="{$record}" attribute="sdo:date" value="{su:parseDate(., 'dd-MM-yyyy', 'd-M-yyyy')}" type="date"/>
            </xsl:when>
            <xsl:otherwise>
                <spinque:attribute subject="{$record}" attribute="sdo:temporal" value="{.}"  type="string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dcterms:temporal">
        <xsl:param name="record"/>
        <!-- Hier worden nog zoveel mogelijk bruikbare data onttrokken aan het veld dcterms:temporal.  -->
        <xsl:choose>
          <!-- dag-maand-jaar t/m dag-maand-jaar -->
          <xsl:when test="su:matches(., '^\d{1,2}-\d{1,2}-\d{4}.*/.*\d{1,2}-\d{1,2}-\d{4}$') and not(contains(., '00-'))">
              <spinque:attribute subject="{$record}" attribute="sdo:startDate" value="{su:parseDate(su:substringBefore(., ' '), 'dd-MM-yyyy', 'd-M-yyyy')}" type="date"/>
              <spinque:attribute subject="{$record}" attribute="sdo:endDate" value="{su:parseDate(su:substringAfterLast(., ' '), 'dd-MM-yyyy', 'd-M-yyyy')}" type="date"/>
          </xsl:when>
          <!-- dag-maand-jaar -->
          <xsl:when test="su:matches(., '^\d{1,2}-\d{1,2}-\d{4}$') and not(contains(., '00-'))">
              <spinque:attribute subject="{$record}" attribute="sdo:date" value="{su:parseDate(., 'dd-MM-yyyy', 'd-M-yyyy')}" type="date"/>
          </xsl:when>
          <!-- dag maand(in tekst) jaar -->
          <xsl:when test="su:matches(., '^\d{1,2}\s\D*\s\d{4}$')">
              <spinque:attribute subject="{$record}" attribute="sdo:date" value="{su:parseDate(., 'nl-nl', 'd MMMM yyyy', 'dd MMMM yyyy')}" type="date"/>
          </xsl:when>
          <!-- jaar t/m jaar -->
          <xsl:when test="su:matches(., '^\d{4}.*[-/].*\d{4}$')">
            <spinque:attribute subject="{$record}" attribute="sdo:startDate" value="{substring(., 1,4)}" type="integer"/>
            <spinque:attribute subject="{$record}" attribute="sdo:endDate" value="{su:trim(substring(., string-length(.)-4))}" type="integer"/>
          </xsl:when>
          <!-- jaar -->
          <xsl:when test="su:matches(., '^\d{4}$')">
            <spinque:attribute subject="{$record}" attribute="sdo:date" value="{.}" type="integer"/>
          </xsl:when>
          <xsl:otherwise>
              <spinque:attribute subject="{$record}" attribute="sdo:temporal" value="{.}"  type="string"/>
          </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dc:subject">
        <xsl:param name="record"/>
        <spinque:attribute subject="{$record}" attribute="sdo:keywords" type="string" value="{.}"/>
    </xsl:template>

    <xsl:template match="dc:coverage">
        <xsl:param name="record"/>
        <spinque:attribute subject="{$record}" attribute="sdo:contentLocation" type="string" value="{.}"/>
    </xsl:template>
</xsl:stylesheet>
