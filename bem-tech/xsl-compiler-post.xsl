<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:d-xsl="bem-b:xsl:dynamic"
    xmlns:d2-xsl="bem-b:xsl:dynamic-2"
    xmlns:bb="bem-b"
    xmlns:tb="bem-b:template:block"
    xmlns:te="bem-b:template:elem"
    xmlns:tm="bem-b:template:mod"
    xmlns:mode="bem-b:template:mode"
    xmlns:str="http://exslt.org/strings"
    xmlns:exslt="http://exslt.org/common"
    exclude-result-prefixes="tb te tm d2-xsl d-xsl exslt str">

    <xsl:output
        encoding="UTF-8"
        method="xml"
        indent="yes"
    />

    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="xsl:text"/>

    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:copy>
            <xsl:value-of select="."/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="d2-xsl:*">
        <xsl:element name="{concat('xsl:', local-name())}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[d-xsl:attribute | d2-xsl:attribute]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="d-xsl:attribute[not(*)] | d2-xsl:attribute[not(*)]"/>
            <xsl:apply-templates select="*[not(self::d-xsl:attribute[not(*)] | self::d2-xsl:attribute[not(*)])]"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="d-xsl:attribute[not(*)] | d2-xsl:attribute[not(*)]">
        <xsl:attribute name="{@name}">
            <xsl:value-of select="str:replace(str:replace(., '}', '}}'), '{', '{{')"/>
        </xsl:attribute>
    </xsl:template>


</xsl:stylesheet>
