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
    xmlns:func="http://exslt.org/functions"
    extension-element-prefixes="bb str func">

    <xsl:output
        encoding="UTF-8"
        method="xml"
        indent="yes"
    />

    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="xsl:text"/>

    <xsl:template name="match">
        <xsl:param name="string"/>
        <xsl:param name="pattern"/>
        <xsl:variable name="char" select="substring($string, 1, 1)"/>
        <xsl:if test="$char != '' and translate($char, $pattern, '') = ''">
            <xsl:value-of select="$char"/>
            <xsl:call-template name="match">
                <xsl:with-param name="string" select="substring($string, 2)"/>
                <xsl:with-param name="pattern" select="$pattern"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- TODO: более правильный разбор xpath -->
    <xsl:template name="extract-variables">
        <xsl:param name="xpath"/>
        <xsl:param name="result" select="/.."/>
        <xsl:variable name="last" select="substring-after($xpath, '$')"/>
        <xsl:variable name="variable">
            <xsl:call-template name="match">
                <xsl:with-param name="string" select="$last"/>
                <xsl:with-param name="pattern" select="'QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm1234567890-_'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$variable != ''">
                <xsl:variable name="result-tmp">
                    <xsl:copy-of select="$result/*"/>
                    <xsl:if test="not($result/*[. = $variable])">
                        <variable><xsl:value-of select="$variable"/></variable>
                    </xsl:if>
                </xsl:variable>
                <xsl:call-template name="extract-variables">
                    <xsl:with-param name="xpath" select="substring-after($last, $variable)"/>
                    <xsl:with-param name="result" select="exslt:node-set($result-tmp)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$result"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <func:function name="bb:extract-variables">
        <xsl:param name="node"/>
        <xsl:variable name="variables-tmp">
            <xsl:call-template name="extract-variables">
                <xsl:with-param name="xpath">
                    <xsl:apply-templates select="$node" mode="bb:variables-xpath"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <func:result select="exslt:node-set($variables-tmp)"/>
    </func:function>

    <xsl:template match="* | @*" mode="bb:variables-xpath"/>
    <xsl:template match="xsl:variable | xsl:param" mode="bb:variables-xpath">
        <xsl:value-of select="@select"/>
    </xsl:template>
    <xsl:template match="xsl:choose" mode="bb:variables-xpath">
        <xsl:for-each select="xsl:when/@test">
            <xsl:if test="position() - 1"> | </xsl:if>
            <xsl:value-of select="."/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="xsl:if" mode="bb:variables-xpath">
        <xsl:value-of select="@test"/>
    </xsl:template>

    <xsl:template match="* | @*" mode="bb:is-variables-simple">
        <xsl:param name="prefix" select="''"/>
        <xsl:param name="delimiter" select="' or '"/>
        <xsl:for-each select="bb:extract-variables(.)/*">
            <xsl:choose>
                <xsl:when test="position() - 1">
                    <xsl:value-of select="$delimiter"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$prefix"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>$</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>__not-simple</xsl:text>
        </xsl:for-each>
    </xsl:template>

    <func:function name="bb:depend-on-variables">
        <xsl:param name="node"/>
        <func:result select="boolean(bb:extract-variables($node)/*)"/>
    </func:function>

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
            <xsl:apply-templates select="xsl:param"/>
            <xsl:element name="xsl:choose">
                <xsl:element name="xsl:when">
                    <xsl:attribute name="test">not(descendant::xsl:* | descendant::d-xsl:*)</xsl:attribute>
                    <xsl:apply-templates select="node()[not(self::xsl:param)]"/>
                </xsl:element>
                <xsl:element name="xsl:when">
                    <xsl:attribute name="test">
                        <xsl:text>(self::b:* | self::e:*) and </xsl:text>
                        <xsl:text>string(@xsl-inline) != 'no' and </xsl:text>
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
                    <xsl:variable name="var" select="concat('tmp__', generate-id())"/>
                    <xsl:element name="xsl:variable">
                        <xsl:attribute name="name"><xsl:value-of select="$var"/></xsl:attribute>
                        <xsl:apply-templates mode="xsl-inline"/>
                    </xsl:element>
                    <xsl:variable name="copy">
                        <xsl:element name="xsl:copy-of">
                            <xsl:attribute name="select">$<xsl:value-of select="$var"/></xsl:attribute>
                        </xsl:element>
                    </xsl:variable>
                    <xsl:element name="xsl:choose">
                        <xsl:element name="xsl:when">
                            <xsl:attribute name="test">exslt:node-set($<xsl:value-of select="$var"/>)//*[self::d-xsl:variable]</xsl:attribute>
                            <d-xsl:if test="true()">
                                <xsl:copy-of select="$copy"/>
                            </d-xsl:if>
                        </xsl:element>
                        <xsl:element name="xsl:otherwise">
                            <xsl:copy-of select="$copy"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="xsl:otherwise">
                    <d-xsl:if test="true()">
                        <xsl:apply-templates mode="d-xsl"/>
                    </d-xsl:if>
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
        <xsl:param name="d-xsl" select="false()"/>
        <xsl:copy>
            <xsl:apply-templates select="." mode="attributes"/>
            <xsl:apply-templates mode="xsl-inline">
                <xsl:with-param name="d-xsl" select="$d-xsl"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xsl:*" mode="xsl-inline">
        <xsl:param name="d-xsl" select="false()"/>
        <xsl:variable name="ns">
            <xsl:if test="$d-xsl">d-</xsl:if>
            <xsl:text>xsl:</xsl:text>
        </xsl:variable>
        <xsl:element name="{concat($ns, local-name())}">
            <xsl:apply-templates select="@*" mode="d-xsl"/>
            <xsl:apply-templates mode="xsl-inline">
                <xsl:with-param name="d-xsl" select="false()"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <xsl:template match="xsl:apply-templates | xsl:apply-imports | xsl:with-param | xsl:if | xsl:for-each | xsl:element[contains(@name, '{')] | xsl:value-of | xsl:copy-of" mode="xsl-inline">
        <xsl:param name="d-xsl" select="false()"/>
        <xsl:copy>
            <xsl:apply-templates select="." mode="attributes"/>
            <xsl:apply-templates mode="xsl-inline">
                <xsl:with-param name="d-xsl" select="$d-xsl"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xsl:variable | xsl:param" mode="xsl-inline">
        <xsl:param name="d-xsl" select="false()"/>
        <xsl:copy>
            <xsl:apply-templates select="." mode="attributes"/>
            <xsl:apply-templates mode="xsl-inline">
                <xsl:with-param name="d-xsl" select="$d-xsl"/>
            </xsl:apply-templates>
        </xsl:copy>
        <xsl:element name="xsl:variable">
            <xsl:attribute name="name"><xsl:value-of select="@name"/>__not-simple</xsl:attribute>
            <xsl:attribute name="select">
                <xsl:value-of select="concat('boolean(exslt:node-set($', @name, ')//*[self::xsl:* | self::d-xsl:*])')"/>
                <xsl:apply-templates select="." mode="bb:is-variables-simple">
                    <xsl:with-param name="prefix" select="' or '"/>
                </xsl:apply-templates>
            </xsl:attribute>
        </xsl:element>

        <xsl:element name="xsl:if">
            <xsl:attribute name="test">
                <xsl:text>$</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>__not-simple</xsl:text>
            </xsl:attribute>
            <xsl:element name="{concat('d-xsl:', local-name())}">
                <xsl:apply-templates select="@*" mode="d-xsl"/>
                <xsl:apply-templates mode="xsl-inline">
                    <xsl:with-param name="d-xsl" select="$d-xsl"/>
                </xsl:apply-templates>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="xsl:choose[bb:depend-on-variables(.)] | xsl:if[bb:depend-on-variables(.)]" mode="xsl-inline">
        <xsl:param name="d-xsl" select="false()"/>
        <xsl:element name="xsl:choose">
            <xsl:element name="xsl:when">
                <xsl:attribute name="test">
                    <xsl:apply-templates select="." mode="bb:is-variables-simple"/>
                </xsl:attribute>
                <xsl:element name="{concat('d-xsl:', local-name())}">
                    <xsl:apply-templates select="@*" mode="d-xsl"/>
                    <xsl:apply-templates mode="xsl-inline">
                        <xsl:with-param name="d-xsl" select="boolean(self::xsl:choose)"/>
                    </xsl:apply-templates>
                </xsl:element>
            </xsl:element>
            <xsl:element name="xsl:otherwise">
                <xsl:copy>
                    <xsl:apply-templates select="." mode="attributes"/>
                    <xsl:apply-templates mode="xsl-inline"/>
                </xsl:copy>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- TODO: добавить про остальные элементы, зависящие от переменных -->

</xsl:stylesheet>
