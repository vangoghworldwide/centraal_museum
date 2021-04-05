<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
    xmlns:dc="http://purl.org/dc/elements/1.1/">

<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
<!--xsl:strip-space elements="*"/-->

<xsl:param name="baseUri">https://centraalmuseum.nl/</xsl:param>

<xsl:template match="recordList">
    <rdf:RDF>
        <xsl:apply-templates select="record"/>
        <!-- hack for 'other images': -->
        <xsl:apply-templates select="record/Reproduction" mode="secondaryimage">
            <xsl:with-param name="uri" select="record/PIDwork/PID_work_URI"/>
        </xsl:apply-templates>
    </rdf:RDF>
</xsl:template>

<!-- do not map diagnostics -->
<xsl:template match="diagnostic"/>

<xsl:template match="record">
    <crm:E22_Human-Made_Object>
        <xsl:attribute name="rdf:about">
            <xsl:value-of select="PIDwork/PID_work_URI"/>
        </xsl:attribute>

        <!-- VGW URI -->
        <rdfs:seeAlso>
            <xsl:attribute name="rdf:resource">
                <xsl:value-of select="PIDother/PID_other_URI"/>
            </xsl:attribute>
        </rdfs:seeAlso>

        <!-- type -->
        <xsl:apply-templates select="Object_name"/>

        <!-- identifier -->
        <xsl:apply-templates select="object_number">
            <xsl:with-param name="uri" select="PIDwork/PID_work_URI"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="Alternative_number">
            <xsl:with-param name="uri" select="PIDwork/PID_work_URI"/>
        </xsl:apply-templates>

        <!-- titles -->
        <xsl:apply-templates select="Title/title">
            <xsl:with-param name="uri" select="PIDwork/PID_work_URI"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="Titel_translation/title.translation">
            <xsl:with-param name="uri" select="PIDwork/PID_work_URI"/>
        </xsl:apply-templates>

        <!-- current owner -->
        <crm:P52_has_current_owner>
            <crm:E39_Actor rdf:about="https://data.rkd.nl/artists/493820">
                <rdfs:label>Centraal Museum</rdfs:label>
            </crm:E39_Actor>
        </crm:P52_has_current_owner>

        <!-- Production -->
        <crm:P108i_was_produced_by>
            <crm:E12_Production>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="PIDwork/PID_work_URI"/>
                    <xsl:text>#production</xsl:text>
                </xsl:attribute>
                <crm:P4_has_time-span>
                    <crm:E52_Time-Span>
                        <xsl:apply-templates select="Production_date/production.date.start"/>
                        <xsl:apply-templates select="Production_date/production.date.end"/>
                    </crm:E52_Time-Span>
                </crm:P4_has_time-span>
                <xsl:apply-templates select="Production"/>
            </crm:E12_Production>
        </crm:P108i_was_produced_by>

        <!-- Dimension -->
        <xsl:apply-templates select="Dimension"/>

        <!-- Material -->
        <xsl:apply-templates select="Material"/>

        <!-- Images -->
        <xsl:apply-templates select="Reproduction" mode="primaryimage"/>

        <!-- Literature -->
        <xsl:apply-templates select="Documentation"/>

        <!-- Exhibition -->
        <xsl:apply-templates select="Exhibition/exhibition/venue"/>

    </crm:E22_Human-Made_Object>

    <xsl:apply-templates select="owner_hist.owner">
        <xsl:with-param name="uri" select="PIDwork/PID_work_URI"/>
    </xsl:apply-templates>

 
</xsl:template>

<!-- type -->
<xsl:template match="Object_name">
    <xsl:if test="string(object_name)">
        <crm:P2_has_type>
            <crm:E55_Type>
                 <xsl:if test="string(object_name/PIDother/PID_other_URI)">
                    <xsl:choose>
                        <xsl:when test="substring-after(object_name/PIDother/PID_other_URI, 'aat-ned.nl')">
                            <xsl:attribute name="rdf:about">
                                <xsl:text>http://vocab.getty.edu/aat</xsl:text>
                                <xsl:value-of select="substring-after(object_name/PIDother/PID_other_URI, 'aat-ned.nl')"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of select="object_name/PIDother/PID_other_URI"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
                <xsl:if test="string(object_name/term)">
                    <rdfs:label>
                        <xsl:value-of select="object_name/term"/>
                    </rdfs:label>
                </xsl:if>
            </crm:E55_Type>
        </crm:P2_has_type>
    </xsl:if>
</xsl:template>

<!-- identifier -->
<xsl:template match="object_number">
    <xsl:param name="uri"/>
    <xsl:if test="string(.)">
        <crm:P1_is_identified_by>
             <crm:E42_Identifier>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="$uri"/>
                    <xsl:text>#identifier</xsl:text>
                </xsl:attribute>
                <crm:P2_has_type>
                  <crm:E55_Type rdf:about="http://vocab.getty.edu/aat/300312355">
                    <rdfs:label>accession numbers</rdfs:label>
                  </crm:E55_Type>
                </crm:P2_has_type>
                <crm:P190_has_symbolic_content>
                    <xsl:value-of select="."/>
                </crm:P190_has_symbolic_content>
            </crm:E42_Identifier>
        </crm:P1_is_identified_by>
    </xsl:if>
</xsl:template>

