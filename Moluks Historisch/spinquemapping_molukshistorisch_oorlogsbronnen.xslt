<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:su="com.spinque.tools.importStream.Utils"
    xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
    xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
    xmlns:ese="http://www.europeana.eu/schemas/ese/" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:schema="http://schema.org/"
    extension-element-prefixes="spinque">

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:template match="record">
        <xsl:variable name="subject"
            select="concat('http://93.191.128.243/MHM/Details/collect/', priref)"/>

        <!-- *** run generic Dublin Core *** -->
        <xsl:if
            test="((production.date.end &gt; 1939) and (production.date.start &lt; 1950)) or (contains(su:lowercase(description), 'rms'))">
            <!--conatins(object_name, 'WOII') -->
            <xsl:call-template name="dc_record">
                <xsl:with-param name="subject" select="$subject"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- *** generic Dublin Core parser *** -->
    <xsl:template name="dc_record">
        <xsl:param name="subject"/>
        <spinque:attribute subject="{$subject}"
            attribute="niod:Organizations/recordCount" value="1" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="schema:thumbnail"
            value="{concat('http://93.191.128.243/webapi/wwwopac.ashx?command=getcontent&amp;server=images&amp;value=', reproduction.reference)}"
            type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:language"
            value="nl" type="string"/>
        <xsl:if test="collection != ''">
            <spinque:attribute subject="{$subject}" attribute="http://purl.org/dc/dcmitype/Collection"
                value="{collection}" type="string"/>
        </xsl:if>
        <spinque:attribute
            subject="{$subject}"
            attribute="schema:disambiguatingDescription"
            value="In Oorlogsbronnen in set collectie_mhmuseum"
            type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:source"
            value="http://93.191.128.243/MHM/Details/collect/{priref}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:identifier"
            value="{object_number}" type="string"/>
        <xsl:choose>
            <xsl:when test="contains(object_category, 'foto')">
                <spinque:relation subject="{$subject}" predicate="rdf:type"
                    object="schema:Photograph"/>
                <spinque:attribute subject="{$subject}" attribute="dc:type"
                    value="foto" type="string"/>
            </xsl:when>
            <xsl:otherwise>
    			<!--spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:CreativeWork"/-->
    			<spinque:relation subject="{$subject}" predicate="rdf:type" object="schema:Photograph"/>
    			<spinque:attribute subject="{$subject}" attribute="dc:type" value="voorwerp"  type="string"/>
            </xsl:otherwise>
        </xsl:choose>

        <!-- *** Link Publisher *** -->
        <spinque:relation subject="{$subject}" predicate="dc:publisher"
            object="niod:Organizations/60"/>
        <spinque:attribute subject="{$subject}" attribute="dc:publisher"
            value="Moluks Historisch Museum" type="string"/>
        <!-- end -->

        <spinque:relation
            subject="{$subject}"
            predicate="dc:rights"
            object="https://creativecommons.org/licenses/by-sa/4.0/"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:rights"
            value="CC BY-SA"
            type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:title"
            value="{title}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="dc:description"
            value="{description}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="schema:startDate"
            type="date" value="{su:parseDate(production.date.start, 'nl-nl', 'yyyy', 'yyyy-MM-dd')}"/>
        <spinque:attribute subject="{$subject}" attribute="schema:endDate"
            type="date" value="{su:parseDate(production.date.end, 'nl-nl', 'yyyy', 'yyyy-MM-dd')}"/>

        <xsl:apply-templates select="maker">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="production.date.end | production.date.start">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="object_name">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="association.subject">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>


    </xsl:template>
    <!-- *** -->

    <!-- ******* -->
    <xsl:template match="maker">
        <xsl:param name="subject"/>
        <spinque:attribute subject="{$subject}" attribute="dc:creator"
            value="{.}" type="string"/>
        <spinque:attribute subject="{$subject}" attribute="schema:creator"
            value="{.}" type="string"/>
    </xsl:template>

    <xsl:template match="object_name">
        <xsl:param name="subject"/>
        <spinque:attribute subject="{$subject}" attribute="schema:keywords"
            value="{.}" type="string"/>
    </xsl:template>

    <xsl:template match="association.subject">
        <xsl:param name="subject"/>
        <xsl:variable name="spatial" select="su:normalizeWhiteSpace(concat('http://data.oorlogsbronnen.nl/collectie_mhmuseum/spatial/', .))"/>
        <spinque:relation subject="{$subject}" object="{$spatial}"
            predicate="schema:contentLocation"/>
        <spinque:relation subject="{$spatial}" object="schema:Place"
            predicate="rdf:type"/>
        <spinque:attribute subject="{$spatial}" attribute="schema:name" value="{.}"
            type="string"/>
        <spinque:attribute type="string" value="{.}" attribute="schema:contentLocation"
            subject="{$subject}"/>
    </xsl:template>

    <xsl:template match="production.date | production.date">
        <xsl:param name="subject"/>
        <spinque:attribute subject="{$subject}" attribute="dc:date"
            type="date" value="{su:parseDate(., 'nl-nl', 'yyyy', 'yyyy-MM-dd')}"/>
        <spinque:attribute subject="{$subject}" attribute="schema:startDate"
            type="date" value="{su:parseDate(production.date.start, 'nl-nl', 'yyyy', 'yyyy-MM-dd')}"/>
        <spinque:attribute subject="{$subject}" attribute="schema:endDate"
            type="date" value="{su:parseDate(production.date.end, 'nl-nl', 'yyyy', 'yyyy-MM-dd')}"/>
    </xsl:template>

</xsl:stylesheet>
