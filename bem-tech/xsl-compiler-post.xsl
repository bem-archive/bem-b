<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:d-xsl="b:xsl"
    xmlns:d2-xsl="b:xsl-2"
    xmlns:x="http://www.yandex.ru/xscript"
    xmlns:b="b"
    extension-element-prefixes="x b"
    exclude-result-prefixes="d2-xsl d-xsl"
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
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="d2-xsl:*" priority="10">
        <xsl:element name="{concat('xsl:', local-name())}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