<xsl:template match="Alternative_number">
    <xsl:param name="uri"/>
    <xsl:choose>
        <xsl:when test="alternative_number.type = 'Jan Hulsker'">
            <crm:P1_is_identified_by>
                 <crm:E42_Identifier>
                    <xsl:attribute name="rdf:about">
                        <xsl:value-of select="$uri"/>
                        <xsl:text>#jh_number</xsl:text>
                    </xsl:attribute>
                    <crm:P2_has_type>
                      <crm:E55_Type rdf:about="https://vangoghworldwide.org/data/concept/jh_number"/>
                    </crm:P2_has_type>
                    <crm:P190_has_symbolic_content>
                        <xsl:value-of select="alternative_number"/>
                    </crm:P190_has_symbolic_content>
                </crm:E42_Identifier>
            </crm:P1_is_identified_by>
        </xsl:when>
        <xsl:when test="alternative_number.type = 'De la Faille'">
            <crm:P1_is_identified_by>
                 <crm:E42_Identifier>
                    <xsl:attribute name="rdf:about">
                        <xsl:value-of select="$uri"/>
                        <xsl:text>#f_number</xsl:text>
                    </xsl:attribute>
                    <crm:P2_has_type>
                      <crm:E55_Type rdf:about="https://vangoghworldwide.org/data/concept/f_number"/>
                    </crm:P2_has_type>
                    <crm:P190_has_symbolic_content>
                        <xsl:value-of select="alternative_number"/>
                    </crm:P190_has_symbolic_content>
                </crm:E42_Identifier>
            </crm:P1_is_identified_by>
        </xsl:when>
    </xsl:choose>
</xsl:template>


<!-- titles -->

<xsl:template match="Titel_translation/title.translation">
    <xsl:param name="uri"/>
    <xsl:if test="string(.)">
        <crm:P1_is_identified_by>
            <crm:E33_E41_Linguistic_Appellation>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="$uri"/>
                    <xsl:text>#title</xsl:text>
                </xsl:attribute>
                <crm:P2_has_type>
                  <crm:E55_Type rdf:about="http://vocab.getty.edu/aat/300404670">
                    <rdfs:label>primary name</rdfs:label>
                  </crm:E55_Type>
                </crm:P2_has_type>
                <crm:P190_has_symbolic_content>
                    <xsl:value-of select="."/>
                </crm:P190_has_symbolic_content>
                <crm:P72_has_language>
                    <crm:E56_Language rdf:about="http://vocab.getty.edu/aat/300388277">
                        <rdfs:label>English (language)</rdfs:label>
                    </crm:E56_Language>
                </crm:P72_has_language>
            </crm:E33_E41_Linguistic_Appellation>
        </crm:P1_is_identified_by>
    </xsl:if>
</xsl:template>

<xsl:template match="Title/title">
    <xsl:param name="uri"/>
    <xsl:if test="string(.)">
        <crm:P1_is_identified_by>
            <crm:E33_E41_Linguistic_Appellation>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="$uri"/>
                    <xsl:text>#titel</xsl:text>
                </xsl:attribute>
                <crm:P2_has_type>
                  <crm:E55_Type rdf:about="http://vocab.getty.edu/aat/300404670">
                    <rdfs:label>primary name</rdfs:label>
                  </crm:E55_Type>
                </crm:P2_has_type>
                <crm:P190_has_symbolic_content>
                    <xsl:value-of select="."/>
                </crm:P190_has_symbolic_content>
                <crm:P72_has_language>
                    <crm:E56_Language rdf:about="http://vocab.getty.edu/aat/300388256">
                        <rdfs:label>Dutch (language)</rdfs:label>
                    </crm:E56_Language>
                </crm:P72_has_language>
            </crm:E33_E41_Linguistic_Appellation>
        </crm:P1_is_identified_by>
    </xsl:if>
</xsl:template>

<!-- production -->
<!-- vervaardigingsdatums -->
<xsl:template match="Production_date/production.date.start">
    <xsl:choose>
        <xsl:when test="string(.)">
            <crm:P82a_begin_of_the_begin rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                <xsl:call-template name="begindateconverter">
                    <xsl:with-param name="date" select="."/>
                </xsl:call-template>
            </crm:P82a_begin_of_the_begin>
        </xsl:when>
        <xsl:otherwise>
            <crm:P82a_begin_of_the_begin rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                <xsl:call-template name="begindateconverter">
                    <xsl:with-param name="date" select="../production.date.end"/>
                </xsl:call-template>
            </crm:P82a_begin_of_the_begin>            
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="Production_date/production.date.end">
    <xsl:choose>
        <xsl:when test="string(.)">
            <crm:P82b_end_of_the_end rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                <xsl:call-template name="enddateconverter">
                    <xsl:with-param name="date" select="."/>
                </xsl:call-template>
            </crm:P82b_end_of_the_end>
        </xsl:when>
        <xsl:otherwise>
            <crm:P82b_end_of_the_end rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                <xsl:call-template name="enddateconverter">
                    <xsl:with-param name="date" select="../production.date.start"/>
                </xsl:call-template>
            </crm:P82b_end_of_the_end>         
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- creator -->
<xsl:template match="Production">
    <xsl:if test="(not(creator.qualifier)) or (creator.qualifier = '')">
        <crm:P14_carried_out_by>
            <xsl:apply-templates select='creator'/>
        </crm:P14_carried_out_by>
    </xsl:if>
    <xsl:if test="string(production.place)">
        <crm:P7_took_place_at>
            <crm:E53_Place>
                <xsl:if test="string(production.place/PIDother/PID_other_URI)">
                    <xsl:choose>
                        <xsl:when test="substring-after(production.place/PIDother/PID_other_URI, 'page/tgn')">
                            <xsl:attribute name="rdf:about">
                                <xsl:text>http://vocab.getty.edu/tgn</xsl:text>
                                <xsl:value-of select="substring-after(production.place/PIDother/PID_other_URI, 'page/tgn')"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of select="production.place/PIDother/PID_other_URI"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
                <xsl:if test="string(production.place/term)">
                    <rdfs:label>
                        <xsl:value-of select="production.place/term"/>
                    </rdfs:label>
                </xsl:if>
            </crm:E53_Place>
        </crm:P7_took_place_at>
    </xsl:if>
    <xsl:apply-templates select="../Technique"/>
