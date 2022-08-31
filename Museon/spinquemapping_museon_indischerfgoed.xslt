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

    <xsl:template match="Records">
        <xsl:variable name="id" select="ccObjectID"/>
        <xsl:variable name="organizationId">museon</xsl:variable>
        <xsl:variable name="record" select="su:uri($base, $organizationId, 'record', $id)"/>

        <spinque:relation subject="{$record}" predicate="rdf:type" object="sdo:CreativeWork"/>
        <!-- Deze collectie bestaat uit diverse vormen van beeldmateriaal en krijgt daarom de klasse schema:VisualArtwork -->
        <spinque:relation subject="{$record}" predicate="rdf:type" object="sdo:VisualArtwork"/>

        <spinque:attribute subject="{$record}" attribute="sdo:url" value="{europeana_isshownat}" type="string"/>
        <spinque:attribute subject="{$record}" attribute="sdo:image" value="{concat('https://cc.museon.nl/imageproxy.aspx?server=localhost&amp;port=17512&amp;filename=images/', image)}" type="string"/>
        <spinque:attribute subject="{$record}" attribute="sdo:identifier" value="{invnrobjnaam}" type="string"/>
        <spinque:attribute subject="{$record}" attribute="sdo:abstract" value="{dc_description}"  lang="nl" type="string"/>
        <spinque:attribute subject="{$record}" attribute="sdo:material" value="{icn_material}" type="string"/>
        <spinque:relation subject="{$record}" predicate="sdo:publisher" object="niod:Organizations/28"/>
        <spinque:relation subject="{$record}" predicate="sdo:license" object="https://creativecommons.org/licenses/by/4.0/"/>
        <spinque:attribute subject="{$record}" attribute="sdo:license" value="CC-BY 4.0" type="string"/>
        <spinque:attribute subject="{$record}" attribute="sdo:inLanguage" value="nl" type="string"/>

        <!-- Hier worden zoveel mogelijk bruikbare data onttrokken aan het veld dc_date  -->
        <xsl:choose>
            <!-- jaar -->
            <xsl:when test="su:matches(dc_date, '\d{4}')">
                <spinque:attribute subject="{$record}" attribute="sdo:startDate" value="{dc_date}" type="integer"/>
            </xsl:when>
            <!-- jaar-jaar -->
            <xsl:when test="su:matches(dc_date, '\d{4}-\d{4}')">
              <spinque:attribute subject="{$record}" attribute="sdo:startDate" value="{substring(dc_date, 1,4)}" type="integer"/>
              <spinque:attribute subject="{$record}" attribute="sdo:endDate" value="{substring(dc_date, 6,9)}" type="integer"/>
            </xsl:when>
            <!-- dag maand (tekst) jaar -->
            <xsl:when test="su:matches(dc_date, '\d{1,2}\s\w+\s\d{4}')">
                <spinque:attribute subject="{$record}" attribute="sdo:startDate" value="{su:parseDate(dc_date, 'nl-nl', 'dd MMM yyyy')}" type="date"/>
            </xsl:when>
            <!-- Alle andere situaties -->
            <xsl:otherwise>
                <spinque:attribute subject="{$record}" attribute="sdo:temporal" value="{dc_date}" type="string"/>
            </xsl:otherwise>
        </xsl:choose>

        <!-- Hier wordt een titel gemaakt uit de velden dc_type en dc_title  -->
        <xsl:choose>
           <!-- Er is een type en een titel. Format wordt Type: Titel-->
            <xsl:when test="(dc_title != '' and dc_type != '')">
                <xsl:variable name="title" select="dc_title/text()[1]"/>
                <xsl:variable name="type" select="su:capitalize(dc_type, 'titlecase')"/>
                <xsl:choose>
                    <!-- Maximaal 100 karakters uit het titel veld gebruiken  -->
                    <xsl:when test="string-length($title) &gt; 101">
                        <spinque:attribute subject="{$record}" attribute="sdo:name" value="{concat($type, ': ', substring($title, 1,100), '...')}" type="string"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <spinque:attribute subject="{$record}" attribute="sdo:name" value="{concat($type, ': ', $title)}" type="string"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- Er is alleen een titel. Format wordt Titel -->
            <xsl:when test="(dc_title != '' and dc_type = '')">
                <xsl:variable name="title" select="dc_title/text()[1]"/>
                <xsl:choose>
                    <!-- Maximaal 100 karakters uit het titel veld gebruiken  -->
                    <xsl:when test="string-length($title) &gt; 101">
                        <spinque:attribute subject="{$record}" attribute="sdo:name" value="{concat(substring($title, 1,100), '...')}" type="string"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <spinque:attribute subject="{$record}" attribute="sdo:name" value="{$title}" type="string"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- Er is geen titel: gebruik het type als titel -->
            <xsl:otherwise>
                <xsl:variable name="title" select="su:capitalize(dc_type, 'titlecase')"/>
                <spinque:attribute subject="{$record}" attribute="sdo:name" value="{$title}" type="string"/>
            </xsl:otherwise>
        </xsl:choose>

        <!-- <xsl:if test="IsJapan != ''">
            <spinque:attribute subject="{$record}" attribute="sdo:contentLocation" value="Nederlands-Indië" type="string"/>
        </xsl:if> -->

        <xsl:apply-templates select="dc_creator">
            <xsl:with-param name="record" select="$record"/>
            <xsl:with-param name="organizationId" select="$organizationId"/>
            <xsl:with-param name="id" select="$id"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="dc_subject">
            <xsl:with-param name="record" select="$record"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="dc_coverage">
            <xsl:with-param name="record" select="$record"/>
        </xsl:apply-templates>

    </xsl:template>

    <xsl:template match="dc_creator">
        <xsl:param name="record"/>
        <xsl:param name="organizationId"/>
        <xsl:param name="id"/>
            <xsl:choose>
                <!-- Als dc_creator (Vervaardiger) bevat gebruik dan het deel voor deze tekst als creator en maak er een persoon van. -->
                <xsl:when test="contains(., '(Vervaardiger)')">
                  <xsl:variable name="name" select="substring-before(., ' (')"/>
                  <xsl:variable name="person" select="su:uri($base, $organizationId, 'person', su:replaceAll(su:normalizeWhiteSpace($name), ' ', '-'), $id)"/>
                  <spinque:relation subject="{$record}" predicate="sdo:creator" object="{$person}"/>
                  <xsl:call-template name="person">
                      <xsl:with-param name="person" select="$person"/>
                      <xsl:with-param name="record" select="$record"/>
                      <xsl:with-param name="name" select="$name"/>
                  </xsl:call-template>
                  </xsl:when>
                <!-- Gebruik in alle andere gevallen de hele tekst en maak daar een contributer van, omdat het niet zeker is dat het een persoon is, of dat het om de vervaardiger gaat. -->
                <xsl:otherwise>
                  <xsl:variable name="contributor" select="./text()[1]"/>
                    <spinque:attribute subject="{$record}" attribute="sdo:contributor" value="{$contributor}" type="string"/>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>

    <xsl:template match="dc_subject">
        <xsl:param name="record"/>
            <spinque:attribute subject="{$record}" attribute="sdo:about" type="string" value="{.}"/>
    </xsl:template>

    <xsl:template match="dc_coverage">
        <xsl:param name="record"/>
        <xsl:choose>
            <xsl:when test="contains(., '(')">
                <spinque:attribute subject="{$record}" attribute="sdo:contentLocation" value="{substring-before(., '(')}" type="string"/>
            </xsl:when>
            <!-- Als de locatie een kamp is wordt het een trefwoord, zodat het gematcht kan worden met de WO2_Thesaurus -->
            <xsl:when test="contains(su:lowercase(.), 'kamp')">
                <spinque:attribute subject="{$record}" attribute="sdo:about" value="{.}"  type="string" />
            </xsl:when>
            <xsl:otherwise>
                <spinque:attribute subject="{$record}" attribute="sdo:contentLocation" value="{.}" type="string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="person">
        <xsl:param name="person"/>
        <xsl:param name="record"/>
        <xsl:param name="name"/>
        <spinque:relation subject="{$person}" predicate="rdf:type" object="sdo:Person"/>
        <spinque:relation subject="{$person}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:attribute subject="{$person}" attribute="sdo:name" value="{$name}" type="string"/>
        <spinque:attribute subject="{$person}" attribute="sdo:description" value="{biography}" type="string"/>
        <xsl:choose>
          <!-- displaydate geeft informatie over geboorte en/of sterfdatum van de creator. De onderstaande varianten komen voor -->
        <xsl:when test="su:matches(displaydate, '\d{4}\s*-\s*\d{4}')">
            <spinque:attribute subject="{$person}" attribute="sdo:birthDate" value="{substring(displaydate, 1,4)}" type="integer"/>
            <spinque:attribute subject="{$person}" attribute="sdo:deathDate" value="{su:trim(substring(displaydate, string-length(displaydate)-4))}" type="integer"/>
        </xsl:when>
        <xsl:when test="su:matches(su:lowercase(displaydate), 'geboren\s*\d{4}')">
            <spinque:attribute subject="{$person}" attribute="sdo:birthDate" value="{substring-after(su:lowercase(displaydate), 'geboren ')}" type="integer"/>
        </xsl:when>
        <xsl:when test="su:matches(su:lowercase(displaydate), 'gestorven\s*\d{4}')">
            <spinque:attribute subject="{$person}" attribute="sdo:deathDate" value="{substring-after(su:lowercase(displaydate), 'gestorven ')}" type="integer"/>
        </xsl:when>
      </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
