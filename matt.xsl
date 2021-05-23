<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
    <!-- 
    Notes:
        created-by: MJS (matthew.south@psych.ox.ac.uk)
        created-on: 1st May 2015
        Need to insert this line to 2nd line of xnat schema to instruct XSLT Processor:
        <?xml-stylesheet type="text/xsl" href="[insert-url]/schema-heirarchy.xslt"?>
    todo:
        provide option to show xdat database mapping annotations?
    -->
    <xsl:template match="/xs:schema">
        <html>
            <head>
                <title>UKRDC data schema</title>
                <style>
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
                    table, th, td {
                        border: 2px solid grey;
                        padding: 8px !important;
                        margin-top: 2px;
                        font-size: 12px !important;
                    }
                </style>
                <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css" />
            </head>
            <body>
                <h4>Types</h4>
                <xsl:for-each select="xs:complexType">
                    <xsl:sort select="@name" />
                    <xsl:call-template name="link" />
                </xsl:for-each>

                <!-- show detail -->

                <xsl:for-each select="xs:element">
                    <xsl:for-each select="xs:complexType">
                        <xsl:apply-templates select="." />
                        <hr />
                    </xsl:for-each>
                </xsl:for-each>

                <hr />
                
                <xsl:for-each select="xs:complexType">
                    <xsl:apply-templates select="." />
                    <hr />
                </xsl:for-each>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="link">
        <a>
            <xsl:attribute name="href" select="concat('#xnat:',@name)" />
            <xsl:value-of select="@name" />
        </a>
        <xsl:text></xsl:text>
    </xsl:template>

    <!-- Found under xs:complexType, xs:element, xs:attribute -->
    <xsl:template match="xs:annotation/xs:documentation">
        <div class="documentation">
            <xsl:value-of select="." />
        </div>
    </xsl:template>

    <!-- Found under xs:element or xs:attribute -->
    <xsl:template name="restriction">
        <xsl:value-of select="xs:simpleType/xs:restriction/@base" />
        (restricted)
        <xsl:if test="xs:simpleType/xs:restriction/xs:maxLength">
            <div class="restriction">
                maxLength:
                <xsl:value-of select="xs:simpleType/xs:restriction/xs:maxLength/@value" />
            </div>
        </xsl:if>
        <xsl:if test="xs:simpleType/xs:restriction/xs:enumeration">
            <div class="restriction">
                Enumeration:
                <ul>
                <xsl:for-each select="xs:simpleType/xs:restriction/xs:enumeration">
                    <li><xsl:value-of select="@value" /> (<xsl:value-of select="xs:annotation/xs:documentation" />)</li>
                </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
        <xsl:if test="xs:simpleType/xs:restriction/xs:minInclusive or xs:simpleType/xs:restriction/xs:maxInclusive">
            <div class="restriction">
                value:
                <xsl:choose>
                    <xsl:when test="xs:simpleType/xs:restriction/xs:minInclusive and xs:simpleType/xs:restriction/xs:maxInclusive">
                        &gt;=
                        <xsl:value-of select="xs:simpleType/xs:restriction/xs:minInclusive/@value" />
                        , &lt;=
                        <xsl:value-of select="xs:simpleType/xs:restriction/xs:maxInclusive/@value" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="xs:simpleType/xs:restriction/xs:minInclusive">
                            &gt;=
                            <xsl:value-of select="xs:simpleType/xs:restriction/xs:minInclusive/@value" />
                        </xsl:if>
                        <xsl:if test="xs:simpleType/xs:restriction/xs:maxInclusive">
                            &lt;=
                            <xsl:value-of select="xs:simpleType/xs:restriction/xs:maxInclusive/@value" />
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
            <xsl:when test="starts-with(@base, 'xnat:')">
                <a>
                    <xsl:attribute name="href" select="concat('#',@base)" />
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
                        <a>
                            <xsl:attribute name="href" select="concat('#xnat:',../../@name)" />
                            xnat:
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
                        <a>
                            <xsl:attribute name="href" select="concat('#', @type)" />
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
                        <a>
                            <xsl:attribute name="name" select="concat('xnat:', @name)" />
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
</xsl:stylesheet>
