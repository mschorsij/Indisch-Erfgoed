<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:su="com.spinque.tools.importStream.Utils"
    xmlns:ad="com.spinque.tools.extraction.socialmedia.AccountDetector"
    xmlns:spinque="com.spinque.tools.importStream.EmitterWrapper"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:schema="http://schema.org/"
    extension-element-prefixes="spinque">

	<xsl:output method="text" encoding="UTF-8"/>

	<xsl:variable name="base">https://www.oorlogslevens.nl/</xsl:variable>

	<!--
  <row line="63">
    <field name="SorteerNaam">Palte, W.A.</field>
    <field name="Naam">Palte</field>
    <field name="Voornaam">W.A.</field>
    <field name="Titulatuur">NULL</field>
    <field name="Bijnaam">NULL</field>
    <field name="Geslacht">M</field>
    <field name="GebPlaats">Onbekend</field>
    <field name="GebDatum">NULL</field>
    <field name="GebDatumZekerheid">?</field>
    <field name="OverlPlaats">Atlantische Oceaan</field>
    <field name="OverlDatum">1939-11-16</field>
    <field name="Begraafpl">Zeemansgraf (N 54° 15' - W 14° 00')</field>
    <field name="Onderdl-Org">MS "Sliedrecht"</field>
    <field name="Rang">Stoker Olieman</field>
    <field name="Religie">?</field>
    <field name="ReligieZekerheid">NULL</field>
    <field name="Doodsoorz">Torpedering van het schip</field>
    <field name="ArrestDatum">NULL</field>
    <field name="Gehuwd">?</field>
    <field name="Kinderen">NULL</field>
    <field name="Leeftijd">NULL</field>
    <field name="id">7801</field>
    <field name="Geboorteplaats">Onbekend</field>
  </row>
  <row line="64">
    <field name="SorteerNaam">Quispel, Jochem</field>
    <field name="Naam">Quispel</field>
    <field name="Voornaam">Jochem</field>
    <field name="Titulatuur">NULL</field>
    <field name="Bijnaam">NULL</field>
    <field name="Geslacht">M</field>
    <field name="GebPlaats">Onbekend</field>
    <field name="GebDatum">NULL</field>
    <field name="GebDatumZekerheid">?</field>
    <field name="OverlPlaats">Atlantische Oceaan</field>
    <field name="OverlDatum">1939-11-16</field>
    <field name="Begraafpl">Zeemansgraf (N 54° 15' - W 14° 00')</field>
    <field name="Onderdl-Org">MS "Sliedrecht"</field>
    <field name="Rang">4e Machinist</field>
    <field name="Religie">?</field>
    <field name="ReligieZekerheid">NULL</field>
    <field name="Doodsoorz">Torpedering van het schip</field>
    <field name="ArrestDatum">NULL</field>
    <field name="Gehuwd">?</field>
    <field name="Kinderen">NULL</field>
    <field name="Leeftijd">NULL</field>
    <field name="id">8247</field>
    <field name="Geboorteplaats">Onbekend</field>
  </row>
