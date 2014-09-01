<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output omit-xml-declaration="yes"/>
  <xsl:template match="Fields">
    <xsl:text>import dateutil&#xa;class Message(object):&#xa;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>    def __repr__(self):&#xa;        return "class: {0}".format(self.__class__.__name__)</xsl:text>
  </xsl:template>

  <xsl:template match="field">
    <xsl:text>&#xa;    def </xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text>(self):&#xa;        return </xsl:text>
    <xsl:call-template name="type-to-default-value">
      <xsl:with-param name="type" select="type"/>
    </xsl:call-template>
    <xsl:text>&#xa;    def </xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text>(self, value):&#xa;        pass&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="type-to-default-value">
    <xsl:param name="type"/>
    <xsl:choose>
      <xsl:when test="$type = 'string'"><xsl:text>""</xsl:text></xsl:when>
      <xsl:when test="$type = 'date'"><xsl:text>dateutil.parser.parse("1970-01-01")</xsl:text></xsl:when>
      <xsl:when test="$type = 'datetime'"><xsl:text>dateutil.parser.parse("1970-01-01T00:00:00.000000")</xsl:text></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
