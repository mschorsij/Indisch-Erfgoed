<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:su="com.spinque.tools.importStream.Utils"
	xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
	xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
	xmlns:ese="http://www.europeana.eu/schemas/ese/"
	xmlns:europeana="http://www.europeana.eu/schemas/ese/"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:oai="http://www.openarchives.org/OAI/2.0/"
	xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:schema="http://schema.org/"
	extension-element-prefixes="spinque">

	<xsl:output method="text" encoding="UTF-8"/>

	<!-- *** Entry point for OAI-DC records  *** -->
	<xsl:template match="europeana:record">
		<!--<xsl:if test="(dc:publisher != 'niod_mus') or (dc:publisher != 'niod_raa') or (dc:publisher!= 'niod_nimh') or (dc:publisher != 'niod_saa') or (dc:publisher != 'niod_am') or (dc:publisher != 'niod_naa') or (dc:publisher != 'niod_nbm') or (dc:publisher != 'niod_sfa') or (dc:publisher != 'niod_hcl') or (dc:publisher != 'niod_gaw')"> -->
		<xsl:if test="not(dc:publisher = 'Stadsarchief Amsterdam')
			and not(dc:publisher = 'Museon')
			and not(dc:pubisher = 'Noord-Hollands Archief')">
			<xsl:if test="(contains(dc:type, 'image') or (contains(dc:type, 'video') and (dc:description != '')))">
			<xsl:variable name="subject">
				<xsl:choose>
					<xsl:when test="contains(europeana:isShownAt, ',')">
						<xsl:value-of
							select="su:replace(substring-before(europeana:isShownAt, ','), 'http:', 'https:')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="su:replace(europeana:isShownAt, 'http:', 'https:')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:call-template name="dc_record">
				<xsl:with-param name="subject" select="$subject"/>
			</xsl:call-template>
			</xsl:if>

		</xsl:if>
	</xsl:template>

	<!-- *** generic Dublin Core parser *** -->
	<xsl:template name="dc_record">
		<xsl:param name="subject"/>
		<xsl:choose>
			<xsl:when test="contains(europeana:isShownBy, 'niod_')"><spinque:attribute subject="{$subject}" attribute="schema:thumbnail" value="{concat(substring-before(europeana:isShownBy, '_'), '/thumb',substring-after(europeana:isShownBy, '/thumb'))}" type="string"/>
			</xsl:when>
			<xsl:otherwise>
				<spinque:attribute subject="{$subject}" attribute="schema:thumbnail" value="{su:replace(europeana:isShownBy, '640x480','1000x1000')}" type="string"/>
			</xsl:otherwise>
		</xsl:choose>

		<spinque:relation subject="http://beeldbankwo2.nl/nl/beelden/?mode=detail&amp;rows=1&amp;page=1&amp;q={dc:identifier}" predicate="http://www.w3.org/2002/07/owl#sameAs" object="{$subject}"/>
		<spinque:attribute subject="{$subject}" attribute="dc:source" value="{$subject}" type="string"/>
        <spinque:relation subject="{$subject}" predicate="dc:publisher" object="niod:Organizations/116"/>
        <spinque:attribute subject="{$subject}" attribute="dc:identifier" value="{dc:identifier}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:description" value="{dc:description}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:creator" value="{dc:creator}" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="dc:language" value="nl" type="string"/>
		<spinque:attribute subject="{$subject}" attribute="schema:disambiguatingDescription" value="In Oorlogsbronnen in set beeldbank_niod" type="string"/>
		<xsl:choose>
			<xsl:when test="contains(dc:creator, 'Huizinga') or contains(su:lowercase(dc:rights), 'public')">
				<spinque:relation subject="{$subject}" predicate="dc:rights" object="https://creativecommons.org/publicdomain/zero/1.0/"/>
				<spinque:attribute subject="{$subject}" attribute="dc:rights" value="Publiek Domein" type="string"/>
			</xsl:when>
			<xsl:when test="dc:rights = 'CC BY-SA'">
				<spinque:relation subject="{$subject}" predicate="dc:rights" object="https://creativecommons.org/licenses/by-sa/4.0/"/>
				<spinque:attribute  subject="{$subject}" attribute="dc:rights" value="CC BY-SA" type="string"/>
			</xsl:when>
			<xsl:when test="string-length(dc:rights) != ''">
				<spinque:relation subject="{$subject}" predicate="dc:rights" object="http://rightsstatements.org/vocab/InC/1.0/"/>
				<spinque:attribute subject="{$subject}" attribute="dc:rights" value="In Copyright" type="string"/>
			</xsl:when>
		</xsl:choose>

		<xsl:choose>
			<xsl:when test="dc:title != ''">
				<spinque:attribute subject="{$subject}" attribute="dc:title" value="{dc:title}" type="string"/>
			</xsl:when>
            <!--<xsl:when test="su:matches(substring(dc:description,30, string-length(dc:description)), '.*\.\s[A-Z].*')">
				<spinque:attribute subject="{$subject}" attribute="dc:title" value="{su:replaceAll(substring(dc:description, 30),'\.\s[A-Z].*')}" type="string"/>
                <spinque:debug message="{concat(substring(dc:description, 1,29), su:replaceAll(substring(dc:description, 30),'\.\s[A-Z].*','.'))}"/>
			</xsl:when>-->
			<xsl:otherwise>
				<spinque:attribute subject="{$subject}" attribute="dc:title" value="{dc:subject[1]}" type="string"/>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:choose>
			<xsl:when test="contains(dc:type, 'video')">
	    		<spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:VideoObject"/>
	    		<spinque:attribute subject="{$subject}" attribute="dc:type" value="bewegend beeld" type="string"/>
	    		<spinque:attribute subject="{$subject}" attribute="schema:video" value="{concat('https://streaming.memorix.nl/vod/mp4:niod:',europeana:object,'/playlist.m3u8')}" type="string"/>
	    		<!--spinque:attribute subject="{$subject}" attribute="schema:contentUrl" value="{.}" type="string"/-->
	    		<!--spinque:debug message="{dc:type}:{$subject}"/-->
			</xsl:when>
			<xsl:otherwise>
				<spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Photograph"/>
				<spinque:attribute subject="{$subject}" attribute="dc:type" value="foto" type="string"/>
			</xsl:otherwise>
		</xsl:choose>


		<xsl:for-each select="dc:coverage">
			<xsl:choose>
				<xsl:when test="not(contains(.,'Gemeente ')) and (. != 'Nederland')">
				<spinque:attribute subject="{$subject}" attribute="schema:contentLocation" value="{.}" type="string"/>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>

		<xsl:apply-templates select="dc:date">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dc:subject">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="europeana:uri">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dcterms:temporal">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<xsl:apply-templates select="dcterms:subject">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>

		<!--<xsl:apply-templates select="dc:coverage">
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:apply-templates>-->
	</xsl:template>

	<xsl:template match="dc:date">
		<xsl:param name="subject"/>
		<spinque:attribute subject="{$subject}" attribute="dc:date" value="{su:parseDate(su:replace(., '00', '01'), 'nl-nl', 'yyyy-MM-dd', 'yyyy-MM', 'dd-MM-yyyy')}" type="date"/>
	</xsl:template>

	<!--><xsl:template match="dcterms:temporal">
		<xsl:param name="subject"/>
		<xsl:choose>
			<xsl:when test="contains(., '-')">
			</xsl:when>
			<xsl:when test="contains(., ' ')">
				<spinque:attribute subject="{$subject}" attribute="dc:date" value="{substring-after(., ' ')}" type="integer"/>
			</xsl:when>
			<xsl:otherwise>
				<spinque:attribute subject="{$subject}" attribute="dc:date" value="{.}" type="integer"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>-->


	<!--europeana:uri bevat de uri van de thesaurus-->
	<xsl:template match="europeana:uri">
		<xsl:param name="subject"/>
		<spinque:relation subject="{$subject}" predicate="dc:subject" object="{.}"/>
	</xsl:template>

	<xsl:template match="dc:subject">
		<xsl:param name="subject"/>
				<xsl:choose>
			<xsl:when test="contains(.,',')">
				<spinque:attribute subject="{$subject}" attribute="schema:about" value="{concat(substring-after(.,', '), ' ', substring-before(.,','))}" type="string"/>
			</xsl:when>
			<xsl:otherwise>
				<spinque:attribute subject="{$subject}" attribute="dc:subject" value="{.}" type="string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="dcterms:subject">
		<xsl:param name="subject"/>
		<xsl:choose>
			<xsl:when test="contains(.,',')">
				<spinque:attribute subject="{$subject}" attribute="schema:about" value="{concat(substring-after(.,', '), ' ', substring-before(.,','))}" type="string"/>
				<!--spinque:debug message="{concat(substring-after(.,', '), ' ', substring-before(.,','))}"/-->
			</xsl:when>
			<xsl:otherwise>
				<spinque:attribute subject="{$subject}" attribute="schema:about" value="{.}" type="string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
