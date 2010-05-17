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
            <xsl:for-each select="@*">
                <xsl:attribute name="{name()}">
                    <xsl:apply-templates select="."/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="xsl:stylesheet">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:attribute name="{name()}">
                    <xsl:apply-templates select="."/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:attribute name="exslt:bla">bla</xsl:attribute>
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

    <xsl:template match="d-xsl:*[not(self::d-xsl:comment | self::d-xsl:value-of)]">
        <xsl:variable name="uniq" select="generate-id()"/>
        <xsl:element name="xsl:variable">
            <xsl:attribute name="name">var-<xsl:value-of select="$uniq"/>-tmp</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
        <xsl:element name="xsl:variable">
            <xsl:attribute name="name">var-<xsl:value-of select="$uniq"/>-nodes</xsl:attribute>
            <xsl:attribute name="select">exslt:node-set($var-<xsl:value-of select="$uniq"/>-tmp)</xsl:attribute>
        </xsl:element>
        <xsl:element name="xsl:choose">
            <xsl:element name="xsl:when">
                <xsl:attribute name="test">
                    $var-<xsl:value-of select="$uniq"/>-nodes//d-xsl:* |
                    $var-<xsl:value-of select="$uniq"/>-nodes//d2-xsl:*
                </xsl:attribute>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:element name="xsl:copy-of">
                        <xsl:attribute name="select">$var-<xsl:value-of select="$uniq"/>-nodes</xsl:attribute>
                    </xsl:element>
                </xsl:copy>
            </xsl:element>
            <xsl:element name="xsl:otherwise">
                <xsl:element name="{concat('xsl:', local-name())}">
                    <xsl:copy-of select="@*"/>
                    <xsl:element name="xsl:copy-of">
                        <xsl:attribute name="select">$var-<xsl:value-of select="$uniq"/>-nodes</xsl:attribute>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="xsl:text/text()">
        <xsl:value-of select="str:replace(str:replace(., '}', '}}'), '{', '{{')"/>
    </xsl:template>

</xsl:stylesheet>