</xsl:template>

<xsl:template match="creator">
    <crm:E39_Actor>
        <xsl:choose>
            <xsl:when test="string(Internet_address/url)">
                <xsl:attribute name="rdf:about">
                    <xsl:text>https://data.rkd.nl/artists</xsl:text>
                    <xsl:value-of select="substring-after(Internet_address/url, 'artists')"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise test="string(priref)">
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="$baseUri"/>
                    <xsl:text>creator/</xsl:text>
                    <xsl:value-of select="priref"/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
        <rdfs:label>
            <xsl:value-of select="name"/>
        </rdfs:label>
    </crm:E39_Actor>
</xsl:template>

<xsl:template match="Technique">
    <xsl:if test="string(technique.lref) or string(technique)">
        <crm:P32_used_general_technique>
            <crm:E55_Type>
                <xsl:if test="string(technique.lref)">
                    <xsl:attribute name="rdf:about">
                        <xsl:value-of select="$baseUri"/>
                        <xsl:text>concept/</xsl:text>
                        <xsl:value-of select="technique.lref"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="string(technique)">
                    <rdfs:label>
                        <xsl:value-of select="technique"/>
                    </rdfs:label>
                </xsl:if>
            </crm:E55_Type>
        </crm:P32_used_general_technique>
    </xsl:if>
</xsl:template>


<!-- Dimension -->
<xsl:template match="Dimension">
    <xsl:variable name="dimtype">
        <xsl:choose>
            <xsl:when test="string(dimension.type/value)">
                <xsl:value-of select="dimension.type/value"/>
            </xsl:when>
            <xsl:when test="string(dimension.type)">
                <xsl:value-of select="dimension.type"/>
            </xsl:when>
            <xsl:when test="not(string(dimension.type/value))">
                <xsl:text>dimtype_empty</xsl:text>
            </xsl:when>
            <xsl:when test="not(string(dimension.type))">
                <xsl:text>dimtype_empty</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>dimtype_error</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:if test="not($dimtype = 'dimtype_empty')">
        <crm:P43_has_dimension>
            <crm:E54_Dimension>
                <xsl:choose>
                    <xsl:when test="($dimtype = 'hoogte') or ($dimtype = 'height') or ($dimtype = 'hoogte (dagmaat)')">
                        <crm:P2_has_type>
                            <crm:E55_Type rdf:about="http://vocab.getty.edu/aat/300055644">
                                <rdfs:label>
                                    <xsl:value-of select="$dimtype"/>
                                </rdfs:label>
                            </crm:E55_Type>
                        </crm:P2_has_type>                    
                    </xsl:when>
                    <xsl:when test="($dimtype = 'breedte') or ($dimtype = 'width') or ($dimtype = 'breedte (dagmaat)')">
                        <crm:P2_has_type>
                            <crm:E55_Type rdf:about="http://vocab.getty.edu/aat/300055647">
                                <rdfs:label>
                                    <xsl:value-of select="$dimtype"/>
                                </rdfs:label>
                            </crm:E55_Type>
                        </crm:P2_has_type>                    
                    </xsl:when>
                    <xsl:when test="($dimtype = 'diepte') or ($dimtype = 'depth')">
                        <crm:P2_has_type>
                            <crm:E55_Type rdf:about="hhttp://vocab.getty.edu/aat/300072633">
                                <rdfs:label>
                                    <xsl:value-of select="$dimtype"/>
                                </rdfs:label>
                            </crm:E55_Type>
                        </crm:P2_has_type>                    
                    </xsl:when>
                    <xsl:otherwise>
                        <crm:P2_has_type>
                            <crm:E55_Type>
                                <rdfs:label>
                                    <xsl:value-of select="$dimtype"/>
                                </rdfs:label>
                            </crm:E55_Type>
                        </crm:P2_has_type>
                    </xsl:otherwise>
                </xsl:choose>
                <crm:P90_has_value rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">
                    <!--xsl:call-template name="valueconverter">
                        <xsl:with-param name="value" select="dimension.value"/>
                    </xsl:call-template-->
                    <xsl:value-of select="dimension.value"/>
                </crm:P90_has_value>
                <xsl:choose>
                    <xsl:when test="dimension.unit = 'cm' or dimension.unit/value = 'cm'">
                        <crm:P91_has_unit>
                            <crm:E58_Measurement_Unit rdf:about="http://vocab.getty.edu/aat/300379098">
                                <rdfs:label>centimeters</rdfs:label>
                            </crm:E58_Measurement_Unit>
                        </crm:P91_has_unit>
                    </xsl:when>
                    <xsl:when test="dimension.unit = 'mm' or dimension.unit/value = 'mm'">
                        <crm:P91_has_unit>
                            <crm:E58_Measurement_Unit rdf:about="http://vocab.getty.edu/aat/300379097">
                                <rdfs:label>millimeters</rdfs:label>
                            </crm:E58_Measurement_Unit>
                        </crm:P91_has_unit>
                    </xsl:when>
                    <xsl:otherwise>
                        <crm:P91_has_unit>
                            <crm:E58_Measurement_Unit>
                                <rdfs:label>
                                    <xsl:value-of select="dimension.unit"/>
                                </rdfs:label>
                            </crm:E58_Measurement_Unit>
                        </crm:P91_has_unit>
                    </xsl:otherwise>
                </xsl:choose>
            </crm:E54_Dimension>
        </crm:P43_has_dimension>
    </xsl:if>
