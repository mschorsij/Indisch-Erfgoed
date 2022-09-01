<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:su="com.spinque.tools.importStream.Utils"
    xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
    xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    extension-element-prefixes="spinque">

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:variable name="base">https://www.indischerfgoed.nl/</xsl:variable>

    <xsl:template match="oai_dc:dc">
    <!--filter voor Nederlands-Indie content in collectie -->
	   <xsl:if test="contains(dc:subject, 'propaganda') or contains(su:lowercase(dc:subject), 'oorlogen') or contains(dc:subject, 'mobilisatie') or contains(dc:subject, 'bevrijding') or contains(../../oai:header/oai:setSpec[2], 'propaganda') or contains(dc:subject, 'Indonesi') or contains(dc:subject, 'Nederlands-Indi') or contains(su:lowercase(dc:subject), 'japanse bezetting') or contains(dc:subject, 'Soekarno') or contains(dc:subject, 'politionele') or contains(dc:coverage, 'Batavia') or contains(dc:coverage, 'Nederlands-Indi') or contains(dc:coverage, 'Indonesi') or contains(su:lowercase(dc:title), 'Nieuws uit')">

    <!--create id -->
        <xsl:variable name="id" select="dc:identifier"/>
        <xsl:variable name="organizationId">beeldengeluid</xsl:variable>
        <xsl:variable name="record" select="su:uri($base, $organizationId, 'record', $id)"/>
        <spinque:attribute subject="{$record}" attribute="sdo:url" value="{concat('https://www.openbeelden.nl/media/',  substring-after(../../oai:header/oai:identifier, 'openimages.eu:'))}" type="string"/>
        <spinque:relation subject="{$record}" predicate="rdf:type" object="sdo:CreativeWork"/>
        <spinque:relation subject="{$record}" predicate="rdf:type" object="sdo:VideoObject"/>
        <spinque:attribute subject="{$record}" attribute="sdo:identifier" value="{dc:identifier}" type="string"/>
        <spinque:attribute subject="{$record}" attribute="sdo:inLanguage" value="nl" type="string"/>
        <spinque:attribute subject="{$record}" attribute="sdo:abstract" value="{dc:description}"  lang="nl" type="string"/>
        <spinque:relation subject="{$record}" predicate="sdo:publisher" object="niod:Organizations/11"/> <!-- willen we hier NIOD ids voor blijven gebruiken? -->
        <spinque:relation subject="{$record}" predicate="sdo:usageInfo" object="{dc:rights}"/>
        <spinque:attribute subject="{$record}" attribute="sdo:date" value="{dc:date}" type="date"/>

            <xsl:apply-templates select="dc:subject">
                <xsl:with-param name="record" select="$record"/>
            </xsl:apply-templates>

            <xsl:apply-templates select="dc:format">
                <xsl:with-param name="record" select="$record"/>
            </xsl:apply-templates>

            <xsl:apply-templates select="dc:coverage">
                <xsl:with-param name="record" select="$record"/>
            </xsl:apply-templates>
          </xsl:if>
        </xsl:template>

        <xsl:template match="dc:subject">
            <xsl:param name="record"/>
            <spinque:attribute subject="{$record}" attribute="sdo:about" type="string" value="{.}"/>
        </xsl:template>


        <xsl:template match="dc:format">
            <xsl:param name="record"/>
            <xsl:choose>
			    <xsl:when test="contains(su:lowercase(.), 'mp4')">
				    <spinque:attribute subject="{$record}" attribute="sdo:contentUrl" value="{.}" type="string"/>
			    </xsl:when>
			    <xsl:when test="contains(su:lowercase(.), 'webm')">
				    <spinque:attribute subject="{$record}" attribute="sdo:contentUrl" value="{.}" type="string"/>
			    </xsl:when>
            </xsl:choose>
             <xsl:choose>
                <xsl:when test="contains(su:lowercase(.), 'png')">
                    <spinque:attribute subject="{$record}" attribute="sdo:thumbnail" value="{.}" type="string"/>
                </xsl:when>
            </xsl:choose>
        </xsl:template>

        <xsl:template match="dc:coverage">
            <xsl:param name="record"/>
            <spinque:attribute subject="{$record}" attribute="sdo:contentLocation" type="string" value="{.}"/>
        </xsl:template>


</xsl:stylesheet>
