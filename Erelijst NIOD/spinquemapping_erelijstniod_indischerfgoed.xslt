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

  <xsl:template match="row">
    <!-- In deze mapping wordt geen filtering vooraf toegepast, gezien het grote aantal relevante plaatsnamen kan er beter een match met een locatie dataset plaatsvinden in de strategie -->
    <xsl:variable name="givenName">
      <xsl:if test="field[@name='Voornaam'] != 'NULL'">
        <xsl:value-of select="field[@name='Voornaam']"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="familyName">
      <xsl:if test="field[@name='Naam'] != 'NULL'">
        <xsl:value-of select="field[@name='Naam']"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="familyNamePrefix">
      <xsl:if test="field[@name='Vvgsl'] != 'NULL'">
        <xsl:value-of select="field[@name='Vvgsl']"/>
      </xsl:if>
    </xsl:variable>
  	<xsl:variable name="name" select="su:normalizeWhiteSpace(concat($givenName, ' ', $familyNamePrefix, ' ', $familyName))"/>
    <xsl:variable name="id" select="field[@name='id']"/>
    <xsl:variable name="organizationId">niod</xsl:variable>
    <xsl:variable name="url" select="field[@name='Scan']" />
    <!--  Maak een id voor het record en de persoon op basis van de naam -->
    <xsl:variable name="record" select="su:uri($base, $organizationId, 'record', su:replaceAll($name, ' ', '-'), $id)"/>
    <xsl:variable name="person" select="su:uri($base, $organizationId, 'person', su:replaceAll($name, ' ', '-'), $id)"/>
    <spinque:relation subject="{$record}" predicate="rdf:type" object="prov:Entity"/>
    <spinque:attribute subject="{$record}" attribute="sdo:url" value="{$url}" type="string"/>
    <spinque:relation subject="{$record}" predicate="sdo:publisher" object="niod:Organizations/116"/>
    <spinque:relation subject="{$person}" predicate="prov:wasDerivedFrom" object="{$record}"/>

    <xsl:call-template name="person">
      <xsl:with-param name="person" select="$person"/>
      <xsl:with-param name="record" select="$record"/>
      <xsl:with-param name="givenName" select="$givenName"/>
      <xsl:with-param name="familyNamePrefix" select="$familyNamePrefix"/>
      <xsl:with-param name="familyName" select="$familyName"/>
      <xsl:with-param name="name" select="$name"/>
      <xsl:with-param name="id" select="$id"/>
      <xsl:with-param name="url" select="$url"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="person">
    <xsl:param name="person"/>
    <xsl:param name="record"/>
    <xsl:param name="givenName"/>
    <xsl:param name="familyNamePrefix"/>
    <xsl:param name="familyName"/>
    <xsl:param name="name"/>
    <xsl:param name="id"/>
    <xsl:param name="url"/>

    <xsl:variable name="birthDate">
  		<xsl:if test="field[@name='GebDatum'] != 'NULL'">
  			<xsl:value-of select="su:parseDate(field[@name='GebDatum'], 'nl-nl', 'yyyy-MM-dd')"/>
  		</xsl:if>
  	</xsl:variable>
    <xsl:variable name="birthPlace">
      <xsl:if test="(field[@name='Geboorteplaats'] != 'NULL') and (field[@name='Geboorteplaats'] != 'Onbekend')">
        <xsl:choose>
          <xsl:when test="contains(field[@name='Geboorteplaats'], '(')">
            <xsl:value-of select="su:substringBefore(field[@name='Geboorteplaats'], ' (')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="field[@name='Geboorteplaats']"/>
          </xsl:otherwise>
        </xsl:choose>
  		</xsl:if>
  	</xsl:variable>
    <xsl:variable name="arrestDate">
      <xsl:if test="field[@name='ArrestDatum'] != 'NULL'">
        <xsl:value-of select="su:parseDate(field[@name='ArrestDatum'], 'nl-nl', 'yyyy-MM-dd')"/>
      </xsl:if>
    </xsl:variable>
  	<xsl:variable name="arrestPlace">
    	<xsl:if test="(field[@name='ArrestPlaats'] != 'NULL') and (field[@name='ArrestPlaats'] != 'Onbekend')">
  			<xsl:value-of select="field[@name='ArrestPlaats']"/>
  		</xsl:if>
  	</xsl:variable>
    <xsl:variable name="deathDate">
  		<xsl:if test="field[@name='OverlDatum'] != 'NULL'">
  			<xsl:value-of select="su:parseDate(field[@name='OverlDatum'], 'nl-nl', 'yyyy-MM-dd')"/>
  		</xsl:if>
  	</xsl:variable>
  	<xsl:variable name="deathPlace">
    	<xsl:if test="(field[@name='OverlPlaats'] != 'NULL') and (field[@name='OverlPlaats'] != 'Onbekend')">
  			<xsl:value-of select="field[@name='OverlPlaats']"/>
  		</xsl:if>
  	</xsl:variable>
  	<xsl:variable name="homeLocation">
    	<xsl:if test="(field[@name='Woonplaats'] != 'NULL') and not(contains(field[@name='Woonplaats'],'?'))">
        <xsl:choose>
          <xsl:when test="contains(field[@name='Woonplaats'], '(')">
    		    <xsl:value-of select="su:substringBefore(field[@name='Woonplaats'], ' (')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="field[@name='Woonplaats']"/>
          </xsl:otherwise>
        </xsl:choose>
    	</xsl:if>
  	</xsl:variable>

    <spinque:relation subject="{$person}" predicate="rdf:type" object="sdo:Person"/>
  	<spinque:attribute subject="{$person}" attribute="niod:oorlogslevensIdentifier" value="{su:substringAfter($person, 'person/')}" type="string"/>
    <spinque:attribute subject="{$person}" attribute="sdo:name" value="{$name}" type="string"/>
    <spinque:attribute subject="{$person}" attribute="sdo:givenName" value="{$givenName}" type="string"/>
  	<spinque:attribute subject="{$person}" attribute="sdo:familyName" value="{su:normalizeWhiteSpace(concat($familyNamePrefix, ' ', $familyName))}" type="string"/>
    <spinque:attribute subject="{$person}" attribute="niod:familyNamePrefix" value="{$familyNamePrefix}" type="string"/>
  	<xsl:choose>
      <xsl:when test="field[@name='Geslacht'] = 'V'">
        <spinque:relation subject="{$person}" predicate="sdo:gender" object="sdo:Female"/>
      </xsl:when>
      <xsl:when test="field[@name='Geslacht'] = 'M'">
        <spinque:relation subject="{$person}" predicate="sdo:gender" object="sdo:Male"/>
      </xsl:when>
    </xsl:choose>
    <spinque:attribute subject="{$person}" attribute="sdo:birthDate" value="{$birthDate}" type="date"/>
  	<spinque:attribute subject="{$person}" attribute="sdo:deathDate" value="{$deathDate}" type="date"/>
  	<spinque:attribute subject="{$person}" attribute="sdo:birthPlace" value="{$birthPlace}" type="string"/>
  	<spinque:attribute subject="{$person}" attribute="sdo:deathPlace" value="{$deathPlace}" type="string"/>

    <xsl:if test="$homeLocation != ''">
      <spinque:attribute subject="{$person}" attribute="sdo:homeLocation" value="{$homeLocation}" type="string"/>
      <spinque:attribute subject="{$person}" attribute="niod:homeLocationText" value="{concat('en woonde in ', $homeLocation)}" type="string"/>
    </xsl:if>

  	<xsl:if test="$birthDate != '' or $birthPlace  != ''">
    	<xsl:variable name="birth" select="su:uri($person, 'birth')"/>
        <spinque:relation subject="{$birth}" predicate="rdf:type" object="sdo:Event"/>
        <spinque:relation subject="{$birth}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/6360"/>
        <spinque:attribute subject="{$birth}" attribute="rdfs:label" value="Geboorte" type="string"/>
        <spinque:relation subject="{$birth}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$birth}" predicate="sdo:actor" object="{$person}"/>
        <spinque:attribute subject="{$birth}" attribute="sdo:location" value="{$birthPlace}" type="string"/>
        <spinque:attribute subject="{$birth}" attribute="sdo:date" value="{$birthDate}" type="date"/>
        <xsl:variable name="birthPlaceLabel">
            <xsl:if test="$birthPlace != ''">
                <xsl:value-of select="concat(' in ', $birthPlace)"/>
            </xsl:if>
        </xsl:variable>
        <spinque:attribute subject="{$birth}" attribute="sdo:alternateName" value="{concat($name, ' is geboren', $birthPlaceLabel, '.')}" type="string"/>
              <xsl:choose>
        <xsl:when test="$birthDate != ''">
          <spinque:attribute subject="{$birth}" attribute="sdo:description" value="{concat('Op ${date} is ', $name , ' geboren', $birthPlaceLabel, '.')}" type="string"/>
        </xsl:when>
        <xsl:otherwise>
          <spinque:attribute subject="{$birth}" attribute="sdo:description" value="{concat($name , ' is geboren', $birthPlaceLabel, '.')}" type="string"/>
        </xsl:otherwise>
      </xsl:choose>
         </xsl:if>

    <xsl:if test="$arrestDate != '' or $arrestPlace != ''">
    	<xsl:variable name="arrest" select="su:uri($person, 'arrest')"/>
      <spinque:relation subject="{$arrest}" predicate="rdf:type" object="sdo:Event"/>
      <spinque:relation subject="{$arrest}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/6344"/>
      <spinque:attribute subject="{$arrest}" attribute="rdfs:label" value="Arrestatie" type="string"/>
      <spinque:relation subject="{$arrest}" predicate="prov:wasDerivedFrom" object="{$record}"/>
      <spinque:relation subject="{$arrest}" predicate="sdo:actor" object="{$person}"/>
      <spinque:attribute subject="{$arrest}" attribute="sdo:location" value="{$arrestPlace}" type="string"/>
      <spinque:attribute subject="{$arrest}" attribute="sdo:date" value="{$arrestDate}" type="date"/>
      <xsl:variable name="arrestPlaceLabel">
        <xsl:if test="$arrestPlace != ''">
          <xsl:value-of select="concat(' in ', $arrestPlace)"/>
        </xsl:if>
      </xsl:variable>
      <spinque:attribute subject="{$arrest}" attribute="sdo:alternateName" value="{concat($name , ' is gearresteerd', $arrestPlaceLabel, '.')}" type="string"/>
      <xsl:choose>
        <xsl:when test="$arrestDate != ''">
          <spinque:attribute subject="{$arrest}" attribute="sdo:description" value="{concat('Op ${date} is ', $name , ' gearresteerd', $arrestPlaceLabel, '.')}" type="string"/>
        </xsl:when>
        <xsl:otherwise>
          <spinque:attribute subject="{$arrest}" attribute="sdo:description" value="{concat($name , ' is gearresteerd', $arrestPlaceLabel, '.')}" type="string"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>

		<xsl:if test="$deathDate != ''">
			<xsl:variable name="death" select="su:uri($person, 'death')"/>
        <spinque:relation subject="{$death}" predicate="rdf:type" object="sdo:Event"/>
        <spinque:relation subject="{$death}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/8772"/>
        <spinque:attribute subject="{$death}" attribute="rdfs:label" value="Overlijden" type="string"/>
        <spinque:relation subject="{$death}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$death}" predicate="sdo:actor" object="{$person}"/>
        <spinque:attribute subject="{$death}" attribute="sdo:location" value="{$deathPlace}" type="string"/>
        <spinque:attribute subject="{$death}" attribute="sdo:date" value="{$deathDate}" type="date"/>
        <xsl:variable name="deathPlaceLabel">
            <xsl:if test="$deathPlace != ''">
                <xsl:value-of select="concat(' in ', $deathPlace)"/>
            </xsl:if>
        </xsl:variable>
        <spinque:attribute subject="{$death}" attribute="sdo:alternateName" value="{concat($name, ' is omgekomen', $deathPlaceLabel,'.')}" type="string"/>
        <spinque:attribute subject="{$death}" attribute="sdo:description" value="{concat('Op ${date} is ', $name , ' omgekomen', $deathPlaceLabel, '.')}" type="string"/>
    	</xsl:if>

	</xsl:template>

</xsl:stylesheet>