</xsl:template>

<!-- Material -->
<xsl:template match="Material">
    <xsl:choose>
        <xsl:when test="material.part = 'medium'">
            <crm:P45_consists_of>
                <crm:E57_Material>
                    <xsl:if test="string(material/PIDother/PID_other_URI)">
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="material/PIDother/PID_other_URI"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="string(material/term)">
                        <rdfs:label>
                            <xsl:value-of select="material/term"/>
                        </rdfs:label>
                    </xsl:if>
                </crm:E57_Material>
            </crm:P45_consists_of>
        </xsl:when>
        <xsl:when test="material.part = 'drager'">
            <crm:P46_is_composed_of>
              <crm:E22_Human-Made_Object>
                <crm:P2_has_type>
                  <crm:E55_Type rdf:about="http://vocab.getty.edu/aat/300014844">
                    <rdfs:label>supports</rdfs:label>
                  </crm:E55_Type>
                </crm:P2_has_type>
                <crm:P45_consists_of>
                  <crm:E57_Material>
                    <xsl:if test="string(material/PIDother/PID_other_URI)">
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="material/PIDother/PID_other_URI"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="string(material/term)">
                        <rdfs:label>
                            <xsl:value-of select="material/term"/>
                        </rdfs:label>
                    </xsl:if>
                  </crm:E57_Material>
                </crm:P45_consists_of>
              </crm:E22_Human-Made_Object>
            </crm:P46_is_composed_of>
        </xsl:when>
    </xsl:choose>
</xsl:template>

<!-- images -->
<!-- hack voor Van Gogh World Wide, see https://github.com/vangoghworldwide/linkedart/issues/21 -->

<xsl:template match="Reproduction" mode="primaryimage">
    <xsl:variable name="img" select="translate(reproduction.reference/reference_number, ' \', '+/')"/>
    <xsl:choose>
        <xsl:when test="not(string($img))"></xsl:when>
        <xsl:when test="contains($img, '_01.tif') and contains($img, '/gecropt/')">
            <!-- primary image -->
            <crm:P138i_has_representation>
              <crm:E36_Visual_Item>
                <xsl:attribute name="rdf:about">
                    <xsl:text>https://cmu.adlibhosting.com/webapiimages/wwwopac.ashx?command=getcontent&amp;server=images&amp;value=</xsl:text>
                    <xsl:value-of select="$img"/>
                </xsl:attribute>
                <crm:P2_has_type>
                  <crm:E55_Type rdf:about="http://vocab.getty.edu/aat/300215302">
                    <rdfs:label>digital images</rdfs:label>
                  </crm:E55_Type>
                </crm:P2_has_type>
                <crm:P2_has_type>
                  <crm:E55_Type rdf:about="http://vocab.getty.edu/aat/300404450">
                    <rdfs:label>primary (general designation)</rdfs:label>
                  </crm:E55_Type>
                </crm:P2_has_type>
                <dc:format>image/tiff</dc:format>
              </crm:E36_Visual_Item>
            </crm:P138i_has_representation>
        </xsl:when>
        <xsl:otherwise>
            <!-- other images -->
            <!--crm:P138i_has_representation>
              <crm:E36_Visual_Item>
                <xsl:attribute name="rdf:about">
                    <xsl:text>https://cmu.adlibhosting.com/webapiimages/wwwopac.ashx?command=getcontent&amp;server=images&amp;value=</xsl:text>
                    <xsl:value-of select="$img"/>
                </xsl:attribute>
                <crm:P2_has_type>
                  <crm:E55_Type rdf:about="http://vocab.getty.edu/aat/300215302">
                    <rdfs:label>digital images</rdfs:label>
                  </crm:E55_Type>
                </crm:P2_has_type>
                <dc:format>image/tiff</dc:format>
              </crm:E36_Visual_Item>
            </crm:P138i_has_representation-->
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- hack voor Van Gogh World Wide: maak technische plaatjes van de rest van de plaatjes -->
<xsl:template match="Reproduction" mode="secondaryimage">
    <xsl:param name="uri"/>
    <xsl:variable name="img" select="translate(reproduction.reference/reference_number, ' \', '+/')"/>
    <xsl:choose>
        <xsl:when test="not(string($img))"></xsl:when>
        <xsl:when test="contains($img, '_01.tif') and contains($img, '/gecropt/')"></xsl:when>
        <xsl:otherwise>
            <!-- other images -->
            <crm:E22_Human-Made_Object>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="$baseUri"/>
                    <xsl:text>plaatje-</xsl:text>
                    <xsl:number/>
                </xsl:attribute>
                <crm:P2_has_type>
                    <crm:E55_Type>
                          <rdfs:label>normal lighting</rdfs:label>
                    </crm:E55_Type>
                </crm:P2_has_type>
                <crm:P108i_was_produced_by>
                    <crm:E12_Production>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="$baseUri"/>
                            <xsl:text>plaatje-</xsl:text>
                            <xsl:number/>
                            <xsl:text>#production</xsl:text>
                        </xsl:attribute>
                        <crm:P16_used_specific_object>
                            <crm:E22_Human-Made_Object>
                                <xsl:attribute name="rdf:about">
                                    <xsl:value-of select="$uri"/>
                                </xsl:attribute>
                            </crm:E22_Human-Made_Object>
                        </crm:P16_used_specific_object>            
                    </crm:E12_Production>
                </crm:P108i_was_produced_by>
                <crm:P138i_has_representation>
                    <crm:E36_Visual_Item>
                        <xsl:attribute name="rdf:about">
                            <xsl:text>https://cmu.adlibhosting.com/webapiimages/wwwopac.ashx?command=getcontent&amp;server=images&amp;value=</xsl:text>
                            <xsl:value-of select="$img"/>
                        </xsl:attribute>
                        <crm:P2_has_type>
                            <crm:E55_Type rdf:about="http://vocab.getty.edu/aat/300215302">
                                <rdfs:label>digital images</rdfs:label>
                            </crm:E55_Type>
                        </crm:P2_has_type>
                        <dc:format>image/tiff</dc:format>
                    </crm:E36_Visual_Item>
                </crm:P138i_has_representation>
            </crm:E22_Human-Made_Object>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Literature -->
