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

        <xsl:template match="results/hits/node/_source">
            <!-- De gegevens van de Oorlogsgravenstichting wordt gefilterd op periode aan de hand van de sterfdatum (tussen 1930 en 1969) en op relatie met het thema aan de hand van de categorieen. Personen waarvan de naam onbekend is worden geskipt -->
            <!-- <spinque:debug message="{su:stripTags(su:flatten(categories/node))}"/> -->
            <xsl:if test="su:matches(date_of_death, '.*19[3-6].*') and (contains(su:stripTags(su:lowercase(su:flatten(categories/node))), 'noi') or contains(su:stripTags(su:lowercase(su:flatten(categories/node))), 'knil') or contains(su:stripTags(su:lowercase(su:flatten(categories/node))), 'bersiap'))">
                <xsl:if test="name/full_name != 'Onbekende'">
                    <xsl:variable name="name" select="name/full_name"/>
                	  <xsl:variable name="id" select="su:replace(_id,'.0','')"/>
          	    		<xsl:variable name="organizationId">oorlogsgravenstichting</xsl:variable>
                    <xsl:variable name="url" select="url_ogs_website" />

                    <!--  id voor het record en de persoon op basis van de naam -->
                    <xsl:variable name="record" select="su:uri($base, $organizationId, 'record', su:replaceAll($name, ' ', '-'), $id)"/>
             	    	<xsl:variable name="person">
                				<xsl:choose>
                  					<xsl:when test="contains($name, '%27')">
                  						<xsl:value-of select="su:uri($base, $organizationId, 'person', su:replaceAll(su:replaceAll($name, '%27',''), ' ', '-'), $id)"/>
                  					</xsl:when>
                  					<xsl:otherwise>
                  						<xsl:value-of select="su:uri($base, $organizationId, 'person', su:replaceAll($name, ' ', '-'), $id)"/>
                  					</xsl:otherwise>
                				</xsl:choose>
              			</xsl:variable>

                    <spinque:relation subject="{$record}" predicate="rdf:type" object="prov:Entity"/>
                    <spinque:attribute subject="{$record}" attribute="sdo:url" value="{$url}" type="string"/>
                    <spinque:relation subject="{$record}" predicate="sdo:publisher" object="niod:Organizations/293"/>

                    <spinque:relation subject="{$person}" predicate="prov:wasDerivedFrom" object="{$record}"/>

                  	<xsl:call-template name="person">
                      	<xsl:with-param name="person" select="$person"/>
                      	<xsl:with-param name="record" select="$record"/>
                        <xsl:with-param name="name" select="$name"/>
                        <xsl:with-param name="id" select="$id"/>
                      	<xsl:with-param name="url" select="$url"/>
                  	</xsl:call-template>
                </xsl:if>
            </xsl:if>
        </xsl:template>

        <!-- Person -->
        <xsl:template name="person">
            <xsl:param name="person"/>
            <xsl:param name="record"/>
            <xsl:param name="name"/>
            <xsl:param name="id"/>
            <xsl:param name="url"/>

            <xsl:variable name="birthDate" select="su:parseDate(date_of_birth, 'nl_nl', 'yyyy-MM-dd', 'yyyy-MM', 'yyyy')"/>
            <xsl:variable name="deathDate" select="su:parseDate(date_of_death, 'nl_nl', 'yyyy-MM-dd', 'yyyy-MM', 'yyyy')"/>
            <xsl:variable name="birthPlace" select="place_of_birth"/>
            <xsl:variable name="deathPlace" select="place_of_death"/>

            <spinque:relation subject="{$person}" predicate="rdf:type" object="sdo:Person"/>
            <spinque:attribute subject="{$person}" attribute="sdo:url" value="{$url}" type="string"/>
            <spinque:attribute subject="{$person}" attribute="niod:oorlogslevensIdentifier" value="{su:substringAfter($person, 'person/')}" type="string"/>
            <spinque:attribute subject="{$person}" attribute="sdo:name" value="{$name}" type="string"/>
            <spinque:attribute subject="{$person}" attribute="sdo:givenName" value="{name/first_names}" type="string"/>
            <spinque:attribute subject="{$person}" attribute="sdo:familyName" value="{name/surname}" type="string"/>
            <spinque:attribute subject="{$person}" attribute="niod:familyNamePrefix" value="{name/middle_names}" type="string"/>
            <spinque:attribute subject="{$person}" attribute="niod:initials" value="{name/initials}" type="string"/>
            <xsl:choose>
            	<xsl:when test="gender = 'Vrouw'">
            		<spinque:relation subject="{$person}" predicate="sdo:gender" object="sdo:Female"/>
               		<xsl:choose>
                    	<xsl:when test="contains(name/surname, '-')">
                        	<spinque:attribute subject="{$person}" attribute="niod:maidenName" value="{substring-after(name/surname, '-')}" type="string"/>
                        	<spinque:attribute subject="{$person}" attribute="niod:marriedName" value="{substring-before(name/surname, '-')}" type="string"/>
                    	</xsl:when>
                    	<xsl:when test="name/maiden_name != ''">
                        	<spinque:attribute subject="{$person}" attribute="niod:maidenName" value="{name/maiden_name}" type="string"/>
                    	</xsl:when>
                	</xsl:choose>
            	</xsl:when>
              <xsl:when test="gender = 'Man'">
              		<spinque:relation subject="{$person}" predicate="sdo:gender" object="sdo:Male"/>
            	</xsl:when>
              <xsl:when test="gender = 'Onbekend'">
              		<spinque:attribute subject="{$person}" attribute="sdo:gender" value="Onbekend" type="string"/>
            	</xsl:when>
            </xsl:choose>

            <spinque:attribute subject="{$person}" attribute="sdo:birthDate" value="{$birthDate}" type="date"/>
            <spinque:attribute subject="{$person}" attribute="sdo:deathDate" value="{$deathDate}" type="date"/>
            <spinque:attribute subject="{$person}" attribute="sdo:birthPlace" value="{$birthPlace}" type="string"/>
            <spinque:attribute subject="{$person}" attribute="sdo:deathPlace" value="{$deathPlace}" type="string"/>

            <xsl:apply-templates select="profession">
                <xsl:with-param name="person" select="$person"/>
            </xsl:apply-templates>

            <!-- Life events birth, death, residence-->
            <xsl:if test="$birthDate != ''">
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
                <spinque:attribute subject="{$birth}" attribute="sdo:alternateName" value="{concat($name, ' is geboren', $birthPlaceLabel,'.')}" type="string"/>
                <spinque:attribute subject="{$birth}" attribute="sdo:description" value="{concat('Op ${date} is ', $name, ' geboren', $birthPlaceLabel,'.')}" type="string"/>
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
                <spinque:attribute subject="{$death}" attribute="sdo:description" value="{concat('Op ${date} is ', $name, ' omgekomen', $deathPlaceLabel,'.')}" type="string"/>
          	</xsl:if>

    <!-- In onderstaande variant zit een onderscheid tussen omgekomen en overleden, kunnen we daar wat mee in Indisch Erfgoed? -->
            <!-- <xsl:if test="($deathDate != '') and ($name != 'Rosette Susanna Manus') and ($name != 'Roosje Wolf-Leezer')">
                <xsl:variable name="death" select="su:uri($person, 'death')"/>
                <xsl:choose>
                    <xsl:when test="number(su:substringBefore($deathDate,'-') &lt; 1946)">

                        <spinque:attribute subject="{$death}" attribute="sdo:name" value="Omgekomen" type="string"/>
                        <spinque:relation subject="{$death}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/8772"/>
              <xsl:variable name="deathPlaceLabel"><xsl:if test="$deathPlace != ''"><xsl:value-of select="concat(' in ', su:trim($deathPlace))"/></xsl:if></xsl:variable>
              <spinque:attribute subject="{$death}" attribute="sdo:alternateName" value="{concat($name , ' is omgekomen', $deathPlaceLabel)}" type="string"/>
                    <spinque:attribute subject="{$death}" attribute="sdo:description" value="{concat('Op ${date} is ', $name , ' omgekomen', $deathPlaceLabel,'.')}" type="string"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <spinque:attribute subject="{$death}" attribute="sdo:name" value="Overleden" type="string"/>
                        <spinque:relation subject="{$death}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/6361"/>
              <xsl:variable name="deathPlaceLabel"><xsl:if test="$deathPlace != ''"><xsl:value-of select="concat(' in ', su:trim($deathPlace))"/></xsl:if></xsl:variable>
              <spinque:attribute subject="{$death}" attribute="sdo:alternateName" value="{concat($name , ' is overleden', $deathPlaceLabel)}" type="string"/>
                    <spinque:attribute subject="{$death}" attribute="sdo:description" value="{concat('Op ${date} is ', $name , ' overleden', $deathPlaceLabel,'.')}" type="string"/>
                    </xsl:otherwise>
                </xsl:choose>
                <spinque:relation subject="{$death}" predicate="rdf:type" object="sdo:Event"/>
                <spinque:relation subject="{$death}" predicate="prov:wasDerivedFrom" object="{$record}"/>
                <spinque:relation subject="{$death}" predicate="sdo:actor" object="{$person}"/>
                <spinque:attribute subject="{$death}" attribute="sdo:date" value="{$deathDate}" type="date"/>
                <spinque:attribute subject="{$death}" attribute="sdo:location" value="{$deathPlace}" type="string"/>

            </xsl:if> -->

            <xsl:if test="last_known_address/address != '' or last_known_address/city != ''">
                <xsl:variable name="residence" select="su:uri($person, 'residence')"/>
                <spinque:relation subject="{$residence}" predicate="rdf:type" object="sdo:Residence"/>
                <spinque:attribute subject="{$residence}" attribute="rdfs:label" value="Laatst bekende adres" type="string"/>
                <spinque:relation subject="{$residence}" predicate="prov:wasDerivedFrom" object="{$record}"/>
                <spinque:relation subject="{$residence}" predicate="sdo:actor" object="{$person}"/>
            	<xsl:variable name="residenceLabel">
            		<xsl:choose>
            			<xsl:when test="last_known_address/address != ''">
            				<xsl:value-of select="concat(last_known_address/address, ', ', last_known_address/city)"/>
            			</xsl:when>
            			<xsl:otherwise>
            				<xsl:value-of select="last_known_address/city"/>
            			</xsl:otherwise>
            		</xsl:choose>
            	</xsl:variable>
              <spinque:attribute subject="{$residence}" attribute="sdo:address" value="{last_known_address/address}" type="string"/>
              <spinque:attribute subject="{$residence}" attribute="sdo:addressLocality" value="{last_known_address/city}" type="string"/>
              <spinque:attribute subject="{$residence}" attribute="sdo:location" value="{$residenceLabel}" type="string"/>
              <spinque:attribute subject="{$residence}" attribute="sdo:alternateName" value="{concat($name, ' had als laatst bekende adres ', $residenceLabel,'.')}" type="string"/>
            </xsl:if>

            <xsl:for-each select="images/node">
            		<xsl:choose>
                  	<xsl:when test="main_image = 'true'">
                       <xsl:variable name="imageId" select="id"/>
                      	<xsl:variable name="recordImage" select="su:uri($person, 'image', $imageId)"/>
                				<spinque:relation subject="{$recordImage}" predicate="rdf:type" object="sdo:CreativeWork"/>
                				<spinque:relation subject="{$recordImage}" predicate="rdf:type" object="sdo:ImageObject"/>
                				<spinque:relation subject="{$recordImage}" predicate="sdo:publisher" object="niod:Organizations/293"/>
                				<spinque:relation subject="{$recordImage}" predicate="sdo:maintainer" object="niod:Organizations/293"/>
                				<spinque:relation subject="{$recordImage}" predicate="prov:wasDerivedFrom" object="{$record}"/>
                				<spinque:attribute subject="{$recordImage}" attribute="sdo:position" value="2" type="integer"/><!-- weging van plaatje tov andere afbeeldingen bij persoon /-->
                				<spinque:attribute subject="{$recordImage}" attribute="sdo:caption" value="{images/node/title}" type="string"/>
                    		<spinque:attribute subject="{$recordImage}" attribute="sdo:url" value="{images/node/url}" type="string"/>
                        <spinque:relation subject="{$person}" predicate="sdo:image" object="{$recordImage}"/>
                  	</xsl:when>
                  	<xsl:otherwise>
                      <xsl:variable name="imageId" select="id"/>
                      <xsl:variable name="recordImage" select="su:uri($person, 'image', $imageId)"/>
                      <spinque:relation subject="{$recordImage}" predicate="rdf:type" object="sdo:CreativeWork"/>
                      <spinque:relation subject="{$recordImage}" predicate="rdf:type" object="sdo:ImageObject"/>
                      <spinque:relation subject="{$recordImage}" predicate="sdo:publisher" object="niod:Organizations/293"/>
                      <spinque:relation subject="{$recordImage}" predicate="sdo:maintainer" object="niod:Organizations/293"/>
                      <spinque:relation subject="{$recordImage}" predicate="sdo:about" object="{$person}"/>
                      <spinque:relation subject="{$recordImage}" predicate="prov:wasDerivedFrom" object="{$record}"/>
                      <spinque:attribute subject="{$recordImage}" attribute="sdo:position" value="3" type="integer"/><!-- weging van plaatje tov andere afbeeldingen bij persoon /-->
                      <spinque:attribute subject="{$recordImage}" attribute="sdo:caption" value="{images/node/title}" type="string"/>
                      <spinque:attribute subject="{$recordImage}" attribute="sdo:url" value="{images/node/url}" type="string"/>
                  	</xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:apply-templates select="categories/node/name">
                <xsl:with-param name="person" select="$person"/>
            </xsl:apply-templates>

        </xsl:template>

        <!-- Matching categorieen Oorlogsgraven met WO2 thesaurus. Wat kan hier weg, wat moet er bij? Is dit niet meer iets voor in de strategie? Moeten we niet matchen met Indische thesaurus?-->
        <xsl:template match="categories/node/name">
            <xsl:param name="person"/>
            <spinque:attribute subject="{$person}" attribute="sdo:about" value="{.}" type="string"/>
            <xsl:choose>
            	<xsl:when test="(. = 'Militair') or (. = 'Koninklijke Marine') and (. != 'KNIL') and (. != 'NOI')">
            		<spinque:relation subject="{$person}" predicate="sdo:memberOf" object="niod:WO2_Thesaurus/11187"/>
                <!-- Militair -->
                </xsl:when>
                <xsl:when test="(. = 'KNIL') or (. = 'Krijgsgevangene Japan')">
            		<spinque:relation subject="{$person}" predicate="sdo:memberOf" object="niod:WO2_Thesaurus/11195"/>
                <!-- Militair in Nederlands-Indië -->
                </xsl:when>
                <xsl:when test="(. = 'Sjoa') or contains(.,'Jood')">
            		<spinque:relation subject="{$person}" predicate="sdo:memberOf" object="niod:WO2_Thesaurus/11190"/>
                <!-- Joods -->
                </xsl:when>
                <xsl:when test="(. = 'Burger') and (. != 'Verzet') and (. != 'NOI')">
            		<spinque:relation subject="{$person}" predicate="sdo:memberOf" object="niod:WO2_Thesaurus/11186"/>
                <!-- Burger -->
                </xsl:when>
                <xsl:when test="contains(., 'Japans burger') or contains(., 'NOI') and (. != 'KNIL')">
            		<spinque:relation subject="{$person}" predicate="sdo:memberOf" object="niod:WO2_Thesaurus/11197"/>
                <!-- Burger in Nederlands-Indië -->
                </xsl:when>
                <xsl:when test="(. = 'Verzet')">
            		<spinque:relation subject="{$person}" predicate="sdo:memberOf" object="niod:WO2_Thesaurus/11188"/>
                <!-- Verzetsdeelnemer -->
                </xsl:when>
                <xsl:when test=". = 'Sinti en Roma'">
            		<spinque:relation subject="{$person}" predicate="sdo:memberOf" object="niod:WO2_Thesaurus/11191"/>
                <!-- Sinti Roma -->
                </xsl:when>
            </xsl:choose>
        </xsl:template>

        <xsl:template match="profession">
            <xsl:param name="person"/>
            <xsl:for-each select="su:split(., ',')">
                <spinque:attribute subject="{$person}" attribute="sdo:jobTitle" value="{.}" type="string"/>
            </xsl:for-each>
        </xsl:template>

    </xsl:stylesheet>
