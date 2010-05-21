<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:d-xsl="bem-b:xsl:dynamic"
    xmlns:d2-xsl="bem-b:xsl:dynamic-2"
    xmlns:bb="bem-b"
    xmlns:tb="bem-b:template:block"
    xmlns:te="bem-b:template:elem"
    xmlns:tm="bem-b:template:mod"
    xmlns:mode="bem-b:template:mode"
    xmlns:m="bem-b:mod"
    xmlns:str="http://exslt.org/strings"
    xmlns:exslt="http://exslt.org/common"
    extension-element-prefixes="bb str">

    <xsl:output
        encoding="UTF-8"
        method="xml"
        indent="yes"
    />

    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="xsl:text"/>

    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="." mode="attributes"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*" mode="attributes">
        <xsl:for-each select="@*">
            <xsl:attribute name="{name()}">
                <xsl:apply-templates select="."/>
            </xsl:attribute>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="xsl:stylesheet">
        <xsl:copy>
            <xsl:apply-templates select="." mode="attributes"/>
            <xsl:attribute name="exslt:bla">bla</xsl:attribute>
            <xsl:attribute name="d-xsl:bla">bla</xsl:attribute>
            <xsl:attribute name="d2-xsl:bla">bla</xsl:attribute>
            <xsl:attribute name="tb:bla">bla</xsl:attribute>
            <xsl:attribute name="te:bla">bla</xsl:attribute>
            <xsl:attribute name="tm:bla">bla</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xsl:stylesheet/@extension-element-prefixes">
        <xsl:value-of select="."/>
        <xsl:text> exslt</xsl:text>
    </xsl:template>

    <xsl:template match="xsl:stylesheet/@exclude-result-prefixes">
        <xsl:value-of select="."/>
        <xsl:text> tb te tm d2-xsl exslt</xsl:text>
    </xsl:template>

    <xsl:template match="xsl:comment">
        <xsl:element name="{concat('d-xsl:', local-name())}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="xsl:text/text()">
        <xsl:value-of select="str:replace(str:replace(., '}', '}}'), '{', '{{')"/>
    </xsl:template>

    <xsl:template match="xsl:template">
        <xsl:copy>
            <xsl:apply-templates select="." mode="attributes"/>
            <xsl:element name="xsl:choose">
                <xsl:element name="xsl:when">
                    <xsl:attribute name="test">not(descendant::xsl:* | descendant::d-xsl:*)</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
                <xsl:element name="xsl:when">
                    <xsl:attribute name="test">
                        <xsl:text>(self::b:* | self::e:*) and </xsl:text>
                        <xsl:text>@xsl-inline = 'yes' and </xsl:text>
                        <xsl:text>descendant::xsl:*[</xsl:text>
                            <xsl:text>self::xsl:apply-imports | </xsl:text>
                            <xsl:text>self::xsl:apply-templates | </xsl:text>
                            <xsl:text>self::xsl:call-template | </xsl:text>
                            <xsl:text>self::xsl:for-each | </xsl:text>
                            <xsl:text>self::xsl:attribute | </xsl:text>
                            <xsl:text>self::xsl:element | </xsl:text>
                            <xsl:text>self::xsl:copy | </xsl:text>
                            <xsl:text>self::xsl:copy-of | </xsl:text>
                            <xsl:text>self::xsl:value-of | </xsl:text>
                            <xsl:text>self::xsl:choose | </xsl:text>
                            <xsl:text>self::xsl:if | </xsl:text>
                            <xsl:text>self::xsl:number]</xsl:text>
                    </xsl:attribute>
                    <xsl:apply-templates mode="xsl-inline"/>
                </xsl:element>
                <xsl:element name="xsl:otherwise">
                    <xsl:apply-templates mode="d-xsl"/>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*" mode="d-xsl">
        <xsl:copy>
            <xsl:apply-templates select="." mode="attributes"/>
            <xsl:apply-templates mode="d-xsl"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xsl:*" mode="d-xsl">
        <xsl:element name="{concat('d-xsl:', local-name())}">
            <xsl:apply-templates select="@*" mode="d-xsl"/>
            <xsl:apply-templates mode="d-xsl"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@*" mode="d-xsl">
        <xsl:attribute name="{name()}">
            <xsl:value-of select="str:replace(str:replace(., '}', '}}'), '{', '{{')"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="*" mode="xsl-inline">
        <xsl:copy>
            <xsl:apply-templates select="." mode="attributes"/>
            <xsl:apply-templates mode="xsl-inline"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xsl:*" mode="xsl-inline">
        <xsl:element name="{concat('d-xsl:', local-name())}">
            <xsl:apply-templates select="@*" mode="d-xsl"/>
            <xsl:apply-templates mode="xsl-inline"/>
        </xsl:element>
    </xsl:template>

    <!-- TODO: with-params -->
    <xsl:template match="xsl:apply-templates" mode="xsl-inline">
        <xsl:copy>
            <xsl:apply-templates select="." mode="attributes"/>
            <xsl:apply-templates mode="xsl-inline"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
