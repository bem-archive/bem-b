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
    xmlns:func="http://exslt.org/functions"
    extension-element-prefixes="func"
    exclude-result-prefixes="tb te tm mode">

    <xsl:output
        encoding="UTF-8"
        method="text"
    />

    <xsl:param name="output" slect="'json'"/>

    <xsl:key name="blocks" match="b:* | tb:* | e:*[@b]" use="bb:block-full-name(.)"/>
    <xsl:key name="elems" match="e:* | te:*" use="bb:item-full-name(.)"/>
    <xsl:key name="mods" match="*[self::b:* | self::e:*]/@*[bb:is-mod(.)] | tm:*" use="bb:mod-full-name(.., .)"/>
    <xsl:key name="vals" match="*[self::b:* | self::e:*]/@*[bb:is-mod(.)] | tm:*" use="bb:val-full-name(.., .)"/>

    <func:function name="bb:block-full-name">
        <xsl:param name="block"/>
        <xsl:choose>
            <xsl:when test="bb:is-block($block)">
                <func:result select="local-name($block)"/>
            </xsl:when>
            <xsl:when test="$block[self::e:*[@b]]">
                <func:result select="$block/@b"/>
            </xsl:when>
            <xsl:otherwise>
                <func:result select="$block"/>
            </xsl:otherwise>
        </xsl:choose>
    </func:function>

    <func:function name="bb:elem-full-name">
        <xsl:param name="block"/>
        <xsl:param name="node"/>
        <func:result select="concat(bb:block-full-name($block), '__', local-name($node))"/>
    </func:function>

    <func:function name="bb:item-full-name">
        <xsl:param name="node"/>
        <xsl:choose>
            <xsl:when test="bb:is-block($node)">
                <func:result select="bb:block-full-name($node)"/>
            </xsl:when>
            <xsl:otherwise>
                <func:result select="bb:elem-full-name(
                    $node/@b | $node/ancestor::*[not($node/@b) and bb:is-block(.)][1],
                    $node)"/>
            </xsl:otherwise>
        </xsl:choose>
    </func:function>

    <func:function name="bb:mod-full-name">
        <xsl:param name="item"/>
        <xsl:param name="node"/>
        <func:result select="concat(bb:item-full-name($item), '_', local-name($node))"/>
    </func:function>

    <func:function name="bb:val-full-name">
        <xsl:param name="item"/>
        <xsl:param name="node"/>
        <func:result select="concat(bb:mod-full-name($item, $node), '_', bb:mod-val($node))"/>
    </func:function>

    <func:function name="bb:is-block">
        <xsl:param name="node"/>
        <func:result select="boolean($node[self::tb:* | self::b:*])"/>
    </func:function>

    <func:function name="bb:is-mod">
        <xsl:param name="node"/>
        <func:result select="boolean($node[namespace-uri() = 'bem-b:mod'])"/>
    </func:function>

    <func:function name="bb:mod-val">
        <xsl:param name="mod"/>
        <xsl:choose>
            <xsl:when test="$mod[self::tm:*]">
                <func:result select="$mod/@val"/>
            </xsl:when>
            <xsl:otherwise>
                <func:result select="$mod"/>
            </xsl:otherwise>
        </xsl:choose>
    </func:function>

    <xsl:template match="/">
        <xsl:if test="$output = 'module'">exports.blocks = </xsl:if>
        <xsl:text>[</xsl:text>
            <xsl:apply-templates select="//*[generate-id() = generate-id(key('blocks', bb:block-full-name(.)))]" mode="block"/>
        <xsl:text>]</xsl:text>
        <xsl:if test="$output = 'module'">;&#10;</xsl:if>
    </xsl:template>

    <xsl:template name="obj">
        <xsl:param name="name" select="local-name()"/>
        <xsl:param name="content"/>

        <xsl:if test="position() - 1">, </xsl:if>
        <xsl:text>{</xsl:text>
            <xsl:text>"name": "</xsl:text><xsl:value-of select="$name"/><xsl:text>"</xsl:text>
            <xsl:value-of select="$content"/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template match="*" mode="block">
        <xsl:call-template name="obj">
            <xsl:with-param name="name" select="bb:block-full-name(.)"/>
            <xsl:with-param name="content">
                <xsl:apply-templates select="." mode="mods"/>

                <xsl:variable name="elems" select="//*[
                    generate-id() = generate-id(
                        key(
                            'elems',
                            bb:elem-full-name(current(), .)))]"/>
                <xsl:if test="$elems">
                    <xsl:text>, "elems": [</xsl:text>
                    <xsl:apply-templates select="$elems" mode="elem"/>
                    <xsl:text>]</xsl:text>
                </xsl:if>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*" mode="elem">
        <xsl:call-template name="obj">
            <xsl:with-param name="content">
                <xsl:apply-templates select="." mode="mods"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*" mode="mods">
        <xsl:variable name="mods" select="(//*/@*[bb:is-mod(.)] | //tm:*)[
            generate-id() = generate-id(
                key(
                    'mods',
                    bb:mod-full-name(current(), .)))]"/>
        <xsl:if test="$mods">
            <xsl:text>, "mods": [</xsl:text>
            <xsl:apply-templates select="$mods" mode="mod"/>
            <xsl:text>]</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="* | @*" mode="mod"/>
    <xsl:template match="tm:* | @m:*" mode="mod">
        <xsl:call-template name="obj">
            <xsl:with-param name="content">
                <xsl:variable name="vals" select="key('mods', bb:mod-full-name(.., .))[
                    generate-id() = generate-id(
                        key(
                            'vals',
                            bb:val-full-name(.., .)))]"/>
                <xsl:if test="$vals">
                    <xsl:text>, "vals": [</xsl:text>
                    <xsl:for-each select="$vals">
                        <xsl:if test="position() - 1">, </xsl:if>
                        <xsl:text>"</xsl:text><xsl:value-of select="bb:mod-val(.)"/><xsl:text>"</xsl:text>
                    </xsl:for-each>
                    <xsl:text>]</xsl:text>
                </xsl:if>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
