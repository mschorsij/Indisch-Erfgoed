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
      <!-- In deze mapping wordt geen filtering vooraf toegepast, we gaan er van uit dat alle records relevant zijn voor Indisch Erfgoed -->
      <xsl:variable name="name">
          <!--  Correctie van onregelmatigheden in het Naam veld-->
        	<xsl:choose>
            <!-- Soms staat er (m) direct achter de voornaam (7x) -->
          		<xsl:when test="contains(field[@name='Naam'],'(m)')">
            			<xsl:value-of select="concat(substring-before(su:replaceAll(field[@name='Naam'],'-',''), '(m)'), substring-after(field[@name='Naam'], '(m)'))"/>
          		</xsl:when>
              <!-- Soms staat er een afbreekstreepje in de naam (535x) -->
              <xsl:when test="su:matches(field[@name='Naam'],'\w+-\w+')">
            			<xsl:value-of select="su:replaceAll(field[@name='Naam'],'-','')"/>
          		</xsl:when>
          		<xsl:otherwise>
            			<xsl:value-of select="field[@name='Naam']"/>
          		</xsl:otherwise>
        	</xsl:choose>
      </xsl:variable>
      <xsl:variable name="id" select="./@line"/>
      <xsl:variable name="organizationId">nationaalarchief</xsl:variable>
      <xsl:variable name="url" select="field[@name='Scan']" />

      <!--  Maak een id voor het record en de persoon op basis van de naam -->
      <xsl:variable name="record" select="su:uri($base, $organizationId, 'record', su:replaceAll($name, ' ', '-'), $id)"/>
      <xsl:variable name="person" select="su:uri($base, $organizationId, 'person', su:replaceAll($name, ' ', '-'), $id)"/>

    	<spinque:relation subject="{$record}" predicate="rdf:type" object="prov:Entity"/>
      <spinque:attribute subject="{$record}" attribute="sdo:url" value="{$url}" type="string"/>
      <spinque:relation subject="{$record}" predicate="sdo:publisher" object="niod:Organizations/113"/>
      <!-- dataset toevoegen? Hoe heet deze bij NA? Wat voor attribute kunnen we hiervoor gebruiken? -->

      <spinque:relation subject="{$person}" predicate="prov:wasDerivedFrom" object="{$record}"/>

      <xsl:call-template name="person">
          <xsl:with-param name="person" select="$person"/>
          <xsl:with-param name="record" select="$record"/>
          <xsl:with-param name="name" select="$name"/>
          <xsl:with-param name="id" select="$id"/>
          <xsl:with-param name="url" select="$url"/>
      </xsl:call-template>

  </xsl:template>

  <xsl:template name="person">
     <xsl:param name="person"/>
     <xsl:param name="record"/>
     <xsl:param name="name"/>
     <xsl:param name="id"/>
     <xsl:param name="url"/>

     <!--  Variabelen voor Persoon: birthDate, deathDate, deathPlace, arrestPlace -->
  	 <xsl:variable name="birthDate">
  			 <xsl:choose>
             <!--  Correctie voor fouten in geboortejaar (komt 1x voor)-->
    				 <xsl:when test="contains(field[@name='Geboortedatum'], '181')">
      					 <xsl:value-of select="su:parseDate(su:replace(field[@name='Geboortedatum'], '181', '191'), 'yyyy-MM-dd', 'yyyy-M-d', 'yyyy-MM-d', 'yyyy-M-dd')"/>
    				 </xsl:when>
      			 <xsl:otherwise>
        				 <xsl:value-of select="su:parseDate(field[@name='Geboortedatum'], 'yyyy-MM-dd', 'yyyy-M-d', 'yyyy-MM-d', 'yyyy-M-dd')"/>
    				 </xsl:otherwise>
      	 </xsl:choose>
     </xsl:variable>

     <xsl:variable name="deathDate">
        <!-- soms staat died in meerdere occurrences van de other info fields. Ik hark eerst alle died waarden uit alle velden bij elkaar-->
        <xsl:variable name="deathDateRaw">
            <xsl:for-each select="field[contains(@name,'Other_info')]">
                <xsl:if test="contains(su:lowercase(.), 'died') and su:matches(., '.*\d{4}.*')">
                  <!-- nu zorgen dat de datum achter died gevonden wordt, soms staat er toch nog een andere datum in de zin voor died en dan wordt die opgepakt-->
                    <xsl:variable name="zin" select="su:substringAfter(su:lowercase(.),'died')"/>
                    <xsl:variable name="stukZinVoor" select="su:substringBeforeLast(su:substringBeforeLast(su:substringBefore($zin, ' 19'),' '), ' ')"/>
                    <xsl:variable name="stukZinNa" select="substring(su:substringAfter($zin, ' 19'),3)"/>
                    <xsl:choose>
                        <xsl:when test="string-length($stukZinNa)">
                            <xsl:variable name="dateText" select="su:substringAfter(su:substringBefore($zin, $stukZinNa),$stukZinVoor)"/>
                            <xsl:value-of select="su:parseDate($dateText, 'en-US', 'd MMMM yyyy', 'dd MMMM yyyy')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="dateText" select="su:substringAfter($zin, $stukZinVoor)"/>
                            <xsl:value-of select="su:parseDate($dateText, 'en-US', 'd MMMM yyyy', 'dd MMMM yyyy')"/>
                        </xsl:otherwise>
                      </xsl:choose>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <!-- nu alle sterfdata bij elkaar zijn geveegd ga ik kijken of er uberhaupt een sterfdatum is. En als er meerdere zijn dan pak ik alleen de eerste sterfdatum (eerste 10 tekens van de Raw variable -->
        <xsl:if test="string-length($deathDateRaw) &gt;9">
            <!--spinque:debug message="{./@line} - {$deathDateRaw}"/-->
            <xsl:value-of select="substring($deathDateRaw,1,10)"/>
        </xsl:if>
     </xsl:variable>

      <!-- <xsl:if test="$deathDate != ''">
          <spinque:debug message="{concat(./@line, ', ', field[@name='Naam'], ': ', $deathDate)}"/>
      </xsl:if> -->

      <!-- Place of origin is niet de geboorteplaats -->
      <!-- <xsl:variable name="birthPlace">
          <xsl:if test="field[@name='Place_origin'] != '(n/a)'">
              <xsl:value-of select="field[@name='Place_origin']"/>
              </xsl:if>
      </xsl:variable> -->

      <xsl:variable name="deathPlace">
        	<xsl:choose>
          		<xsl:when test="field[@name='Camp3'] != ''">
            			<xsl:value-of select="field[@name='Camp3']"/>
          		</xsl:when>
          		<xsl:when test="field[@name='Camp2'] != ''">
            			<xsl:value-of select="field[@name='Camp2']"/>
          		</xsl:when>
        	</xsl:choose>
      </xsl:variable>

      <xsl:variable name="arrestPlace" select="field[@name='Place_of_capture_clean']"/>

  		<spinque:relation subject="{$person}" predicate="rdf:type" object="sdo:Person"/>
  		<spinque:attribute subject="{$person}" attribute="niod:oorlogslevensIdentifier" value="{su:substringAfter($person, 'person/')}" type="string"/>
      <spinque:attribute subject="{$person}" attribute="sdo:name" value="{$name}" type="string"/>
      <xsl:choose>
          <xsl:when test="contains(field[@name='Voornaam'], ' (')">
              <spinque:attribute subject="{$person}" attribute="sdo:givenName" value="{substring-before(field[@name='Voornaam'], ' (')}" type="string"/>
          </xsl:when>
          <xsl:otherwise>
              <spinque:attribute subject="{$person}" attribute="sdo:givenName" value="{field[@name='Voornaam']}" type="string"/>
          </xsl:otherwise>
      </xsl:choose>
      <spinque:attribute subject="{$person}" attribute="sdo:familyName" value="{su:normalizeWhiteSpace(concat(field[@name='Tussenvoegsel'], ' ', field[@name='Achternaam']))}" type="string"/>
      <spinque:attribute subject="{$person}" attribute="niod:familyNamePrefix" value="{field[@name='Tussenvoegsel']}" type="string"/>
      <spinque:attribute subject="{$person}" attribute="niod:initials" value="{concat(substring(field[@name='Naam'], 1,1), '.')}" type="string"/>
      <spinque:relation subject="{$person}" predicate="sdo:gender" object="sdo:Male"/>

      <spinque:attribute subject="{$person}" attribute="sdo:birthDate" value="{$birthDate}" type="date"/>
      <spinque:attribute subject="{$person}" attribute="sdo:deathDate" value="{$deathDate}" type="string"/>
      <!-- <spinque:attribute subject="{$person}" attribute="sdo:birthPlace" value="{$birthPlace}" type="string"/> -->
      <spinque:attribute subject="{$person}" attribute="sdo:deathPlace" value="{$deathPlace}" type="string"/>

      <!-- Harde mapping van alle personen in deze dataset met WO2 thesaurus. Liggen deze relaties echt vast? Wat kan hier weg, wat moet er bij? Moeten we niet matchen met Indische thesaurus? -->
      <spinque:relation subject="{$person}" predicate="sdo:memberOf" object="niod:WO2_Thesaurus/corporaties/4562"/> <!-- Soort betrokkene = KNIL -->
      <spinque:relation subject="{$person}" predicate="sdo:memberOf" object="niod:WO2_Thesaurus/1877"/> <!-- Soort betrokkene = Marine -->
      <spinque:relation subject="{$person}" predicate="sdo:memberOf" object="niod:WO2_Thesaurus/11195"/> <!-- Soort betrokkene = Militair in Nederlands Indië -->

      <!-- Life events -->
      <xsl:if test="$birthDate != ''">
      		<xsl:variable name="birth" select="su:uri($person, 'birth')"/>
          <spinque:relation subject="{$birth}" predicate="rdf:type" object="sdo:Event"/>
          <spinque:relation subject="{$birth}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/6360"/>
          <spinque:attribute subject="{$birth}" attribute="rdfs:label" value="Geboorte" type="string"/>
          <spinque:relation subject="{$birth}" predicate="prov:wasDerivedFrom" object="{$record}"/>
          <spinque:relation subject="{$birth}" predicate="sdo:actor" object="{$person}"/>
          <!-- <spinque:attribute subject="{$birth}" attribute="sdo:location" value="{$birthPlace}" type="string"/> -->
          <spinque:attribute subject="{$birth}" attribute="sdo:date" value="{$birthDate}" type="date"/>
          <!-- <xsl:variable name="birthPlaceLabel">
              <xsl:if test="$birthPlace != ''">
                  <xsl:value-of select="concat(' in ', $birthPlace)"/>
              </xsl:if>
          </xsl:variable> -->
          <spinque:attribute subject="{$birth}" attribute="sdo:alternateName" value="{concat($name, ' is geboren.')}" type="string"/>
          <spinque:attribute subject="{$birth}" attribute="sdo:description" value="{concat($name, ' is geboren op ${date}', '.')}" type="string"/>
      </xsl:if>

    	<xsl:if test="$deathDate != ''">
     			<xsl:variable name="death" select="su:uri($person, 'death')"/>
          <spinque:relation subject="{$death}" predicate="rdf:type" object="sdo:Event"/>
          <spinque:relation subject="{$death}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/8772"/>
          <spinque:attribute subject="{$death}" attribute="rdfs:label" value="Dood" type="string"/>
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
          <spinque:attribute subject="{$death}" attribute="sdo:description" value="{concat($name, ' is omgekomen op ${date} ', $deathPlaceLabel,'.')}" type="string"/>
    	</xsl:if>

    	<xsl:variable name="arrest" select="su:uri($person, 'arrest', field[@name='date_of_capture'])"/>
      <spinque:relation subject="{$arrest}" predicate="rdf:type" object="sdo:Event"/>
      <spinque:relation subject="{$arrest}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/6344"/>
      <spinque:attribute subject="{$arrest}" attribute="rdfs:label" value="Arrestatie" type="string"/>
      <spinque:relation subject="{$arrest}" predicate="prov:wasDerivedFrom" object="{$record}"/>
      <spinque:relation subject="{$arrest}" predicate="sdo:actor" object="{$person}"/>
      <spinque:attribute subject="{$arrest}" attribute="sdo:location" value="{$arrestPlace}" type="string"/>
      <spinque:attribute subject="{$arrest}" attribute="sdo:date" value="{su:parseDate(field[@name='date_of_capture'],'yyyy-MM-dd')}" type="date"/>
      <xsl:variable name="arrestPlaceLabel">
          <xsl:if test="$arrestPlace != ''">
              <xsl:value-of select="concat(' in ', $arrestPlace, ' ')"/>
          </xsl:if>
      </xsl:variable>
      <spinque:attribute subject="{$arrest}" attribute="sdo:alternateName" value="{concat($name , ' is krijgsgevangen gemaakt', $arrestPlaceLabel, '.')}" type="string"/>
      <xsl:choose>
          <xsl:when test="field[@name='date_of_capture'] != ''">
              <spinque:attribute subject="{$arrest}" attribute="sdo:description" value="{concat('Op ${date} is ', $name , ' krijgsgevangen gemaakt', $arrestPlaceLabel, '.')}" type="string"/>
          </xsl:when>
          <xsl:otherwise>
              <spinque:attribute subject="{$arrest}" attribute="sdo:description" value="{concat($name , ' is krijgsgevangen gemaakt', $arrestPlaceLabel, '.')}" type="string"/>
          </xsl:otherwise>
      </xsl:choose>

      <xsl:variable name="imprisonment" select="su:uri($person, 'imprisonment')"/>
      <spinque:relation subject="{$imprisonment}" predicate="rdf:type" object="sdo:Event"/>
      <spinque:relation subject="{$imprisonment}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/6354"/>
      <spinque:attribute subject="{$imprisonment}" attribute="rdfs:label" value="Gevangenschap" type="string"/>
      <spinque:relation subject="{$imprisonment}" predicate="prov:wasDerivedFrom" object="{$record}"/>
      <spinque:relation subject="{$imprisonment}" predicate="sdo:actor" object="{$person}"/>
      <xsl:variable name="camp_name">
          <xsl:choose>
              <xsl:when test="field[@name='Camp1_clean'] != ''">
                  <xsl:value-of select="field[@name='Camp1_clean']"/>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:value-of select="su:substringAfter(field[@name='Camp1'], ';')"/>
              </xsl:otherwise>
          </xsl:choose>
      </xsl:variable>
      <spinque:attribute subject="{$imprisonment}" attribute="sdo:location" value="{$camp_name}" type="string"/>
      <spinque:attribute subject="{$imprisonment}" attribute="sdo:startDate" value="{su:parseDate(field[@name='date_of_capture'],'yyyy-MM-dd')}" type="date"/>
      <!-- dit is de zelfde datum als bij de arrestatie. Dat hoeft niet te kloppen -->
      <spinque:attribute subject="{$imprisonment}" attribute="sdo:alternateName" value="{concat($name , ' heeft gevangen gezeten in ', $camp_name,'.')}" type="string"/>
      <spinque:attribute subject="{$imprisonment}" attribute="sdo:description" value="{concat('Vanaf ${startDate}', ' heeft ', $name , ' gevangen gezeten in ', $camp_name,'.')}" type="string"/>

    <!-- Transfer als event is nieuw. Zou ook als event gemodelleerd kunnen worden, maar niet op basis van de data in deze dataset. Daarom hier alleen als attribute bij de persoon -->
    <xsl:variable name="transfer">
        <xsl:choose>
            <xsl:when test="field[@name='Other_info1'] != ''">
                <xsl:for-each select="su:split(field[@name='Other_info1'], ';')">
                    <xsl:choose>
                        <xsl:when test="contains(su:lowercase(.), 'transfer')">
                            <xsl:value-of select="."/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <spinque:attribute subject="{$person}" attribute="niod:transferred" value="{$transfer}" type="string"/>

  </xsl:template>

</xsl:stylesheet>