<xsl:template match="Documentation">
    <crm:P67i_is_referred_to_by>
        <crm:E33_Linguistic_Object>
            <crm:P67i_is_referred_to_by>
                <crm:E33_Linguistic_Object>
                    <crm:P2_has_type>
                        <crm:E55_Type rdf:about="http://vocab.getty.edu/aat/300435440">
                            <rdfs:label>Pagination Statement</rdfs:label>
                        </crm:E55_Type>
                    </crm:P2_has_type>
                    <crm:P190_has_symbolic_content>
                        <xsl:value-of select="documentation.page_reference"/>    
                    </crm:P190_has_symbolic_content>
                </crm:E33_Linguistic_Object>
            </crm:P67i_is_referred_to_by>
            <crm:P106i_forms_part_of>
                <xsl:apply-templates select="documentation.title"/>
            </crm:P106i_forms_part_of>
        </crm:E33_Linguistic_Object>
    </crm:P67i_is_referred_to_by>
</xsl:template>


<xsl:template match="documentation.title">
    <crm:E33_Linguistic_Object>
        <xsl:attribute name="rdf:about">
            <xsl:value-of select="$baseUri"/>
            <xsl:text>documentation/</xsl:text>
            <xsl:value-of select="priref"/>
        </xsl:attribute>

        <crm:P1_is_identified_by>
            <crm:E33_E41_Linguistic_Appellation>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="$baseUri"/>
                    <xsl:text>documentation/</xsl:text>
                    <xsl:value-of select="priref"/>
                    <xsl:text>#title</xsl:text>
                </xsl:attribute>
                <crm:P190_has_symbolic_content>
                    <xsl:if test="string(Title/lead_word)">
                        <xsl:value-of select="Title/lead_word"/>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="Title/title"/>
                </crm:P190_has_symbolic_content>
            </crm:E33_E41_Linguistic_Appellation>
        </crm:P1_is_identified_by>

        <xsl:if test="string(Author)">
            <crm:P94i_was_created_by>
                <crm:E65_Creation>
                    <xsl:attribute name="rdf:about">
                        <xsl:value-of select="$baseUri"/>
                        <xsl:text>documentation/</xsl:text>
                        <xsl:value-of select="priref"/>
                        <xsl:text>#creation</xsl:text>
                    </xsl:attribute>
                    <xsl:apply-templates select="Author">
                        <xsl:with-param name="priref" select="priref"/>
                    </xsl:apply-templates>
                </crm:E65_Creation>
            </crm:P94i_was_created_by>
        </xsl:if>

            <xsl:choose>
                <xsl:when test="Source">
                    <!-- Article -->
                    <crm:P2_has_type>
                        <crm:E55_Type rdf:about="http://vocab.getty.edu/aat/300048715">
                            <rdfs:label>articles</rdfs:label>
                        </crm:E55_Type>
                    </crm:P2_has_type>
                    <crm:P106i_forms_part_of>
                        <crm:E33_Linguistic_Object>
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of select="$baseUri"/>
                                <xsl:text>documentation/</xsl:text>
                                <xsl:value-of select="priref"/>
                                <xsl:text>#journal</xsl:text>
                            </xsl:attribute>
                            <crm:P1_is_identified_by>
                                <crm:E33_E41_Linguistic_Appellation>
                                    <xsl:attribute name="rdf:about">
                                        <xsl:value-of select="$baseUri"/>
                                        <xsl:text>documentation/</xsl:text>
                                        <xsl:value-of select="priref"/>
                                        <xsl:text>#journaltitle</xsl:text>
                                    </xsl:attribute>
                                    <crm:P190_has_symbolic_content>
                                        <xsl:value-of select="Source/source.title"/>
                                    </crm:P190_has_symbolic_content>
                                </crm:E33_E41_Linguistic_Appellation>
                            </crm:P1_is_identified_by>             
                        </crm:E33_Linguistic_Object>
                    </crm:P106i_forms_part_of>
                    <crm:P16i_was_used_for>
                        <crm:E7_Activity>
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of select="$baseUri"/>
                                <xsl:text>documentation/</xsl:text>
                                <xsl:value-of select="priref"/>
                                <xsl:text>#publication</xsl:text>
                            </xsl:attribute>
                            <crm:P2_has_type>
                                <crm:E55_Type rdf:about="http://vocab.getty.edu/aat/300054686">
                                    <rdfs:label>Publishing</rdfs:label>
                                </crm:E55_Type>
                            </crm:P2_has_type>
                            <crm:P4_has_time-span>
                                <crm:E52_Time-Span>
                                    <xsl:attribute name="rdf:about">
                                        <xsl:value-of select="$baseUri"/>
                                        <xsl:text>documentation/</xsl:text>
                                        <xsl:value-of select="priref"/>
                                        <xsl:text>#publicationdate</xsl:text>
                                    </xsl:attribute>
                                    <crm:P82a_begin_of_the_begin rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                        <xsl:call-template name="begindateconverter">
                                            <xsl:with-param name="date" select="translate(Source/source.publication_years, '[]abcdefghijklmnopqrstuvwxyz.','')"/>
                                        </xsl:call-template>
                                    </crm:P82a_begin_of_the_begin>
                                    <crm:P82b_end_of_the_end rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                        <xsl:call-template name="enddateconverter">
                                            <xsl:with-param name="date" select="translate(Source/source.publication_years, '[]abcdefghijklmnopqrstuvwxyz.','')"/>
                                        </xsl:call-template>
                                    </crm:P82b_end_of_the_end>               
                                </crm:E52_Time-Span>
                            </crm:P4_has_time-span>
                        </crm:E7_Activity>
                    </crm:P16i_was_used_for>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Book -->
                    <crm:P2_has_type>
                        <crm:E55_Type rdf:about="http://vocab.getty.edu/aat/300028051">
                            <rdfs:label>books</rdfs:label>
                        </crm:E55_Type>
                    </crm:P2_has_type>
                    <crm:P16i_was_used_for>
                        <crm:E7_Activity>
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of select="$baseUri"/>
                                <xsl:text>documentation/</xsl:text>
                                <xsl:value-of select="priref"/>
                                <xsl:text>#publication</xsl:text>
                            </xsl:attribute>
                            <crm:P2_has_type>
                                <crm:E55_Type rdf:about="http://vocab.getty.edu/aat/300054686">
                                    <rdfs:label>Publishing</rdfs:label>
                                </crm:E55_Type>
                            </crm:P2_has_type>
                            <!--crm:P14_carried_out_by>
                                <crm:E39_Actor rdf:about="">
                                        <rdfs:label></rdfs:label>
                                    </crm:E39_Actor>
                            </crm:P14_carried_out_by-->
                            <crm:P4_has_time-span>
                                <crm:E52_Time-Span>
                                    <xsl:attribute name="rdf:about">
                                        <xsl:value-of select="$baseUri"/>
                                        <xsl:text>documentation/</xsl:text>
                                        <xsl:value-of select="priref"/>
                                        <xsl:text>#publicationdate</xsl:text>
                                    </xsl:attribute>
                                    <crm:P82a_begin_of_the_begin rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                        <xsl:call-template name="begindateconverter">
                                            <xsl:with-param name="date" select="translate(Publisher/year_of_publication, '[]abcdefghijklmnopqrstuvwxyz.','')"/>
                                        </xsl:call-template>
                                    </crm:P82a_begin_of_the_begin>
                                    <crm:P82b_end_of_the_end rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                        <xsl:call-template name="enddateconverter">
                                            <xsl:with-param name="date" select="translate(Publisher/year_of_publication, '[]abcdefghijklmnopqrstuvwxyz.','')"/>
                                        </xsl:call-template>
                                    </crm:P82b_end_of_the_end>               
                                </crm:E52_Time-Span>
                            </crm:P4_has_time-span>

                            <xsl:apply-templates select="Publisher/place_of_publication">
                                <xsl:with-param name="priref" select="priref"/>
                            </xsl:apply-templates>

                        </crm:E7_Activity>
                    </crm:P16i_was_used_for>

                </xsl:otherwise>
            </xsl:choose>

    </crm:E33_Linguistic_Object>

