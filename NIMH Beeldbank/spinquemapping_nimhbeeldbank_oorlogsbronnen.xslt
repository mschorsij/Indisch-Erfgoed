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
    <!--
	<record xmlns="http://www.openarchives.org/OAI/2.0/">
      <header>
        <identifier>oai:136820bf-414b-7d8b-026b-bc637ad8a77f:c76fb63c-e27b-11df-8518-07a625a03e79</identifier>
        <datestamp>2016-03-07T14:02:32Z</datestamp>
        <setSpec>c76fb560-e27b-11df-8515-a779f60d9fa1</setSpec>
        <setSpec>c76fb560-e27b-11df-8515-a779f60d9fa1:c76fb63c-e27b-11df-8518-07a625a03e79</setSpec>
        <setSpec>c76fb560-e27b-11df-8515-a779f60d9fa1:c76fb63c-e27b-11df-8518-07a625a03e79:2ac62636-40db-6272-cd5b-7a88572e5d90</setSpec>
      </header>
      <metadata>
        <europeana:record xmlns:europeana="http://www.europeana.eu/schemas/ese/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/">
          <dc:identifier>2182-020-004</dc:identifier>
          <dc:description>Korporaal-telegrafist KM M. (Mattheus) Stroosnijder, geboren op 30-3-1911 te Ierseke. Was van oorsprong Kwartiermeester. 320 squadron, tweede wereldoorlog. Stroosnijder is
          in juni 1943 geplaatst bij 860 squadron RAF als Vliegtuigtelegrafist/mitrailleurschutter.</dc:description>
          <dc:subject>Stroosnijder M.</dc:subject>
          <dc:subject>samenleving, defensie, conflicten, Tweede Wereldoorlog</dc:subject>
          <dc:subject>samenleving, economie, personeel, beroepen, piloten</dc:subject>
          <dc:subject>samenleving, defensie, strijdkrachten, Britse strijdkrachten, Britse luchtstrijdkrachten, Royal Air Force, 320 (Dutch) Squadron (RAF)</dc:subject>
          <dc:subject>samenleving, defensie, strijdkrachten, Britse strijdkrachten, Britse luchtstrijdkrachten, Royal Air Force</dc:subject>
          <dc:subject>samenleving, mensen</dc:subject>
          <dcterms:created>1940 / 1945</dcterms:created>
          <dc:type>Foto</dc:type>
          <europeana:type>IMAGE</europeana:type>
          <dcterms:isPartOf>Nederlanders bij de RAF</dcterms:isPartOf>
          <europeana:dataProvider>Nederlands Instituut voor Militaire Historie</europeana:dataProvider>
          <europeana:provider>Nederlands Instituut voor Militaire Historie</europeana:provider>
          <dc:rights>Nederlands Instituut voor Militaire Historie</dc:rights>
          <europeana:rights>http://www.europeana.eu/rights/rr-f/</europeana:rights>
          <europeana:isShownAt>http://nimh-beeldbank.defensie.nl/memorix/136820bf-414b-7d8b-026b-bc637ad8a77f</europeana:isShownAt>
          <europeana:object>https://images.memorix.nl/nda/thumb/640x480/29162194-240a-da25-26cd-35ce28779d39.jpg</europeana:object>
        </europeana:record>
      </metadata>
    </record>
    -->
    <xsl:template match="recordlist | record | metadata">
        <xsl:apply-templates/>
    </xsl:template>


    <!-- *** Entry point for OAI-DC records  *** -->
    <xsl:template match="europeana:record">
        <xsl:variable name="subject" select="europeana:isShownAt"/>
        <xsl:choose>
            <xsl:when test="(dcterms:spatial = 'Nederlands-Indië')">
                <xsl:if
                    test="contains(dcterms:created, '1946')
                    or contains(dcterms:created, '1947')
                    or contains(dcterms:created, '1948')
                    or contains(dcterms:created, '1949')
                    or contains(dcterms:created, '1950')">
                    <xsl:call-template name="dc_record">
                        <xsl:with-param name="subject" select="$subject"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            <xsl:when
                test="contains(dc:description, 'Tweede Wereldoorlog')
                or contains(dc:subject, 'Tweede Wereldoorlog')
                or contains(dcterms:created, '1939')
                or contains(dcterms:created, '1940')
                or contains(dcterms:created, '1941')
                or contains(dcterms:created, '1942')
                or contains(dcterms:created, '1943')
                or contains(dcterms:created, '1944')
                or contains(dcterms:created, '1945')">
                <xsl:call-template name="dc_record">
                    <xsl:with-param name="subject" select="$subject"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- *** generic Dublin Core parser *** -->
    <xsl:template name="dc_record">
        <xsl:param name="subject"/>

        <spinque:attribute
            subject="{$subject}"
            attribute="schema:thumbnail"
            value="{su:replace(europeana:object, '640x480', '1000x1000')}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:source"
            value="{europeana:isShownAt}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:identifier"
            value="{dc:identifier}"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:description"
            value="{su:stripTags(dc:description)}"
            type="string"/>
        <!-- *** Link Publisher *** -->
        <spinque:relation
            subject="{$subject}"
            predicate="dc:publisher"
            object="niod:Organizations/4"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:publisher"
            value="NIMH"
            type="string"/>
        <!-- end -->
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:language"
            value="nl"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dcmit:Collection"
            value="Beeldbank NIMH"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="schema:disambiguatingDescription"
            value="In Oorlogsbronnen in set beeldbank_nimh"
            type="string"/>
        <spinque:relation
            subject="{$subject}"
            predicate="rdf:type"
            object="schema:Photograph"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:type"
            value="foto"
            type="string"/>
        <spinque:attribute
            subject="{$subject}"
            attribute="dc:date"
            value="{dcterms:created}"
            type="string"/>

        <xsl:choose>
            <xsl:when test="contains(europeana:rights, 'rr-f')">
                <spinque:relation
                    subject="{$subject}"
                    predicate="dc:rights"
                    object="http://rightsstatements.org/vocab/InC/1.0/"/>
                <spinque:attribute
                    subject="{$subject}"
                    attribute="dc:rights"
                    value="In Copyright"
                    type="string"/>
            </xsl:when>
            <xsl:when test="string-length(europeana:rights) != 0">
                <spinque:relation
                    subject="{$subject}"
                    predicate="dc:rights"
                    object="http://rightsstatements.org/vocab/InC/1.0/"/>
                <spinque:attribute
                    subject="{$subject}"
                    attribute="dc:rights"
                    value="In Copyright"
                    type="string"/>
            </xsl:when>
            <xsl:when test="dc:creator != ''">
                <spinque:relation
                    subject="{$subject}"
                    predicate="dc:rights"
                    object="http://rightsstatements.org/vocab/InC/1.0/"/>
                <spinque:attribute
                    subject="{$subject}"
                    attribute="dc:rights"
                    value="In Copyright"
                    type="string"/>
            </xsl:when>
            <xsl:otherwise>
                <spinque:relation
                    subject="{$subject}"
                    predicate="dc:rights"
                    object="http://rightsstatements.org/vocab/CNE/1.0/"/>
                <spinque:attribute
                    subject="{$subject}"
                    attribute="dc:rights"
                    value="Copyright niet bekend"
                    type="string"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="dc:title != ''">
                <spinque:attribute subject="{$subject}"
                    attribute="dc:title" value="{dc:title}"
                    type="string"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="dc:description != ''">
                        <!--spinque:attribute
                            subject="{$subject}"
                            attribute="dc:title"
                            value="{su:stripTags(dc:description)}"
                            type="string"/-->

                        <xsl:variable name="title" select="su:normalizeWhiteSpace(su:stripTags(dc:description))"/>

                        <xsl:choose>
                            <xsl:when test="string-length($title) &gt; 21">
                                <xsl:variable name="titleLang"
                                    select="substring($title, 20, string-length($title))"/>
                                <xsl:variable name="titleKort">
                                    <xsl:choose>
                                        <!--xsl:when test="contains($titleLang, '(')">
									<xsl:value-of select="substring-before($titleLang, '(')"/>
								</xsl:when-->
                                        <xsl:when test="contains($titleLang, ',')">
                                            <xsl:value-of select="substring-before($titleLang, ',')"/>
                                        </xsl:when>
                                        <xsl:when test="contains($titleLang, '.')">
                                            <xsl:value-of select="substring-before($titleLang, '.')"/>
                                        </xsl:when>
                                        <!--xsl:when test="contains($titleLang, ';')">
									<xsl:value-of select="substring-before($titleLang, ';')"/>
								</xsl:when-->
                                        <xsl:otherwise>
                                            <xsl:value-of select="$titleLang"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <spinque:attribute
                                    subject="{$subject}"
                                    attribute="dc:title"
                                    value="{concat(substring($title, 1,19), $titleKort)}"
                                    type="string"/>
                                <spinque:attribute
                                    subject="{$subject}"
                                    attribute="dc:description"
                                    value="{$title}"
                                    type="string"/>
                                <!--spinque:debug message="ORG: {$title}"/-->
                                <!--spinque:debug message="TIT: {substring($title, 1,19)}"/-->
                                <!--spinque:debug message="KORT: {$titleKort}"/-->
                                <!--spinque:debug message="DEF: {concat(substring($title, 1,19), $titleKort)}"/-->
                            </xsl:when>
                            <xsl:otherwise>
                                <spinque:attribute
                                    subject="{$subject}"
                                    attribute="dc:title"
                                    value="{$title}"
                                    type="string"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>

                    <xsl:otherwise>
                        <spinque:attribute subject="{$subject}"
                            attribute="dc:title" value="{dc:subject}"
                            type="string"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>

		<xsl:if test="dcterms:spatial != ''">
        	<xsl:variable name="aantal" select="string-length(dcterms:spatial)-string-length(translate(dcterms:spatial,',',''))"/>

        	<xsl:choose>
        		<xsl:when test="$aantal = '0' and dcterms:spatial != 'Nederland'">
        			<!--<xsl:variable name="spatial" select="su:uri($subject, 'place')"/>
        			<spinque:relation subject="{$subject}" predicate="schema:contentLocation" object="{$spatial}"/>
        			<spinque:relation subject="{$spatial}" predicate="rdf:type" object="schema:Place"/>-->
        			<spinque:attribute subject="{$subject}" attribute="schema:contentLocation" value="{dcterms:spatial}" type="string"/>
        		</xsl:when>
        		<xsl:when test="number($aantal) > 0">
        			<!--xsl:variable name="spatial" select="su:uri($subject, 'place')"/>
        			<spinque:relation subject="{$subject}" predicate="schema:contentLocation" object="{$spatial}"/>
        			<spinque:relation subject="{$spatial}" predicate="rdf:type" object="schema:Place"/-->
        			<spinque:attribute subject="{$subject}" attribute="schema:contentLocation" value="{substring-before(dcterms:spatial,',')}" type="string"/>
        			<!--spinque:debug message="{substring-before(dcterms:spatial,',')} - {$aantal}"/-->
        		</xsl:when>
        	</xsl:choose>
		</xsl:if>

        <xsl:apply-templates select="dc:subject">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>


        <xsl:apply-templates select="dc:creator">
            <xsl:with-param name="subject" select="$subject"/>
        </xsl:apply-templates>

    </xsl:template>

    <!-- ******* -->

    <xsl:template match="dcterms:created">
        <xsl:param name="subject"/>
        <xsl:variable name="datering">
            <xsl:choose>
                <xsl:when test="contains(su:lowercase(.), 'circa')">
                    <xsl:value-of select="su:replaceAll(su:lowercase(.), 'circa', '')"/>
                </xsl:when>
                <xsl:when test="contains(su:lowercase(.), '0000')">
                    <xsl:value-of select="su:replaceAll(su:lowercase(.), '0000', '')"/>
                </xsl:when>
                <xsl:when test="contains(su:lowercase(.), '0300')">
                    <xsl:value-of select="su:replaceAll(su:lowercase(.), '0300', '')"/>
                </xsl:when>
                <xsl:when test="contains(su:lowercase(.), '1000')">
                    <xsl:value-of select="su:replaceAll(su:lowercase(.), '1000', '')"/>
                </xsl:when>
                <xsl:when test="contains(su:lowercase(.), '0902')">
                    <xsl:value-of select="su:replaceAll(su:lowercase(.), '0902', '')"/>
                </xsl:when>
                <xsl:when test="contains(su:lowercase(.), '0500')">
                    <xsl:value-of select="su:replaceAll(su:lowercase(.), '0500', '')"/>
                </xsl:when>
                <xsl:when test="contains(su:lowercase(.), '1105')">
                    <xsl:value-of select="su:replaceAll(su:lowercase(.), '1105', '')"/>
                </xsl:when>
                <xsl:when test="contains(su:lowercase(.), '1305')">
                    <xsl:value-of select="su:replaceAll(su:lowercase(.), '1305', '')"/>
                </xsl:when>
                <xsl:when test="contains(su:lowercase(.), 'mogelijk')">
                    <xsl:value-of select="su:replaceAll(su:lowercase(.), 'mogelijk ', '')"/>
                </xsl:when>
                <xsl:when test="contains(su:lowercase(.), 'heden')">
                    <xsl:value-of select="su:replaceAll(su:lowercase(.), 'heden ', '')"/>
                </xsl:when>
                <xsl:when test="contains(su:lowercase(.), 'winter')">
                    <xsl:value-of select="su:replaceAll(su:lowercase(.), 'winter ', '')"/>
                </xsl:when>
                <xsl:when test="contains(su:lowercase(.), 'voorjaar')">
                    <xsl:value-of select="su:replaceAll(su:lowercase(.), 'voorjaar ', '')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="contains($datering, ' / ')">
                <xsl:choose>
                    <xsl:when
                        test="substring-before($datering, ' / ') = substring-after($datering, ' / ')">
                        <spinque:attribute subject="{$subject}"
                            attribute="dc:date" type="date"
                            value="{su:parseDate(substring-before($datering, ' / '), 'yyyy-MM-dd', 'yyyy-MM', 'yyyy')}"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <spinque:attribute subject="{$subject}"
                            attribute="schema:startDate" type="date"
                            value="{su:parseDate(substring-before($datering, ' / '), 'yyyy-MM-dd', 'yyyy-MM', 'yyyy')}"/>
                        <spinque:attribute subject="{$subject}"
                            attribute="schema:endDate" type="date"
                            value="{su:parseDate(substring-after($datering, ' / '), 'yyyy-MM-dd', 'yyyy-MM', 'yyyy')}"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="contains($datering, ' /')">
                <spinque:attribute subject="{$subject}"
                    attribute="dc:date" type="date"
                    value="{su:parseDate(substring-before($datering, ' /'), 'yyyy-MM-dd', 'yyyy-MM', 'yyyy')}"
                />
            </xsl:when>
            <xsl:when test="contains($datering, '/ ')">
                <spinque:attribute subject="{$subject}"
                    attribute="dc:date" type="date"
                    value="{su:parseDate(substring-before($datering, ' /'), 'yyyy-MM-dd', 'yyyy-MM', 'yyyy')}"
                />
            </xsl:when>
            <xsl:when test="($datering = '/') or contains($datering, '19400300')"> </xsl:when>
            <xsl:otherwise>
                <!--spinque:debug message="{.}"/-->
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="dc:subject">
        <xsl:param name="subject"/>
        <!--	Add by Michiel -->
        <xsl:choose>
            <xsl:when test="contains(., ',')">
                <xsl:variable name="arrayOfItems" select="su:split(su:lowercase(.), ',', 7)"/>

                <spinque:attribute subject="{$subject}"
                    attribute="dc:subject" value="{$arrayOfItems[1]}"
                    type="string"/>
                <spinque:attribute subject="{$subject}"
                    attribute="dc:subject" value="{$arrayOfItems[2]}"
                    type="string"/>
                <spinque:attribute subject="{$subject}"
                    attribute="dc:subject" value="{$arrayOfItems[3]}"
                    type="string"/>
                <spinque:attribute subject="{$subject}"
                    attribute="dc:subject" value="{$arrayOfItems[4]}"
                    type="string"/>
                <spinque:attribute subject="{$subject}"
                    attribute="dc:subject" value="{$arrayOfItems[5]}"
                    type="string"/>
                <spinque:attribute subject="{$subject}"
                    attribute="dc:subject" value="{$arrayOfItems[7]}"
                    type="string"/>
            </xsl:when>
            <xsl:otherwise>
                <spinque:attribute subject="{$subject}"
                    attribute="dc:subject" value="{su:lowercase(.)}"
                    type="string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="dc:creator">
        <xsl:param name="subject"/>
        <spinque:attribute subject="{$subject}" attribute="dc:creator"
            value="{.}" type="string"/>
    </xsl:template>


</xsl:stylesheet>
