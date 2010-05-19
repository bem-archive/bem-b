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
    exclude-result-prefixes="tb te tm mode">

    <xsl:output
        encoding="UTF-8"
        method="xml"
        indent="yes"
    />

    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="xsl:text"/>

    <xsl:template match="*" name="default">
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

    <xsl:template match="e:*[not(ancestor::b:*)]">
        <xsl:variable name="block">
            <xsl:choose>
                <xsl:when test="@b">
                    <xsl:value-of select="@b"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="local-name(ancestor::tb:*)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="b:{$block}">
            <xsl:attribute name="tag"/>
            <xsl:if test="not(@b) or @b = local-name(ancestor::tb:*)">
                <xsl:apply-templates select="ancestor::tm:*[parent::tb:*]" mode="mod"/>
            </xsl:if>
            <xsl:call-template name="default"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tm:*" mode="mod">
        <xsl:attribute name="m:{local-name()}">
            <xsl:value-of select="@val"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="tb:* | te:* | tm:*">
        <xsl:apply-templates select=".//mode:* | xsl:template | xsl:variable"/>
    </xsl:template>

    <xsl:template match="mode:*">
        <xsl:element name="xsl:template">
            <xsl:attribute name="match">
                <xsl:apply-templates select="." mode="match-content"/>
                <xsl:value-of select="@match"/>
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
        <xsl:choose>
            <!-- элемент c модификатором блока с модификатором -->
            <xsl:when test="parent::tm:*/parent::te:*/parent::tm:*/parent::tb:*">
                <xsl:apply-templates select="parent::tm:*" mode="for-elem-mod-block"/>
            </xsl:when>
            <!-- элемент c модификатором -->
            <xsl:when test="parent::tm:*/parent::te:*/parent::tb:*">
                <xsl:apply-templates select="parent::tm:*" mode="for-elem"/>
            </xsl:when>
            <!-- элемент блока с модификатором -->
            <xsl:when test="parent::te:*/parent::tm:*/parent::tb:*">
                <xsl:apply-templates select="parent::te:*" mode="for-mod-block"/>
            </xsl:when>
            <!-- модификатор блока -->
            <xsl:when test="parent::tm:*/parent::tb:*">
                <xsl:apply-templates select="parent::tm:*" mode="for-block"/>
            </xsl:when>
            <!-- элемент блока -->
            <xsl:when test="parent::te:*/parent::tb:*">
                <xsl:apply-templates select="parent::te:*" mode="for-block"/>
            </xsl:when>
            <!-- блок -->
            <xsl:when test="parent::tb:*">
                <xsl:apply-templates select="parent::tb:*" mode="single"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- b:myblock -->
    <xsl:template match="tb:*" mode="single">
        <xsl:text>b:</xsl:text>
        <xsl:value-of select="local-name()"/>
    </xsl:template>

    <!-- e:myelem -->
    <xsl:template match="te:*" mode="single">
        <xsl:text>e:</xsl:text>
        <xsl:value-of select="local-name()"/>
    </xsl:template>

    <!-- @m:mod1 = 'val1' -->
    <xsl:template match="tm:*" mode="single">
        <xsl:text>@m:</xsl:text>
        <xsl:value-of select="local-name()"/>
        <xsl:text>='</xsl:text>
        <xsl:value-of select="@val"/>
        <xsl:text>'</xsl:text>
    </xsl:template>

    <!-- @b = 'myblock' or (not(@b) and ancestor::b:myblock) -->
    <xsl:template match="tb:*" mode="for-elem">
        <xsl:text>@b='</xsl:text>
        <xsl:value-of select="local-name()"/>
        <xsl:text>'</xsl:text>
        <xsl:text> or (not(@b) and ancestor::b:</xsl:text>
        <xsl:value-of select="local-name()"/>
        <xsl:text>)</xsl:text>
    </xsl:template>

    <!-- e:myelem[@m:mymod1 = 'val1' and (@b = 'myblock' or (not(@b) and ancestor::b:myblock))] -->
    <xsl:template match="tm:*" mode="for-elem">
        <xsl:apply-templates select="parent::te:*" mode="single"/>
        <xsl:text>[</xsl:text>
        <xsl:apply-templates select="." mode="single"/>
        <xsl:text> and (</xsl:text>
        <xsl:apply-templates select="parent::te:*/parent::tb:*" mode="for-elem"/>
        <xsl:text>)]</xsl:text>
    </xsl:template>

    <!-- e:myelem[@b = 'myblock' or (not(@b) and ancestor::b:myblock)] -->
    <xsl:template match="te:*" mode="for-block">
        <xsl:apply-templates select="." mode="single"/>
        <xsl:text>[</xsl:text>
        <xsl:apply-templates select="parent::tb:*" mode="for-elem"/>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <!-- b:myblock[@m:mod1 = 'val1'] -->
    <xsl:template match="tm:*" mode="for-block">
        <xsl:apply-templates select="parent::tb:*" mode="single"/>
        <xsl:text>[</xsl:text>
        <xsl:apply-templates select="." mode="single"/>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <!-- e:myelem[(@b = 'myblock' or not(@b)) and ancestor::b:myblock[@m:mod1 = 'val1']] -->
    <xsl:template match="te:*" mode="for-mod-block">
        <xsl:apply-templates select="." mode="single"/>
        <xsl:text>[</xsl:text>
        <xsl:apply-templates select="ancestor::tb:*" mode="for-elem-mod-block"/>
        <xsl:text> and ancestor::</xsl:text>
        <xsl:apply-templates select="parent::tm:*" mode="for-block"/>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <!-- (@b = 'myblock' or not(@b)) -->
    <xsl:template match="tb:*" mode="for-elem-mod-block">
        <xsl:text>(@b = '</xsl:text>
        <xsl:value-of select="local-name()"/>
        <xsl:text>' or not(@b))</xsl:text>
    </xsl:template>

    <!-- e:myelem[@m:mymod1 = 'val1' and (@b = 'myblock' or not(@b)) and ancestor::b:myblock[@m:mod1 = 'val1']] -->
    <xsl:template match="tm:*" mode="for-elem-mod-block">
        <xsl:apply-templates select="parent::te:*" mode="single"/>
        <xsl:text>[</xsl:text>
        <xsl:apply-templates select="." mode="single"/>
        <xsl:text> and </xsl:text>
        <xsl:apply-templates select="ancestor::tb:*" mode="for-elem-mod-block"/>
        <xsl:text> and ancestor::</xsl:text>
        <xsl:apply-templates select="parent::te:*/parent::tm:*" mode="for-block"/>
        <xsl:text>]</xsl:text>
    </xsl:template>

</xsl:stylesheet>