</xsl:template>

<xsl:template match="Author">
    <xsl:param name="priref"/>
    <crm:P14_carried_out_by>
        <crm:E39_Actor>
            <xsl:attribute name="rdf:about">
                <xsl:value-of select="$baseUri"/>
                <xsl:text>documentation/</xsl:text>
                <xsl:value-of select="$priref"/>
                <xsl:text>#creator</xsl:text>
                <xsl:text>-</xsl:text>
                <xsl:number/>
            </xsl:attribute>
            <rdfs:label>
                <xsl:value-of select="author.name"/>
            </rdfs:label>
        </crm:E39_Actor>
    </crm:P14_carried_out_by>
</xsl:template>

<xsl:template match="Publisher/place_of_publication">
    <xsl:param name="priref"/>
    <crm:P7_took_place_at>
        <crm:E53_Place>
            <xsl:attribute name="rdf:about">
                <xsl:value-of select="$baseUri"/>
                <xsl:text>documentation/</xsl:text>
                <xsl:value-of select="$priref"/>
                <xsl:text>#publicationplace</xsl:text>
                <xsl:text>-</xsl:text>
                <xsl:number/>
            </xsl:attribute>
            <rdfs:label>
                <xsl:value-of select="."/>
            </rdfs:label>
        </crm:E53_Place>
    </crm:P7_took_place_at>
