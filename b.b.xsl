<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:bb="bem-b"
    xmlns:b="bem-b:block"
    xmlns:e="bem-b:elem"
    xmlns:m="bem-b:mod"
    xmlns:mix="bem-b:mix">

    <xsl:template match="b:* | e:*">
        <xsl:variable name="tag">
            <xsl:apply-templates select="." mode="bb:tag"/>
        </xsl:variable>
        <xsl:element name="{$tag}">
            <xsl:apply-templates select="." mode="bb:css-class"/>
            <xsl:apply-templates select="." mode="bb:onclick"/>
            <xsl:apply-templates select="." mode="bb:content"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="b:* | e:*" mode="bb:css-class">
        <xsl:attribute name="class">
            <xsl:apply-templates select=". | mix:mix" mode="bb:css-class-content"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="b:*" mode="bb:css-class-content">
        <xsl:variable name="css-class" select="concat('bb-', local-name())"/>
        <xsl:value-of select="$css-class"/>
        <xsl:apply-templates select="@*" mode="bb:css-class-content">
            <xsl:with-param name="prefix" select="$css-class"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="e:*" mode="bb:css-class-content">
        <xsl:variable name="block">
            <xsl:choose>
                <xsl:when test="@b">
                    <xsl:value-of select="@b"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="local-name(ancestor::b:*[1])"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="css-class" select="concat('bb-', $block, '__', local-name())"/>
        <xsl:value-of select="$css-class"/>
        <xsl:apply-templates select="@*" mode="bb:css-class-content">
            <xsl:with-param name="prefix" select="$css-class"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="@*" mode="bb:css-class-content"/>
    <xsl:template match="@m:*" mode="bb:css-class-content">
        <xsl:param name="prefix"/>
        <xsl:value-of select="concat(' ', $prefix, '_', local-name(), '_', .)"/>
    </xsl:template>

    <xsl:template match="mix:mix" mode="bb:css-class-content">
        <xsl:for-each select="b:* | e:*">
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="." mode="bb:css-class-content"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="b:* | e:*" mode="bb:onclick">
        <xsl:variable name="nodes" select="self::b:* | mix:mix/b:*"/>
        <xsl:if test="$nodes">
            <xsl:attribute name="onclick">
                <xsl:text>return {</xsl:text>
                    <xsl:for-each select="$nodes">
                        <xsl:if test="position() - 1">,</xsl:if>
                        <xsl:value-of select="concat(&quot;'&quot;, local-name(), &quot;':&quot;)"/>
                        <xsl:text>{</xsl:text>
                        <xsl:apply-templates select="." mode="bb:js-params-content"/>
                        <xsl:text>}</xsl:text>
                    </xsl:for-each>
                <xsl:text>}</xsl:text>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <xsl:template match="b:*" mode="bb:js-params-content"/>

    <xsl:template match="b:* | e:*" mode="bb:tag">div</xsl:template>
    <xsl:template match="b:*[@tag] | e:*[@tag]" mode="bb:tag"><xsl:value-of select="@tag"/></xsl:template>

    <xsl:template match="b:* | e:*" mode="bb:content">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="mix:mix"/>

</xsl:stylesheet>