</table>
	-->

  <xsl:template match="row">
    <!-- Create and id for the event based on the line number -->
	<xsl:variable name="name" select="su:replace(su:normalizeWhiteSpace(concat(field[@name='Voornaam'], ' ', field[@name='Vvgsl'], ' ', field[@name='Naam'])),'NULL','')"/>
	<!--spinque:debug message="{$name}"/-->
	<xsl:variable name="organizationId">86</xsl:variable>
	<xsl:variable name="id" select="field[@name='id']"/>
    <xsl:variable name="record" select="su:uri('https://www.oorlogslevens.nl/record', $name , $organizationId, $id)"/>
    <xsl:variable name="person" select="su:uri('https://www.oorlogslevens.nl/person', $name , $organizationId, $id)"/>

    <!--  The person -->
    <xsl:call-template name="person">
     	<xsl:with-param name="person" select="$person"/>
      	<xsl:with-param name="record" select="$record"/>
      	<xsl:with-param name="name" select="$name"/>
    </xsl:call-template>

    <spinque:relation subject="{$record}" predicate="rdf:type" object="prov:Entity"/>
   	<spinque:relation subject="{$record}" predicate="dc:publisher" object="http://www.oorlogsbronnen.nl/organisatie/erelijst_niod" />
	<!--spinque:attribute subject="{$record}" attribute="schema:url" value="https://www.niod.nl/" type="string"/-->

  </xsl:template>


	<xsl:template name="person">
		<xsl:param name="person"/>
        <xsl:param name="record"/>
        <xsl:param name="name"/>

     	<spinque:relation subject="{$person}" predicate="dc:publisher" object="http://www.oorlogsbronnen.nl/organisatie/erelijst_niod" />
		<spinque:relation subject="{$person}" predicate="rdf:type" object="schema:Person"/>
		<spinque:attribute subject="{$person}" attribute="niod:oorlogslevensIdentifier" value="{su:substringAfter($person, 'person/')}" type="string"/>
        <spinque:relation subject="{$person}" predicate="prov:wasDerivedFrom" object="{$record}"/>


		<xsl:variable name="birthDate">
			<xsl:if test="field[@name='GebDatum'] != 'NULL'">
				<xsl:value-of select="su:parseDate(field[@name='GebDatum'], 'nl-nl', 'yyyy-MM-dd')"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="arrestDate">
			<xsl:if test="field[@name='ArrestDatum'] != 'NULL'">
				<xsl:value-of select="su:parseDate(field[@name='ArrestDatum'], 'nl-nl', 'yyyy-MM-dd')"/>
			</xsl:if>
		</xsl:variable>
      	<xsl:variable name="birthPlace">
      		<xsl:if test="(field[@name='Geboorteplaats'] != 'NULL') and (field[@name='Geboorteplaats'] != 'Onbekend')">
				<xsl:value-of select="field[@name='Geboorteplaats']"/>
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
      		<xsl:if test="(field[@name='Woonplaats'] != 'NULL') and not(contains(field[@name='Woonplaats'],'?')  and not(contains(field[@name='Woonplaats'],'(')))">
				<xsl:value-of select="field[@name='Woonplaats']"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="gender">
            <xsl:if test="field[@name='Geslacht']='V'">vrouw</xsl:if>
            <xsl:if test="field[@name='Geslacht']='M'">man</xsl:if>
        </xsl:variable>

		<!-- schema.org Person properties -->
		<spinque:attribute subject="{$person}" attribute="schema:name" value="{$name}" type="string"/>
		<spinque:attribute subject="{$person}" attribute="schema:givenName" value="{field[@name='Voornaam']}" type="string"/>
		<spinque:attribute subject="{$person}" attribute="schema:familyName" value="{su:normalizeWhiteSpace(concat(field[@name='Vvgsl'], ' ', field[@name='Naam']))}" type="string"/>

		<spinque:attribute subject="{$person}" attribute="schema:birthDate" value="{$birthDate}" type="date"/>
		<spinque:attribute subject="{$person}" attribute="schema:deathDate" value="{$deathDate}" type="date"/>
		<spinque:attribute subject="{$person}" attribute="schema:birthPlace" value="{$birthPlace}" type="string"/>
		<spinque:attribute subject="{$person}" attribute="schema:deathPlace" value="{$deathPlace}" type="string"/>
		<spinque:attribute subject="{$person}" attribute="schema:gender" value="{$gender}" type="string"/>
		<!--xsl:if test="$homeLocation != ''">
        	<spinque:attribute subject="{$person}" attribute="schema:homeLocation" value="{$homeLocation}" type="string"/>
        	<spinque:attribute subject="{$person}" attribute="niod:homeLocationText" value="{concat('en woont in ', $homeLocation)}" type="string"/>
        </xsl:if-->
		<!--spinque:debug message="{$homeLocation}"/-->

  		<xsl:if test="$birthDate != ''">
			<xsl:variable name="birth_event" select="su:uri($person, 'birth')"/>
            <spinque:attribute subject="{$birth_event}" attribute="schema:name" value="Geboren" type="string"/>
            <xsl:variable name="birthPlaceLabel"><xsl:if test="$birthPlace != ''"><xsl:value-of select="concat(' in ', su:trim($birthPlace))"/></xsl:if></xsl:variable>
			<spinque:attribute subject="{$birth_event}" attribute="schema:alternateName" value="{concat($name , ' is geboren', $birthPlaceLabel)}" type="string"/>
            <spinque:attribute subject="{$birth_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' geboren', $birthPlaceLabel,'.')}" type="string"/>
            <spinque:relation subject="{$birth_event}" predicate="rdf:type" object="schema:Event"/>
            <spinque:relation subject="{$birth_event}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/6360"/>
	    	<spinque:relation subject="{$birth_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
			<spinque:relation subject="{$birth_event}" predicate="schema:actor" object="{$person}"/>
			<spinque:attribute subject="{$birth_event}" attribute="schema:location" value="{$birthPlace}" type="string"/>
			<spinque:attribute subject="{$birth_event}" attribute="schema:date" value="{$birthDate}" type="date"/>
		</xsl:if>

		<xsl:if test="$arrestDate != ''">
			<xsl:variable name="arrest_event" select="su:uri($person, 'arrest')"/>
            <spinque:attribute subject="{$arrest_event}" attribute="schema:name" value="Gearresteerd" type="string"/>
            <xsl:variable name="arrestPlaceLabel"><xsl:if test="$arrestPlace != ''"><xsl:value-of select="concat(' in ', su:trim($arrestPlace))"/></xsl:if></xsl:variable>
			<spinque:attribute subject="{$arrest_event}" attribute="schema:alternateName" value="{concat($name , ' is gearresteerd', $arrestPlaceLabel)}" type="string"/>
            <spinque:attribute subject="{$arrest_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' gearresteerd', $arrestPlaceLabel,'.')}" type="string"/>
            <spinque:relation subject="{$arrest_event}" predicate="rdf:type" object="schema:Event"/>
            <spinque:relation subject="{$arrest_event}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/6344"/>
	    	<spinque:relation subject="{$arrest_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
			<spinque:relation subject="{$arrest_event}" predicate="schema:actor" object="{$person}"/>
			<spinque:attribute subject="{$arrest_event}" attribute="schema:location" value="{$arrestPlace}" type="string"/>
			<spinque:attribute subject="{$arrest_event}" attribute="schema:date" value="{$arrestDate}" type="date"/>
		</xsl:if>

		<xsl:if test="$deathDate != ''">
			<xsl:variable name="death_event" select="su:uri($person, 'death')"/>
            <spinque:attribute subject="{$death_event}" attribute="schema:name" value="Omgekomen" type="string"/>
            <xsl:variable name="deathPlaceLabel"><xsl:if test="$deathPlace != ''"><xsl:value-of select="concat(' in ', su:trim($deathPlace))"/></xsl:if></xsl:variable>
			<spinque:attribute subject="{$death_event}" attribute="schema:alternateName" value="{concat($name , ' is omgekomen', $deathPlaceLabel)}" type="string"/>
        	<spinque:attribute subject="{$death_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' omgekomen', $deathPlaceLabel,'. ')}" type="string"/>
            <spinque:relation subject="{$death_event}" predicate="rdf:type" object="schema:Event"/>
            <spinque:relation subject="{$death_event}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/8772"/>
			<spinque:relation subject="{$death_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
			<spinque:relation subject="{$death_event}" predicate="schema:actor" object="{$person}"/>
			<spinque:attribute subject="{$death_event}" attribute="schema:location" value="{$deathPlace}" type="string"/>
			<spinque:attribute subject="{$death_event}" attribute="schema:date" value="{$deathDate}" type="date"/>
		</xsl:if>


	</xsl:template>

</xsl:stylesheet>