</xsl:template>


<!-- Exhibitions -->
<xsl:template match="Exhibition/exhibition/venue">
    <xsl:variable name="uri">
        <xsl:value-of select="$baseUri"/>
        <xsl:text>exhibition/</xsl:text>
        <xsl:value-of select="../../exhibition.lref"/>
        <xsl:text>-</xsl:text>
        <xsl:number/>
    </xsl:variable>
    <crm:P16i_was_used_for>
      <crm:E7_Activity>
        <xsl:attribute name="rdf:about">
            <xsl:value-of select="$uri"/>
        </xsl:attribute>
        <crm:P2_has_type>
          <crm:E55_Type rdf:about="http://vocab.getty.edu/aat/300054766">
            <rdfs:label>exhibitions</rdfs:label>
          </crm:E55_Type>
        </crm:P2_has_type>
        <crm:P1_is_identified_by>
          <crm:E33_E41_Linguistic_Appellation>
            <xsl:attribute name="rdf:about">
                <xsl:value-of select="$uri"/>
                <xsl:text>#title</xsl:text>
            </xsl:attribute>
            <crm:P190_has_symbolic_content>
                <xsl:value-of select="../title"/>
            </crm:P190_has_symbolic_content>
          </crm:E33_E41_Linguistic_Appellation>
        </crm:P1_is_identified_by>
        <crm:P4_has_time-span>
          <crm:E52_Time-Span>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="$uri"/>
                    <xsl:text>#date</xsl:text>
                </xsl:attribute>
                <crm:P82a_begin_of_the_begin rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                    <xsl:call-template name="begindateconverter">
                        <xsl:with-param name="date" select="venue.date.start"/>
                    </xsl:call-template>
                </crm:P82a_begin_of_the_begin>
                <crm:P82b_end_of_the_end rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                    <xsl:call-template name="enddateconverter">
                        <xsl:with-param name="date" select="venue.date.end"/>
                    </xsl:call-template>
                </crm:P82b_end_of_the_end>               
          </crm:E52_Time-Span>
        </crm:P4_has_time-span>
        <crm:P7_took_place_at>
            <crm:E53_Place>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="$uri"/>
                    <xsl:text>#place</xsl:text>
                </xsl:attribute>
                <rdfs:label>
                    <xsl:value-of select="venue.place"/>
                </rdfs:label>
            </crm:E53_Place>
        </crm:P7_took_place_at>
        <crm:P14_carried_out_by>
            <crm:E39_Actor>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="$uri"/>
                    <xsl:text>#venue</xsl:text>
                </xsl:attribute>
                <rdfs:label>
                    <xsl:value-of select="venue"/>
                </rdfs:label>
            </crm:E39_Actor>
        </crm:P14_carried_out_by>
      </crm:E7_Activity>
    </crm:P16i_was_used_for>
</xsl:template>

<!-- provenance -->
<xsl:template match="owner_hist.owner">
    <xsl:param name="uri"/>
    <xsl:variable name="number">
        <!--xsl:number/-->
        <xsl:value-of select="position()"/>
    </xsl:variable>
    <crm:E7_Activity>
        <xsl:attribute name="rdf:about">
            <xsl:value-of select="$baseUri"/>
            <xsl:text>provenance/</xsl:text>
            <xsl:value-of select="$number"/>
        </xsl:attribute>
        <crm:P2_has_type>
            <crm:E55_Type rdf:about="http://vocab.getty.edu/aat/300055863">
                <rdfs:label>Provenance Entry</rdfs:label>
            </crm:E55_Type>
        </crm:P2_has_type>
        <crm:P14_carried_out_by>
          <crm:E39_Actor>
            <rdfs:label>
                <xsl:value-of select="."/>
            </rdfs:label>
          </crm:E39_Actor>
        </crm:P14_carried_out_by>
        <crm:P4_has_time-span>
            <crm:E52_Time-Span>
                <crm:P82a_begin_of_the_begin rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                    <xsl:call-template name="begindateconverter">
                        <xsl:with-param name="date" select="../owner_hist.date.start[number($number)]"/>
                    </xsl:call-template>
                </crm:P82a_begin_of_the_begin>
                <crm:P82b_end_of_the_end rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                    <xsl:call-template name="enddateconverter">
                        <xsl:with-param name="date" select="../owner_hist.date.start[number($number)]"/>
                    </xsl:call-template>
                </crm:P82b_end_of_the_end>               
            </crm:E52_Time-Span>
        </crm:P4_has_time-span>        
        <crm:P9_consists_of>
            <crm:E8_Acquisition>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="$baseUri"/>
                    <xsl:text>acquisition/</xsl:text>
                    <xsl:value-of select="$number"/>
                </xsl:attribute>
                <!--crm:P23_transferred_title_from>
                    <crm:E39_Actor>
                        <rdfs:label>
                            <xsl:value-of select="../owner_hist.owner"/>
                        </rdfs:label>
                    </crm:E39_Actor>
                </crm:P23_transferred_title_from-->
                <crm:P24_transferred_title_of>
                    <crm:E22_Human-Made_Object>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of select="$uri"/>
                        </xsl:attribute>
                    </crm:E22_Human-Made_Object>
                </crm:P24_transferred_title_of>
                <crm:P22_transferred_title_to>
                    <crm:E39_Actor>
                        <rdfs:label>
                            <xsl:value-of select="."/>
                        </rdfs:label>
                    </crm:E39_Actor>
                </crm:P22_transferred_title_to>
            </crm:E8_Acquisition>
        </crm:P9_consists_of>
    </crm:E7_Activity>
