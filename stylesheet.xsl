<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
    <!-- 
    Notes:
        originally-created-by: MJS (matthew.south@psych.ox.ac.uk)
        modifications-by: JTC (joel.collins@renalregistry.nhs.uk)
        created-on: 1st May 2015
        modified-on: 25th May 2021
    -->
    <xsl:template match="/xs:schema">
        <html>
            <head>
                <title>UKRDC data schema</title>
                <style>
                    body {
                        margin: 0;
                        font-family: Helvetica, Arial, Sans-Serif;
                        font-size: 14px;
                    }
                    .restriction {
                        color: darkred;
                    }
                    .documentation {
                        color: grey;
                    }
                    .childrefs {
                        background-color: #EEE;
                    }
                    .parentref {
                        background-color: #DDD;
                    }
                    table {
                        border-spacing: 0;
                        border-collapse:collapse
                    }
                    td, th {
                        padding:0
                    }
                    td {
                        border: 2px solid #b0b0b0;
                        padding: 8px !important;
                    }
                    table, th, td {
                        margin-top: 2px;
                        font-size: 12px !important;
                    }
                </style>
            </head>
            <body>
                <h4>Types</h4>
                <ul>
                    <xsl:for-each select="xs:complexType | xs:simpleType">
                        <xsl:sort select="@name" />
                        <li><xsl:call-template name="link" /></li>
                    </xsl:for-each>
                </ul>

                <!-- show detail -->
                <xsl:if test="xs:simpleType">
                    <h4>Simple Types</h4>
                    <xsl:for-each select="xs:simpleType">
                        <xsl:apply-templates select="." />
                        <br/>
                    </xsl:for-each>
                </xsl:if>

                <xsl:if test="xs:complexType or xs:element/xs:complexType">
                    <h4>Complex Types</h4>
                </xsl:if>  

                <xsl:for-each select="xs:element">
                    <xsl:for-each select="xs:complexType">
                        <xsl:apply-templates select="." />
                        <br/>
                    </xsl:for-each>
                </xsl:for-each>
                
                <xsl:for-each select="xs:complexType">
                    <xsl:apply-templates select="." />
                    <br/>
                </xsl:for-each>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="link">
        <a href="{concat('#',@name)}">
            <xsl:value-of select="@name" />
        </a>
    </xsl:template>

    <!-- Found under xs:complexType, xs:element, xs:attribute -->
    <xsl:template match="xs:annotation/xs:documentation">
        <div class="documentation">
            <xsl:value-of select="." />
        </div>
    </xsl:template>

    <!-- Found under xs:element or xs:attribute -->
    <xsl:template name="restriction">
        <xsl:apply-templates select="xs:simpleType/xs:restriction"/>
    </xsl:template>

    <!-- Found under xs:element or xs:attribute -->
    <xsl:template match="xs:simpleType/xs:restriction">
        <xsl:value-of select="@base" />
        (restricted)
        <xsl:if test="xs:maxLength">
            <div class="restriction">
                maxLength:
                <xsl:value-of select="xs:maxLength/@value" />
            </div>
        </xsl:if>
        <xsl:if test="xs:enumeration">
            <div class="restriction">
                Enumeration:
                <ul>
                <xsl:for-each select="xs:enumeration">
                    <li><xsl:value-of select="@value" /> (<xsl:value-of select="xs:annotation/xs:documentation" />)</li>
                </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
        <xsl:if test="xs:minInclusive or xs:maxInclusive">
            <div class="restriction">
                value:
                <xsl:choose>
                    <xsl:when test="s:minInclusive and xs:simpleType/xs:restriction/xs:maxInclusive">
                        &gt;=
                        <xsl:value-of select="xs:minInclusive/@value" />
                        , &lt;=
                        <xsl:value-of select="xs:maxInclusive/@value" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="xs:minInclusive">
                            &gt;=
                            <xsl:value-of select="xs:minInclusive/@value" />
                        </xsl:if>
                        <xsl:if test="xs:maxInclusive">
                            &lt;=
                            <xsl:value-of select="xs:maxInclusive/@value" />
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="xs:attribute">
        <tr>
            <td colspan="2">
                <xsl:choose>
                    <xsl:when test="@use='required'">
                        <strong>
                            @
                            <xsl:value-of select="@name" />
                        </strong>
                    </xsl:when>
                    <xsl:otherwise>
                        @
                        <xsl:value-of select="@name" />
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <td>
                <xsl:apply-templates select="xs:annotation/xs:documentation" />
                <xsl:choose>
                    <xsl:when test="@type">
                        <xsl:value-of select="@type" />
                    </xsl:when>
                    <xsl:when test="xs:simpleType/xs:restriction">
                        <xsl:call-template name="restriction" />
                    </xsl:when>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>

    <xsl:template name="general-link">
        <xsl:choose>
            <xsl:when test="not(starts-with(@base, 'xs:'))">
                <a href="{concat('#',@base)}">
                    <xsl:value-of select="@base" />
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@base" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*/xs:extension">
        <TR class="parentref">
            <TD colspan="3">
                <em>
                    extends
                    <xsl:call-template name="general-link" />
                </em>
            </TD>
        </TR>
        <xsl:apply-templates select="xs:attribute" />
        <xsl:apply-templates select="xs:sequence" />
    </xsl:template>

    <xsl:template name="extended-by">
        <xsl:variable name="nametomatch" select="@name" />
        <xsl:if test="count(//xs:extension[contains(@base,$nametomatch)])>0">
            <TR class="childrefs">
                <TD colspan="3">
                    extended by:
                    <xsl:for-each select="//xs:extension[contains(@base,$nametomatch)]">
                        <a href="{concat('#',../../@name)}">
                            <xsl:value-of select="../../@name" />
                        </a>
                        <xsl:if test="position()!=last()">, </xsl:if>
                    </xsl:for-each>
                </TD>
            </TR>
        </xsl:if>
    </xsl:template>

    <xsl:template name="elementType">
        <xsl:choose>
            <xsl:when test="@minOccurs=0">
                <xsl:value-of select="@name" />
            </xsl:when>
            <xsl:otherwise>
                <strong>
                    <xsl:value-of select="@name" />
                </strong>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@maxOccurs='unbounded'">
            <xsl:text>*</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template name="elementContent">
        <xsl:apply-templates select="xs:annotation/xs:documentation" />
        <xsl:choose>
            <xsl:when test="@type">
                <xsl:choose>
                    <xsl:when test="starts-with(@type, 'xnat:')">
                        <a href="{concat('#', @type)}">
                            <xsl:value-of select="@type" />
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@type" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="xs:simpleType/xs:restriction">
                <xsl:call-template name="restriction" />
            </xsl:when>
            <xsl:when test="xs:complexType">
                <xsl:apply-templates select="xs:complexType" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="xs:sequence">
        <xsl:apply-templates select="xs:element | xs:choice" />
    </xsl:template>

    <xsl:template match="xs:choice">
        <xsl:for-each select="xs:element">
            <tr>
                <xsl:attribute name="position" select="position()" />
                <xsl:if test="position()=1">
                    <td>
                        <xsl:attribute name="rowspan" select="count(../xs:element)" />
                        <xsl:choose>
                            <xsl:when test="@minOccurs=0">&lt;</xsl:when>
                            <xsl:otherwise>
                                <strong>&lt;</strong>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </xsl:if>
                <td>
                    <xsl:value-of select="@name" />
                </td>
                <td>
                    <xsl:call-template name="elementContent" />
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="xs:element">
        <tr>
            <td colspan="2">
                <xsl:call-template name="elementType" />
            </td>
            <td>
                <xsl:call-template name="elementContent" />
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="xs:complexType">
        <table border="1" cellspacing="0" cellpadding="4">
            <xsl:if test="@name">
                <tr bgcolor="#CCC">
                    <td colspan="3">
                        <a name="{@name}">
                            <xsl:value-of select="@name" />
                        </a>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="xs:annotation/xs:documentation">
                <tr>
                    <td colspan="3" class="documentation">
                        <xsl:value-of select="xs:annotation/xs:documentation" />
                    </td>
                </tr>
            </xsl:if>
            <xsl:apply-templates select="*/xs:extension" />
            <xsl:if test="@name">
                <xsl:call-template name="extended-by" />
            </xsl:if>
            <xsl:apply-templates select="xs:attribute" />
            <xsl:apply-templates select="xs:sequence" />
        </table>
    </xsl:template>

    <xsl:template match="xs:simpleType">
        <table border="1" cellspacing="0" cellpadding="4">
            <xsl:if test="@name">
                <tr bgcolor="#CCC">
                    <td colspan="3">
                        <a name="{@name}">
                            <xsl:value-of select="@name" />
                        </a>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="xs:annotation/xs:documentation">
                <tr>
                    <td colspan="3" class="documentation">
                        <xsl:value-of select="xs:annotation/xs:documentation" />
                    </td>
                </tr>
            </xsl:if>

            <xsl:if test="xs:restriction">
                <tr>
                    <td>
                        <xsl:apply-templates select="xs:restriction"/>
                    </td>
                </tr>
            </xsl:if>

        </table>

    </xsl:template>

</xsl:stylesheet>
