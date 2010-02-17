<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:bb="bem-b"
    xmlns:tb="bem-b:template:block"
    xmlns:te="bem-b:template:elem"
    xmlns:tm="bem-b:template:mod"
    xmlns:mode="bem-b:template:mode"
    xmlns:b="bem-b:block"
    xmlns:e="bem-b:elem"
    xmlns:m="bem-b:mod"
    xmlns:mix="bem-b:mix"
    >

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

    <xsl:template match="tb:* | te:* | tm:*">
        <xsl:apply-templates select=".//mode:* | xsl:template | xsl:variable"/>
    </xsl:template>

    <xsl:template match="mode:*">
        <xsl:element name="xsl:template">
            <xsl:attribute name="match">
                <xsl:apply-templates select="." mode="match-content"/>
            </xsl:attribute>
            <xsl:if test="local-name() != 'default'">
                <xsl:attribute name="mode">
                    <xsl:text>bb:</xsl:text>
                    <xsl:value-of select="local-name()"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mode:*" mode="match-content">
        <xsl:variable name="node" select="ancestor::*[self::tb:* | self::te:*][1]"/>
        <xsl:value-of select="substring-after(name($node), 't')"/>
        <!-- если мы не в корне блока, нужен предикат -->
        <xsl:if test="ancestor::te:* | ancestor::tm:*">
            <xsl:text>[</xsl:text>

            <xsl:variable name="mod" select="ancestor::tm:*[1]"/>
            <xsl:variable name="elem" select="ancestor::te:*[1]"/>

            <!-- модификатор блока -->
            <!-- b:myblock[@m:mod1 = 'val1'] -->
            <xsl:if test="$mod and not($elem)">
                <xsl:text>@m:</xsl:text>
                <xsl:value-of select="local-name($mod)"/>
                <xsl:text>='</xsl:text>
                <xsl:value-of select="$mod/@val"/>
                <xsl:text>'</xsl:text>
            </xsl:if>

            <!-- элемент блока -->
            <!-- e:myelem[@b = 'myblock'] -->
            <xsl:if test="$elem and not($mod)">
                <xsl:text>@b='</xsl:text>
                <xsl:value-of select="local-name(ancestor::tb:*[1])"/>
                <xsl:text>'</xsl:text>
            </xsl:if>

            <!-- элемент блока с модификатором -->
            <!-- элемент c модификатором -->
            <!-- элемент c модификатором блока с модификатором -->

            <xsl:text>]</xsl:text>
        </xsl:if>
        <xsl:value-of select="@match"/>
    </xsl:template>

</xsl:stylesheet>