</xsl:template>



<!-- general -->
<xsl:template match="value">
    <xsl:value-of select="."/>
</xsl:template>

    <!-- ********** named templates ************** -->
    <xsl:template name="valueconverter">
        <xsl:param name="value"/>
        <xsl:choose>
            <xsl:when test="format-number(translate($value, ',.', '.'), '###0.##########') != 'NaN'">
                <!--xsl:value-of select="format-number(translate($value, ',.', '.'), '###0.##########')"/-->
                <xsl:value-of select="translate($value, ',.', '.')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>-1</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- datum conversie -->
    <xsl:template name="begindateconverter">
        <xsl:param name="date"/>
        <xsl:choose>
            <xsl:when test="(number($date) &gt; 0) and (number($date) &lt; 9999)">
                <xsl:value-of select="$date"/>
                <xsl:text>-01-01T00:00:00</xsl:text>
            </xsl:when>
            <xsl:when test="(number(substring-before($date,'-')) &lt; 9999) and not(contains(substring-after($date,'-'),'-'))">
                <xsl:value-of select="$date"/>
                <xsl:text>-01T00:00:00</xsl:text>
            </xsl:when>
            <xsl:when test="(number(substring-before($date,'-')) &lt; 9999) and contains(substring-after($date,'-'),'-')">
                <xsl:value-of select="$date"/>
                <xsl:text>T00:00:00</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text></xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="enddateconverter">
        <xsl:param name="date"/>
        <xsl:choose>
            <xsl:when test="(number($date) &gt; 0) and (number($date) &lt; 9999)">
                <xsl:value-of select="$date"/>
                <xsl:text>-12-31T23:59:59</xsl:text>
            </xsl:when>
            <xsl:when test="(number(substring-before($date,'-')) &lt; 9999) and (substring-after($date,'-') = '01')">
                <xsl:value-of select="$date"/>
                <xsl:text>-31T23:59:59</xsl:text>
            </xsl:when>
            <xsl:when test="(number(substring-before($date,'-')) &lt; 9999) and (substring-after($date,'-') = '02')">
                <xsl:value-of select="$date"/>
                <xsl:text>-28T23:59:59</xsl:text>
            </xsl:when>
            <xsl:when test="(number(substring-before($date,'-')) &lt; 9999) and (substring-after($date,'-') = '03')">
                <xsl:value-of select="$date"/>
                <xsl:text>-31T23:59:59</xsl:text>
            </xsl:when>
            <xsl:when test="(number(substring-before($date,'-')) &lt; 9999) and (substring-after($date,'-') = '04')">
                <xsl:value-of select="$date"/>
                <xsl:text>-30T23:59:59</xsl:text>
            </xsl:when>
            <xsl:when test="(number(substring-before($date,'-')) &lt; 9999) and (substring-after($date,'-') = '05')">
                <xsl:value-of select="$date"/>
                <xsl:text>-31T23:59:59</xsl:text>
            </xsl:when>
            <xsl:when test="(number(substring-before($date,'-')) &lt; 9999) and (substring-after($date,'-') = '06')">
                <xsl:value-of select="$date"/>
                <xsl:text>-30T23:59:59</xsl:text>
            </xsl:when>
            <xsl:when test="(number(substring-before($date,'-')) &lt; 9999) and (substring-after($date,'-') = '07')">
                <xsl:value-of select="$date"/>
                <xsl:text>-31T23:59:59</xsl:text>
            </xsl:when>
            <xsl:when test="(number(substring-before($date,'-')) &lt; 9999) and (substring-after($date,'-') = '08')">
                <xsl:value-of select="$date"/>
                <xsl:text>-31T23:59:59</xsl:text>
            </xsl:when>
            <xsl:when test="(number(substring-before($date,'-')) &lt; 9999) and (substring-after($date,'-') = '09')">
                <xsl:value-of select="$date"/>
                <xsl:text>-30T23:59:59</xsl:text>
            </xsl:when>
            <xsl:when test="(number(substring-before($date,'-')) &lt; 9999) and (substring-after($date,'-') = '10')">
                <xsl:value-of select="$date"/>
                <xsl:text>-31T23:59:59</xsl:text>
            </xsl:when>
            <xsl:when test="(number(substring-before($date,'-')) &lt; 9999) and (substring-after($date,'-') = '11')">
                <xsl:value-of select="$date"/>
                <xsl:text>-30T23:59:59</xsl:text>
            </xsl:when>
            <xsl:when test="(number(substring-before($date,'-')) &lt; 9999) and (substring-after($date,'-') = '12')">
                <xsl:value-of select="$date"/>
                <xsl:text>-31T23:59:59</xsl:text>
            </xsl:when>
            <xsl:when test="(number(substring-before($date,'-')) &lt; 9999) and contains(substring-after($date,'-'),'-')">
                <xsl:value-of select="$date"/>
                <xsl:text>T23:59:59</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text></xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
