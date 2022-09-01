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

    <xsl:variable name="base">https://www.oorlogslevens.nl/</xsl:variable>

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:template match="property[@name='_source']/object">

        <xsl:if test="not(contains(property[@name='name']/object/property[@name='full_name']/literal, 'Onbekende')) and not(number(substring(property[@name='date_of_birth']/literal, 1,4)) &gt; 1950) and not(contains(property[@name='date_of_death']/literal, '191'))">
            <xsl:if test="(property[@name='date_of_death']/literal != '') and (property[@name='person_status_id']/literal != '6') and (property[@name='_id']/literal != '78624')"><!-- 22/03/28 id is van Evert Klein, familie maakt bezwaar -->
            <!-- in de ogs set kunnen in principe levenden zitten. Ik sluit ze uit met person_status_id = 6 -->
            	<xsl:variable name="id" select="su:replace(property[@name='_id']/literal,'.0','')"/>
	    		<xsl:variable name="name" select="property[@name='name']/object/property[@name='full_name']/literal"/>
	    		<xsl:variable name="organizationId">02</xsl:variable>
            	<xsl:variable name="record" select="su:uri($base, 'record', su:replaceAll($name, ' ', '-'), $organizationId, $id)"/>
       	    	<!--xsl:variable name="person" select="su:uri($base, 'person', su:replaceAll($name, ' ', '-'),  $organizationId, $id)"/-->
       	    	<xsl:variable name="person">
      				<xsl:choose>
      					<xsl:when test="contains($name, '%27')">
      						<xsl:value-of select="su:uri($base, 'person', su:replaceAll(su:replaceAll($name, '%27',''), ' ', '-'), $organizationId, $id)"/>
      						<!--spinque:debug message="{$name}"/-->
      					</xsl:when>
      					<xsl:otherwise>
      						<xsl:value-of select="su:uri($base, 'person', su:replaceAll($name, ' ', '-'), $organizationId, $id)"/>
      					</xsl:otherwise>
      				</xsl:choose>
      			</xsl:variable>

            	<xsl:variable name="url" select="su:uri('https://www.oorlogsgravenstichting.nl/persoon', $id, su:replaceAll(su:lowercase($name),' ','-'))"/>

            	<!-- Provenance -->
            	<spinque:attribute subject="{$record}" attribute="schema:url" value="{$url}" type="string"/>
            	<spinque:relation subject="{$record}" predicate="dc:publisher" object="http://www.oorlogsbronnen.nl/organisatie/ogs"/>
                <spinque:relation subject="{$record}" predicate="rdf:type" object="prov:Entity"/>

            	<xsl:call-template name="person">
                	<xsl:with-param name="person" select="$person"/>
                	<xsl:with-param name="record" select="$record"/>
                	<xsl:with-param name="url" select="$url"/>
            	</xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <!-- Person -->
    <xsl:template name="person">
        <xsl:param name="person"/>
        <xsl:param name="record"/>
        <xsl:param name="url"/>

        <xsl:variable name="birthDate" select="su:parseDate(property[@name='date_of_birth']/literal, 'nl_nl', 'yyyy-MM-dd', 'yyyy-MM', 'yyyy')"/>
        <xsl:variable name="deathDate" select="su:parseDate(property[@name='date_of_death']/literal, 'nl_nl', 'yyyy-MM-dd', 'yyyy-MM', 'yyyy')"/>
        <xsl:variable name="birthPlace" select="property[@name='place_of_birth']"/>
        <xsl:variable name="deathPlace" select="property[@name='place_of_death']"/>
        <xsl:variable name="name" select="property[@name='name']/object/property[@name='full_name']/literal"/>

        <spinque:relation subject="{$person}" predicate="rdf:type" object="schema:Person"/>
        <spinque:attribute subject="{$person}" attribute="schema:url" value="{$url}" type="string"/>
        <spinque:relation subject="{$person}" predicate="dc:publisher" object="https://www.oorlogsbronnen.nl/organisatie/ogs"/>
        <spinque:relation subject="{$person}" predicate="prov:wasDerivedFrom" object="{$record}"/>

        <spinque:attribute subject="{$person}" attribute="niod:preferredName" value="{$name}" type="string"/>
        <spinque:attribute subject="{$person}" attribute="niod:oorlogslevensIdentifier" value="{su:substringAfter($person, 'person/')}" type="string"/>

        <!-- schema.org Person properties -->
        <spinque:attribute subject="{$person}" attribute="schema:name" value="{$name}" type="string"/>
        <spinque:attribute subject="{$person}" attribute="schema:givenName" value="{property[@name='name']/object/property[@name='first_names']/literal}" type="string"/>
        <spinque:attribute subject="{$person}" attribute="schema:familyName" value="{su:normalizeWhiteSpace(concat(property[@name='name']/object/property[@name='middle_names']/literal, ' ', property[@name='name']/object/property[@name='surname']/literal))}" type="string"/>
        <xsl:choose>
        	<xsl:when test="property[@name='gender']/literal = 'Vrouw'">
        		<spinque:attribute subject="{$person}" attribute="schema:gender" value="vrouw" type="string"/>
           		<xsl:choose>
                	<xsl:when test="contains(property[@name='name']/object/property[@name='surname']/literal, '-')">
                    	<spinque:attribute subject="{$person}" attribute="niod:maidenName" value="{substring-after(property[@name='name']/object/property[@name='surname']/literal, '-')}" type="string"/>
                    	<spinque:attribute subject="{$person}" attribute="niod:marriedName" value="{substring-before(property[@name='name']/object/property[@name='surname']/literal, '-')}" type="string"/>
                	</xsl:when>
                	<xsl:when test="property[@name='name']/object/property[@name='maiden_name']/literal != ''">
                    	<spinque:attribute subject="{$person}" attribute="niod:maidenName" value="{property[@name='name']/object/property[@name='maiden_name']/literal}" type="string"/>
                	</xsl:when>
            	</xsl:choose>
        	</xsl:when>
        	<xsl:otherwise>
        		<spinque:attribute subject="{$person}" attribute="schema:gender" value="man" type="string"/>
        	</xsl:otherwise>
        </xsl:choose>
        <spinque:attribute subject="{$person}" attribute="niod:initials" value="{property[@name='name']/object/property[@name='initials']/literal}" type="string"/>
          <!-- birth -->
        <spinque:attribute subject="{$person}" attribute="schema:birthDate" value="{$birthDate}" type="date"/>
        <spinque:attribute subject="{$person}" attribute="schema:birthPlace" value="{$birthPlace}" type="string"/>
        <!-- death -->
        <spinque:attribute subject="{$person}" attribute="schema:deathDate" value="{$deathDate}" type="date"/>
        <spinque:attribute subject="{$person}" attribute="schema:deathPlace" value="{$deathPlace}" type="string"/>
        <spinque:attribute subject="{$person}" attribute="dc:identifier" value="{su:replace(property[@name='_id'], '.0','')}" type="string"/> <!-- OGS identifier -->

        <xsl:if test="property[@name='last_known_address'] != ''">
        	<xsl:variable name="adres">
        		<xsl:choose>
        			<xsl:when test="property[@name='last_known_address']/object/property[@name='address'] != ''">
        				<xsl:value-of select="concat(property[@name='last_known_address']/object/property[@name='address'], ' in ', property[@name='last_known_address']/object/property[@name='city'])"/>
        			</xsl:when>
        			<xsl:otherwise>
        				<xsl:value-of select="property[@name='last_known_address']/object/property[@name='city']"/>
        			</xsl:otherwise>
        		</xsl:choose>
        	</xsl:variable>
        	<spinque:attribute subject="{$person}" attribute="schema:homeLocation" value="{property[@name='last_known_address']/object/property[@name='city']}" type="string"/>
        	<spinque:attribute subject="{$person}" attribute="niod:homeLocationText" value="{concat('en woont in ', $adres)}" type="string"/>
        </xsl:if>
        <xsl:apply-templates select="property[@name='profession']/array/literal">
            <xsl:with-param name="person" select="$person"/>
        </xsl:apply-templates>

        <!-- url en plaatjes -->
		<xsl:choose>
        	<xsl:when test="(property[@name='main_image']/object/property[@name='url'] != '')">
            	<spinque:attribute subject="{$person}" attribute="schema:image" value="{concat('https://www.oorlogsgravenstichting.nl', property[@name='main_image']/object/property[@name='url'])}" type="string"/>
            	<xsl:variable name="recordImage" select="su:uri($person, 'image')"/>
				<spinque:relation subject="{$recordImage}" predicate="rdf:type" object="schema:CreativeWork"/>
				<spinque:relation subject="{$recordImage}" predicate="rdf:type" object="schema:ImageObject"/>
				<spinque:relation subject="{$recordImage}" predicate="dc:publisher" object="http://www.oorlogsbronnen.nl/organisatie/ogs"/>
				<spinque:attribute subject="{$recordImage}" attribute="schema:maintainer" value="Oorlogsgravenstichting" type="string"/>
				<spinque:relation subject="{$recordImage}" predicate="schema:about" object="{$person}"/>
				<spinque:relation subject="{$recordImage}" predicate="prov:wasDerivedFrom" object="{$record}"/>
				<spinque:attribute subject="{$recordImage}" attribute="schema:position" value="2" type="integer"/><!-- weging van plaatje tov andere afbeeldingen bij persoon /-->
				<spinque:attribute subject="{$recordImage}" attribute="schema:caption" value="{su:normalizeWhiteSpace(property[@name='main_image']/object/property[@name='title']/literal)}" type="string"/>
        		<spinque:attribute subject="{$recordImage}" attribute="schema:thumbnailUrl" value="{concat('https://www.oorlogsgravenstichting.nl', property[@name='main_image']/object/property[@name='url']/literal)}" type="string"/>
        		<spinque:attribute subject="{$recordImage}" attribute="schema:url" value="{$url}" type="string"/>
        	</xsl:when>
        	<xsl:otherwise>
            	<spinque:attribute subject="{$person}" attribute="schema:image" value="{concat('https://www.oorlogsgravenstichting.nl',property[@name='images']/array/object/property[@name='url']/literal[1])}" type="string"/>
        	</xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="property[@name='images']/array/object/property[@name='url']/literal">
            <xsl:variable name="recordImage" select="su:uri($person, 'image', position())"/>
			<spinque:relation subject="{$recordImage}" predicate="rdf:type" object="schema:CreativeWork"/>
			<spinque:relation subject="{$recordImage}" predicate="rdf:type" object="schema:ImageObject"/>
			<spinque:relation subject="{$recordImage}" predicate="dc:publisher" object="http://www.oorlogsbronnen.nl/organisatie/ogs"/>
			<spinque:attribute subject="{$recordImage}" attribute="schema:maintainer" value="Oorlogsgravenstichting" type="string"/>
			<spinque:relation subject="{$recordImage}" predicate="schema:about" object="{$person}"/>
			<spinque:relation subject="{$recordImage}" predicate="prov:wasDerivedFrom" object="{$record}"/>
			<spinque:attribute subject="{$recordImage}" attribute="schema:position" value="3" type="integer"/><!-- weging van plaatje tov andere afbeeldingen bij persoon /-->
			<spinque:attribute subject="{$recordImage}" attribute="schema:caption" value="{concat('Beeldmateriaal over ', $name)}" type="string"/>
        	<spinque:attribute subject="{$recordImage}" attribute="schema:thumbnailUrl" value="{concat('https://www.oorlogsgravenstichting.nl', .)}" type="string"/>
        	<spinque:attribute subject="{$recordImage}" attribute="schema:url" value="{$url}" type="string"/>
        </xsl:for-each>

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
            <spinque:attribute subject="{$birth_event}" attribute="schema:date" value="{$birthDate}" type="date"/>
            <spinque:attribute subject="{$birth_event}" attribute="schema:location" value="{$birthPlace}" type="string"/>
        </xsl:if>

        <xsl:if test="($deathDate != '') and ($name != 'Rosette Susanna Manus') and ($name != 'Roosje Wolf-Leezer')">
            <xsl:variable name="death_event" select="su:uri($person, 'death')"/>
            <xsl:choose>
                <xsl:when test="number(su:substringBefore($deathDate,'-') &lt; 1946)">
                	<!--spinque:debug message="{$deathDate}"/-->
                    <spinque:attribute subject="{$death_event}" attribute="schema:name" value="Omgekomen" type="string"/>
                    <spinque:relation subject="{$death_event}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/8772"/>
					<xsl:variable name="deathPlaceLabel"><xsl:if test="$deathPlace != ''"><xsl:value-of select="concat(' in ', su:trim($deathPlace))"/></xsl:if></xsl:variable>
					<spinque:attribute subject="{$death_event}" attribute="schema:alternateName" value="{concat($name , ' is omgekomen', $deathPlaceLabel)}" type="string"/>
            		<spinque:attribute subject="{$death_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' omgekomen', $deathPlaceLabel,'.')}" type="string"/>
                </xsl:when>
                <xsl:otherwise>
                    <spinque:attribute subject="{$death_event}" attribute="schema:name" value="Overleden" type="string"/>
                    <spinque:relation subject="{$death_event}" predicate="rdf:type" object="niod:WO2_Thesaurus/events/6361"/>
					<xsl:variable name="deathPlaceLabel"><xsl:if test="$deathPlace != ''"><xsl:value-of select="concat(' in ', su:trim($deathPlace))"/></xsl:if></xsl:variable>
					<spinque:attribute subject="{$death_event}" attribute="schema:alternateName" value="{concat($name , ' is overleden', $deathPlaceLabel)}" type="string"/>
            		<spinque:attribute subject="{$death_event}" attribute="schema:description" value="{concat('Op ${date} is ', $name , ' overleden', $deathPlaceLabel,'.')}" type="string"/>
                </xsl:otherwise>
            </xsl:choose>
            <spinque:relation subject="{$death_event}" predicate="rdf:type" object="schema:Event"/>
            <spinque:relation subject="{$death_event}" predicate="prov:wasDerivedFrom" object="{$record}"/>
            <spinque:relation subject="{$death_event}" predicate="schema:actor" object="{$person}"/>
            <spinque:attribute subject="{$death_event}" attribute="schema:date" value="{$deathDate}" type="date"/>
            <spinque:attribute subject="{$death_event}" attribute="schema:location" value="{$deathPlace}" type="string"/>

        </xsl:if>

        <!-- slachtoffer categorie en zo -->
        <xsl:apply-templates select="property[@name='categories']/array/object">
            <xsl:with-param name="person" select="$person"/>
        </xsl:apply-templates>

    </xsl:template>

    <!-- categories -->
    <xsl:template match="property[@name='categories']/array/object">
        <xsl:param name="person"/>
        <spinque:attribute subject="{$person}" attribute="dc:subject" value="{property[@name='name']/literal}" type="string"/>
        <xsl:choose>
        	<xsl:when test="(. = 'Militair') or (. = 'Koninklijke Marine') and (. != 'KNIL') and (. != 'NOI')">
        		<spinque:relation subject="{$person}" predicate="schema:memberOf" object="niod:WO2_Thesaurus/11187"/>
            </xsl:when>
            <xsl:when test="(. = 'KNIL') or (. = 'Krijgsgevangene Japan')">
        		<spinque:relation subject="{$person}" predicate="schema:memberOf" object="niod:WO2_Thesaurus/11195"/>
            </xsl:when>
            <xsl:when test="(. = 'Sjoa') or contains(.,'Jood')">
        		<spinque:relation subject="{$person}" predicate="schema:memberOf" object="niod:WO2_Thesaurus/11190"/>
            </xsl:when>
            <xsl:when test="(. = 'Burger') and (. != 'Verzet') and (. != 'NOI')">
        		<spinque:relation subject="{$person}" predicate="schema:memberOf" object="niod:WO2_Thesaurus/11186"/>
            </xsl:when>
            <xsl:when test="contains(., 'Japans burger') or contains(., 'NOI') and (. != 'KNIL')">
        		<spinque:relation subject="{$person}" predicate="schema:memberOf" object="niod:WO2_Thesaurus/11197"/>
            </xsl:when>
            <xsl:when test="(. = 'Verzet')">
        		<spinque:relation subject="{$person}" predicate="schema:memberOf" object="niod:WO2_Thesaurus/11188"/>
            </xsl:when>
            <xsl:when test=". = 'Sinti en Roma'">
        		<spinque:relation subject="{$person}" predicate="schema:memberOf" object="niod:WO2_Thesaurus/11191"/>
            </xsl:when>
            <xsl:otherwise>
            	<!--spinque:debug message="{.}"/-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="property[@name='profession']/array/literal">
        <xsl:param name="person"/>
        <spinque:attribute subject="{$person}" attribute="schema:jobTitle" value="{.}" type="string"/>
    </xsl:template>



</xsl:stylesheet>
