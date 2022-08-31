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
	<!--

    <field name="Nummer">239.0</field>
    <field name="Naam">Hubertus Marinus Henri Baan</field>
    <field name="Achternaam">Baan</field>
    <field name="Voornaam">Hubertus Marinus Henri </field>
    <field name="Geboortedatum">1909-12-15</field>
    <field name="Nationaliteit">Netherlands</field>
    <field name="Rang">(陸軍　自動車兵)</field>
    <field name="Stamboeknummer">239909.0</field>
    <field name="Place_of_capture_clean">Bandung</field>
    <field name="Place_of_capture">BandungJava; Bandung Java</field>
    <field name="date_of_capture">1942/03/08</field>
    <field name="Occupation"/>
    <field name="Place_origin"/>
    <field name="destination"/>
    <field name="Remarks"/>
    <field name="Camp1">Java 17/08/15[03/08] ;Java POW Camp 1942/08/15[03/08]</field>
    <field name="Camp2">泰; Thai POW Camp</field>
    <field name="Camp_Japans1">爪II(ジャワ俘虜収容所第2分所) 70; No.2 Branch Camp of Java POW Camp 70</field>
    <field name="Camp_Japans2">(タイ俘虜収容所）5381; Thai POW Camp 5381</field>
    <field name="Camp_Japans3">(タイ俘虜収容所）19854; Thai POW Camp 19854</field>
    <field name="Other_info1">Transferred to Thailand on</field>
    <field name="Other_info2">Died;\n10 September 1943;\nRecorded in the monthly report in September;</field>
    <field name="Other_info3">ク甲二一</field>
    <field name="Scan">http://proxy.handle.net/10648/3ebfa371-4623-446e-83c3-b8180d19d474</field>
    <field name="Reference">NL-HaNA/2.10.50.03/418////</field>
    <field name="prs_uuid">e6b216b4-148f-102f-a8e2-0050569c51dd</field>
	-->
	<xsl:variable name="base">https://www.oorlogslevens.nl/</xsl:variable>
	<xsl:template match="row">
		<!--  Create an id for the record and person based on the name -->
		<xsl:variable name="id" select="./@line"/>
		    <xsl:variable name="name">
            	<xsl:choose>
            		<xsl:when test="contains(field[@name='Naam'],'(m)')">
            			<xsl:value-of select="concat(substring-before(su:replaceAll(field[@name='Naam'],'-',''), '(m)'), substring-after(field[@name='Naam'], '(m)'))"/>
            		</xsl:when>
            		<xsl:when test="contains(field[@name='Naam'],'(')">
            			<xsl:value-of select="substring-before(field[@name='Naam'], ' (')"/>
            		</xsl:when>
            		<xsl:otherwise>
            			<xsl:value-of select="field[@name='Naam']"/>
            		</xsl:otherwise>
            	</xsl:choose>
            </xsl:variable>
            <xsl:variable name="organizationId">15</xsl:variable>
    		<xsl:variable name="record" select="su:uri($base, 'record', su:replaceAll($name, ' ', '-'), $organizationId, $id)"/>
    		<xsl:variable name="person" select="su:uri($base, 'person', su:replaceAll($name, ' ', '-'), $organizationId, $id)"/>

		<!-- Constructing url -->
		<xsl:variable name="url" select="field[@name='Scan']" />

      <xsl:call-template name="person">
        <xsl:with-param name="person" select="$person"/>
        <xsl:with-param name="record" select="$record"/>
        <xsl:with-param name="id" select="$id"/>
      </xsl:call-template>

      <!-- Relate the person to the record -->
      	<spinque:relation subject="{$person}" predicate="prov:wasDerivedFrom" object="{$record}"/>
      	<spinque:attribute subject="{$record}" attribute="schema:url" value="{$url}" type="string"/>
    	<spinque:relation subject="{$record}" predicate="rdf:type" object="prov:Entity"/>
    	<spinque:relation subject="{$record}" predicate="dc:publisher" object="http://www.oorlogsbronnen.nl/organisatie/interneringskaarten_knil"/>
  </xsl:template>

  <!-- Person -->
  <xsl:template name="person">
    	<xsl:param name="person"/>
        <xsl:param name="record"/>
    	<xsl:param name="id"/>

        <!-- ********************
        Hoi Lizzy,

        Het ging juist hardstikke goed. Alleen was je bij 1 van de deathDate attributen de "su:parseDate"-functie vergeten. Ik heb deze toegevoegd.

        Mooie expressie trouwens, maar wellicht kun je 'm nog iets meer uitschrijven, zodat ie ook voor leken iets makkelijker te begrijpen is. Ik zou bijvoorbeeld het volgende voorstellen (heb het niet getest):
        -->
        <!-- Split the events -->
        <!--<xsl:for-each select="su:split(field[@column=28], ';')">
            <xsl:choose>-->
            <!-- if the event mentions 'died', let's parse it -->
            <!--<xsl:when test="contains(su:lowercase(.), 'died ') and contains(.,' on ')">
              <xsl:variable name="deathDateStr" select="su:normalizeWhiteSpace(su:substringAfter(., ' on '))"/>
              <spinque:attribute subject="{$person}" attribute="schema:deathDate" value="{su:parseDate($deathDateStr, 'en-US', 'd MMMM yyyy')}" type="date"/>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
        **************************** -->

			<xsl:variable name="birthDate">
				<xsl:choose>
					<xsl:when test="contains(field[@name='Geboortedatum'], '180')">
						<xsl:value-of select="su:parseDate(su:replace(field[@name='Geboortedatum'], '180', '190'), 'yyyy-MM-dd', 'yyyy-M-d', 'yyyy-MM-d', 'yyyy-M-dd')"/>
					</xsl:when>
					<xsl:when test="contains(field[@name='Geboortedatum'], '181')">
						<xsl:value-of select="su:parseDate(su:replace(field[@name='Geboortedatum'], '181', '191'), 'yyyy-MM-dd', 'yyyy-M-d', 'yyyy-MM-d', 'yyyy-M-dd')"/>
					</xsl:when>
					<xsl:otherwise>
					<xsl:value-of select="su:parseDate(field[@name='Geboortedatum'], 'yyyy-MM-dd', 'yyyy-M-d', 'yyyy-MM-d', 'yyyy-M-dd')"/>
					</xsl:otherwise>
				</xsl:choose>
            </xsl:variable>

            <xsl:variable name="deathDate">
            	<xsl:choose>
            		<xsl:when test="field[@name='Other_info1'] !=''">
            			<xsl:value-of select="su:substringBefore(su:substringBefore(su:substringAfterLast(su:substringAfter(su:normalizeWhiteSpace(su:lowercase(field[@name='Other_info1'])), 'died'), ' on '), '.'), ';')"/>
            		</xsl:when>
            		<xsl:when test="field[@name='Other_info2'] !=''">
            			<xsl:value-of select="su:substringBefore(su:substringBefore(su:substringAfterLast(su:substringAfter(su:normalizeWhiteSpace(su:lowercase(field[@name='Other_info2'])), 'died'), ' on '), '.'), ';')"/>
            		</xsl:when>
            	</xsl:choose>
            </xsl:variable>

            <xsl:variable name="deathPlace">
            	<xsl:choose>
            		<xsl:when test="field[@name='Camp3'] !=''">
            			<xsl:value-of select="field[@name='Camp3']"/>
            		</xsl:when>
            		<xsl:when test="field[@name='Camp2'] !=''">
            			<xsl:value-of select="field[@name='Camp2']"/>
            		</xsl:when>
            	</xsl:choose>
            </xsl:variable>

            <!--To do: transfers: Transferred to Fukuoka POW camp on 22 April 1943;-->

            <xsl:variable name="birthPlace">
                    <xsl:if test="field[@name='Place_origin'] != '(n/a)'">
                        <value-of select="field[@name='Place_origin']"/>
                    </xsl:if>
            </xsl:variable>

            <xsl:variable name="arrestPlace" select="field[@name='Place_of_capture_clean']"/>

            <xsl:variable name="name">
            	<xsl:choose>
            		<xsl:when test="contains(field[@name='Naam'],'(m)')">
            			<xsl:value-of select="concat(substring-before(su:replaceAll(field[@name='Naam'],'-',''), '(m)'), substring-after(field[@name='Naam'], '(m)'))"/>
            		</xsl:when>
            		<xsl:when test="contains(field[@name='Naam'],'(')">
            			<xsl:value-of select="substring-before(field[@name='Naam'], ' (')"/>
            		</xsl:when>
            		<xsl:otherwise>
            			<xsl:value-of select="field[@name='Naam']"/>
            		</xsl:otherwise>
            	</xsl:choose>
            </xsl:variable>

			<spinque:relation subject="{$person}" predicate="rdf:type" object="schema:Person"/>
			<spinque:relation subject="{$person}" predicate="dc:publisher" object="http://www.oorlogsbronnen.nl/organisatie/interneringskaarten_knil"/>
			<spinque:attribute subject="{$person}" attribute="niod:oorlogslevensIdentifier" value="{su:substringAfter($person, 'person/')}" type="string"/>

            <spinque:relation subject="{$person}" predicate="dc:subject" object="niod:WO2_Thesaurus/corporaties/4562"/> <!-- Soort betrokkene = KNIL -->
            <spinque:relation subject="{$person}" predicate="dc:subject" object="niod:WO2_Thesaurus/1877"/> <!-- Soort betrokkene = Marine -->
                <!-- trefwoorden betrokkenheid -->
        	<!--spinque:attribute subject="{$person}" attribute="schema:memberOf" value="Militair in Nederlands-Inië" type="string"/-->
        	<spinque:relation subject="{$person}" predicate="schema:memberOf" object="niod:WO2_Thesaurus/11195"/>

			<!-- schema.org Person properties -->
            <spinque:attribute subject="{$person}" attribute="schema:name" value="{$name}" type="string"/>
            <!--spinque:debug message="{$name}"/-->

            <xsl:choose>
                <xsl:when test="contains(field[@name='Voornaam'], ' (')">
                    <spinque:attribute subject="{$person}" attribute="schema:givenName" value="{substring-before(field[@name='Voornaam'], ' (')}" type="string"/>
                </xsl:when>
                <xsl:otherwise>
                    <spinque:attribute subject="{$person}" attribute="schema:givenName" value="{field[@name='Voornaam']}" type="string"/>
                </xsl:otherwise>
            </xsl:choose>

			<spinque:attribute subject="{$person}" attribute="schema:familyName" value="{su:normalizeWhiteSpace(concat(field[@name='Tussenvoegsel'], ' ', field[@name='Achternaam']))}" type="string"/>

			<spinque:attribute subject="{$person}" attribute="schema:gender" value="male" type="string"/>


            <spinque:attribute subject="{$person}" attribute="niod:familyNamePrefix" value="{field[@name='Tussenvoegsel']}" type="string"/>

            <spinque:attribute subject="{$person}" attribute="niod:initials" value="{concat(substring(field[@name='Naam'], 1,1), '.')}" type="string"/>

			<spinque:attribute subject="{$person}" attribute="schema:birthDate" value="{$birthDate}" type="date"/>
			<spinque:attribute subject="{$person}" attribute="schema:deathDate" value="{su:parseDate($deathDate, 'en-US', 'd MMMM yyyy', 'dd MMMM yyyy')}" type="date"/>
			<spinque:attribute subject="{$person}" attribute="schema:birthPlace" value="{$birthPlace}" type="string"/>
			<spinque:attribute subject="{$person}" attribute="schema:deathPlace" value="{$deathPlace}" type="string"/>

			<!-- schema.org Thing properties -->
			<xsl:if test="field[@name='Scan'] != ''">
			     <spinque:attribute subject="{$person}" attribute="schema:url" value="{field[@name='Scan']}" type="string"/>
      		</xsl:if>

			<!-- We use dublin core for all other properties -->
    <!--xsl:for-each select="field"-->
    <!--xsl:if test="field[@column='28'] != ''">
      <spinque:attribute subject="{$person}" attribute="dc:description" value="{concat(field[@column='28'], 'Bron: Japanse Interneringskaarten [..], Nationaal Archief')}" type="string"/>
    </xsl:if-->
    <!--/xsl:for-each-->


    <xsl:if test="$birthDate != ''">
			<xsl:variable name="birth_event" select="su:uri($person, 'birth')"/>
            <spinque:attribute subject="{$birth_event}" attribute="schema:name" value="Geboren" type="string"/>
            <xsl:variable name="birthPlaceLabel"><xsl:if test="$birthPlace != ''"><xsl:value-of select="concat(' in ', $birthPlace)"/></xsl:if></xsl:variable>
			<spinque:attribute subject="{$birth_event}" attribute="schema:alternateName" value="{concat($name , ' is geboren', $birthPlaceLabel)}" type="string"/>
        	<spinque:attribute subject="{$birth_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' geboren', $birthPlaceLabel,'.')}" type="string"/>
            <spinque:relation subject="{$birth_event}" predicate="rdf:type" object="schema:Event"/>
            <spinque:relation subject="{$birth_event}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/6360"/>
	    	<spinque:relation subject="{$birth_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
			<spinque:relation subject="{$birth_event}" predicate="schema:actor" object="{$person}"/>
			<spinque:attribute subject="{$birth_event}" attribute="schema:location" value="{$birthPlace}" type="string"/>
			<spinque:attribute subject="{$birth_event}" attribute="schema:date" value="{$birthDate}" type="date"/>
        </xsl:if>

    	<xsl:if test="$deathDate != ''">
 			<xsl:variable name="death_event" select="su:uri($person, 'death')"/>
            <spinque:attribute subject="{$death_event}" attribute="schema:name" value="Omgekomen" type="string"/>
            <xsl:variable name="deathPlaceLabel"><xsl:if test="$deathPlace != ''"><xsl:value-of select="concat(' in ', $deathPlace)"/></xsl:if></xsl:variable>
			<spinque:attribute subject="{$death_event}" attribute="schema:alternateName" value="{concat($name , ' is omgekomen', $deathPlaceLabel)}" type="string"/>
            <spinque:attribute subject="{$death_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' omgekomen', $deathPlaceLabel,'.')}" type="string"/>
            <spinque:relation subject="{$death_event}" predicate="rdf:type" object="schema:Event"/>
            <spinque:relation subject="{$death_event}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/8772"/>
            <spinque:relation subject="{$death_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
			<spinque:relation subject="{$death_event}" predicate="schema:actor" object="{$person}"/>
			<spinque:attribute subject="{$death_event}" attribute="schema:location" value="{$deathPlace}" type="string"/>
        	<spinque:attribute subject="{$death_event}" attribute="schema:date" value="{su:parseDate($deathDate, 'en-US', 'd MMMM yyyy', 'dd MMMM yyyy')}" type="date"/>
    	</xsl:if>

    	<xsl:variable name="arrest_event" select="su:uri($person, 'arrest')"/>

        <spinque:attribute subject="{$arrest_event}" attribute="schema:name" value="Gearresteerd" type="string"/>
        <xsl:variable name="arrestPlaceLabel"><xsl:if test="$arrestPlace != ''"><xsl:value-of select="concat(' in ', $arrestPlace, ' ')"/></xsl:if></xsl:variable>
        <spinque:attribute subject="{$arrest_event}" attribute="schema:alternateName" value="{concat($name , ' is ', $arrestPlaceLabel, 'gevangen genomen')}" type="string"/>
        <spinque:attribute subject="{$arrest_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' krijgesgevangen gemaakt', $arrestPlaceLabel, '.')}" type="string"/>
        <spinque:relation subject="{$arrest_event}" predicate="schema:actor" object="{$person}"/>
        <spinque:relation subject="{$arrest_event}" predicate="rdf:type" object="schema:Event"/> <!-- Meso Gebeurtenis -->
        <spinque:relation subject="{$arrest_event}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/6344"/> <!-- Gearresteerd Gebeurtenis -->
	    <spinque:relation subject="{$arrest_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$arrest_event}" predicate="schema:actor" object="{$person}"/>
        <spinque:attribute subject="{$arrest_event}" attribute="schema:startDate" value="{su:parseDate(field[@name='date_of_capture'],'yyyy-MM-dd')}" type="date"/>
        <spinque:attribute subject="{$arrest_event}" attribute="schema:location" value="{$arrestPlace}" type="string"/>

        <xsl:variable name="imprisonment" select="su:uri($person, 'imprisonment')"/>
        <spinque:attribute subject="{$imprisonment}" attribute="schema:name" value="Gevangen" type="string"/>
  		<spinque:attribute subject="{$imprisonment}" attribute="schema:alternateName" value="{concat($name , ' heeft gevangen gezeten in ', su:substringAfter(field[@name='Camp1'], ';'))}" type="string"/>
        <spinque:attribute subject="{$imprisonment}" attribute="schema:description" value="{concat('Vanaf ${startDate} heeft ', $name , ' gevangen gezeten in ', su:substringAfter(field[@name='Camp1'], ';'),'.')}" type="string"/>
        <spinque:relation subject="{$imprisonment}" predicate="rdf:type" object="schema:Event"/>
        <spinque:relation subject="{$imprisonment}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/6354"/>
        <spinque:relation subject="{$imprisonment}" predicate="prov:wasDerivedFrom" object="{$record}"/>
        <spinque:relation subject="{$imprisonment}" predicate="schema:actor" object="{$person}"/>
        <spinque:attribute subject="{$imprisonment}" attribute="schema:startDate" value="{su:parseDate(field[@name='date_of_capture'], 'yyyy/MM/dd', 'dd/MM/yyyy', 'yy/MM/dd')}" type="date"/>

        <xsl:choose>
            <xsl:when test="field[@name='Camp1_clean'] != ''">
                <spinque:attribute subject="{$imprisonment}" attribute="schema:location" value="{field[@name='Camp1_clean']}" type="string"/>
            </xsl:when>
            <xsl:otherwise>
                <spinque:attribute subject="{$imprisonment}" attribute="schema:location" value="{su:substringAfter(field[@name='Camp1'], ';')}" type="string"/>
            </xsl:otherwise>
        </xsl:choose>

	</xsl:template>

</xsl:stylesheet>
