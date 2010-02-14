<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:x="http://www.yandex.ru/xscript"
    xmlns:b="b"
    extension-element-prefixes="x"
    >

    <xsl:template match="b:block | b:elem">
        <xsl:variable name="node-name">
            <xsl:apply-templates select="." mode="b:node-name"/>
        </xsl:variable>
        <xsl:element name="{$node-name}">
            <xsl:apply-templates select="." mode="b:css-class"/>
            <xsl:apply-templates select="." mode="b:onclick"/>
            <xsl:apply-templates select="." mode="b:content"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="b:block | b:elem" mode="b:css-class">
        <xsl:attribute name="class">
            <xsl:apply-templates select=". | b:mix" mode="b:css-class-content"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="b:block" mode="b:css-class-content">
        <xsl:variable name="css-class" select="concat('b-', @name)"/>
        <xsl:value-of select="$css-class"/>
        <xsl:apply-templates select="b:mod" mode="b:css-class-content">
            <xsl:with-param name="prefix" select="$css-class"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="b:elem" mode="b:css-class-content">
        <xsl:variable name="css-class" select="concat('b-', @block, '__', @name)"/>
        <xsl:value-of select="$css-class"/>
        <xsl:apply-templates select="b:mod" mode="b:css-class-content">
            <xsl:with-param name="prefix" select="$css-class"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="b:mod" mode="b:css-class-content">
        <xsl:param name="prefix"/>
        <xsl:value-of select="concat(' ', $prefix, '_', @name, '_', @val)"/>
    </xsl:template>

    <xsl:template match="b:mix" mode="b:css-class-content">
        <xsl:for-each select="b:block | b:elem">
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="." mode="b:css-class-content"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="b:block | b:elem" mode="b:onclick">
        <xsl:variable name="nodes" select="self::b:block | b:mix/b:block"/>
        <xsl:if test="$nodes">
            <xsl:attribute name="onclick">
                <xsl:text>return {</xsl:text>
                    <xsl:for-each select="$nodes">
                        <xsl:if test="position() - 1">,</xsl:if>
                        <xsl:value-of select="concat(&quot;'&quot;, @name, &quot;':&quot;)"/>
                        <xsl:text>{</xsl:text>
                        <xsl:apply-templates select="." mode="b:js-params-content"/>
                        <xsl:text>}</xsl:text>
                    </xsl:for-each>
                <xsl:text>}</xsl:text>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <xsl:template match="b:block" mode="b:js-params-content"/>

    <xsl:template match="b:block | b:elem" mode="b:node-name">div</xsl:template>

    <xsl:template match="b:block | b:elem" mode="b:content">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="b:mod | b:data | b:mix"/>

</xsl:stylesheet>
