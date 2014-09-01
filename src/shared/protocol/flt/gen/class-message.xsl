<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output omit-xml-declaration="yes"/>

<xsl:variable name="g-fields" select="document('../spec/fields.xml')/Fields"/>
<xsl:variable name="g-types" select="document('../spec/types.xml')/Types"/>
<xsl:variable name="g-class-name" select="/Message/name"/>

  <xsl:template match="Message">
    <xsl:text>&#xa;import Message&#xa;from dateutil import parser&#xa;&#xa;</xsl:text>
    <xsl:value-of select="concat('class ', name, '(Message.Message):')"/>
    <xsl:apply-templates select="field"/>
  </xsl:template>

  <xsl:template match="field">
    <xsl:variable name="field-length">
      <xsl:call-template name="get-field-length">
        <xsl:with-param name="field" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="field-begin">
      <xsl:call-template name="get-field-begin">
        <xsl:with-param name="field" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="field-name" select="name"/>
    <xsl:variable name="field-type" select="$g-fields/field[name = $field-name]/type"/>

    <!-- <xsl:value-of select="concat($field-name, ' - ', $field-type, ' | ')"/> -->

    <!-- <xsl:text>&#xa;    def </xsl:text> -->
    <!-- <xsl:value-of select="name"/> -->
    <!-- <xsl:text>(self):&#xa;        return </xsl:text> -->
    <!-- <xsl:call-template name="type-to-def-getter"> -->
    <!--     <xsl:with-param name="begin" select="$field-begin"/> -->
    <!--     <xsl:with-param name="end" select="$field-begin + $field-length"/> -->
    <!--     <xsl:with-param name="type" select="$field-type"/> -->
    <!-- </xsl:call-template> -->

    <xsl:text>&#xa;    def </xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text>(self, value = None):&#xa;        if None == value:&#xa;            </xsl:text>
    <xsl:call-template name="type-to-def-getter">
        <xsl:with-param name="begin" select="$field-begin"/>
        <xsl:with-param name="end" select="$field-begin + $field-length"/>
        <xsl:with-param name="type" select="$field-type"/>
    </xsl:call-template>
    <xsl:text>&#xa;        else:&#xa;            </xsl:text>
    <xsl:call-template name="type-to-def-setter">
        <xsl:with-param name="begin" select="$field-begin"/>
        <xsl:with-param name="end" select="$field-begin + $field-length"/>
        <xsl:with-param name="type" select="$field-type"/>
    </xsl:call-template>
    <xsl:text>&#xa;</xsl:text>

    <xsl:if test="not(following-sibling::field)">
      <xsl:call-template name="ancillary-methods">
        <xsl:with-param name="total-length" select="$field-begin + $field-length"/>
      </xsl:call-template>
    </xsl:if>

  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="ancillary-methods">
    <xsl:param name="total-length"/>
    
    <xsl:text>&#xa;    def __init__(self):&#xa;</xsl:text>
    <xsl:value-of select="concat('        self.__buf = &quot; &quot; * ', $total-length)"/>
    <xsl:text>&#xa;&#xa;    def __repr__(self):&#xa;        return (super(</xsl:text>
    <xsl:value-of select="$g-class-name"/>
    <xsl:text>, self).__repr__()
        + ", buffer length: {0}".format(len(self.__buf))
    </xsl:text>
    <xsl:for-each select="/Message/field">
      <xsl:value-of select="concat('&#xa;        + &quot;\n', name, ': [&quot; + ', 'str(self.', name, '())', ' + &quot;]&quot;')"/>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template name="type-to-def-getter">
    <xsl:param name="begin"/>
    <xsl:param name="end"/>
    <xsl:param name="type"/>
    <xsl:variable name="slice" select="concat($begin, ':', $end)"/>
    <xsl:choose>
      <xsl:when test="$type = 'string'"><xsl:value-of select="concat('return self.__buf[', $slice, '].strip()')"/></xsl:when>
      <xsl:when test="$type = 'date'"><xsl:value-of select="concat('return date d&#xa; ')"/></xsl:when>
      <xsl:when test="$type = 'datetime'"><xsl:value-of select="concat('return parser.parse(self.__buf[', $slice,'])')"/></xsl:when>
      <xsl:when test="$type = 'int'"><xsl:value-of select="concat('val = self.__buf[', $slice, '].strip()&#xa;            return int(val) if val else 0')"/></xsl:when>      
      <xsl:when test="$type = 'int'"><xsl:value-of select="concat('val = self.__buf[', $slice, '].strip()&#xa;            return float(val) if val else 0')"/></xsl:when>      
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="type-to-def-setter">
    <xsl:param name="begin"/>
    <xsl:param name="end"/>
    <xsl:param name="type"/>
    <xsl:variable name="width" select="$end - $begin"/>
    <xsl:choose>
      <xsl:when test="$type = 'string'"><xsl:value-of select="concat('self.__buf = self.__buf[:', $begin, '] + str(value).ljust(', $width, ', &quot; &quot;)[:', $width, '] + self.__buf[', $end, ':]')"/></xsl:when>
      <xsl:when test="$type = 'date'"><xsl:value-of select="concat('date d&#xa; ')"/></xsl:when>
      <xsl:when test="$type = 'datetime'"><xsl:value-of select="concat('self.__buf = self.__buf[:', $begin, '] + value.isoformat().ljust(', $width, ', &quot;0&quot;)[:', $width, '] + self.__buf[', $end, ':]')"/></xsl:when>
      <xsl:when test="$type = 'int'"><xsl:value-of select="concat('self.__buf = self.__buf[:', $begin, '] + str(value).rjust(', $width, ', &quot; &quot;)[:', $width, '] + self.__buf[', $end, ':]')"/></xsl:when>
      <xsl:when test="$type = 'double'"><xsl:value-of select="concat('self.__buf = self.__buf[:', $begin, '] + str(value).rjust(', $width, ', &quot; &quot;)[:', $width, '] + self.__buf[', $end, ':]')"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-field-begin">
    <xsl:param name="field"/>
    <xsl:param name="start-field-index" select="1"/>
    <xsl:param name="cum-total" select="0"/>

    <xsl:variable name="start-field" select="/Message/field[$start-field-index]"/>

    <xsl:variable name="field-length">
      <xsl:call-template name="get-field-length">
        <xsl:with-param name="field" select="$start-field"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="generate-id($field) = generate-id($start-field)">
        <xsl:value-of select="$cum-total"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="get-field-begin">
          <xsl:with-param name="field" select="$field"/>
          <xsl:with-param name="start-field-index" select="1 + $start-field-index"/>
          <xsl:with-param name="cum-total" select="$field-length + $cum-total"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template name="get-field-length">
    <xsl:param name="field"/>
    <xsl:choose>
      <xsl:when test="not($field/length)">
        <xsl:call-template name="get-field-length-from-fields">
          <xsl:with-param name="field-name" select="$field/name"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$field/length"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-field-length-from-fields">
    <xsl:param name="field-name"/>
    <xsl:choose>
      <xsl:when test="not($g-fields/field[name = $field-name]/type)"> 
        <xsl:call-template name="print-error-and-exit">
          <xsl:with-param name="message" select="concat($field-name, '/type is not defined in fields.xml')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="not($g-types/type[name = $g-fields/field[name = $field-name]/type]/length)">
            <xsl:call-template name="print-error-and-exit">
              <xsl:with-param name="message" select="concat($g-fields/field[name = $field-name]/type, '/length is not defined in types.xml for field ', $field-name)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$g-types/type[name = $g-fields/field[name = $field-name]/type]/length"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="print-error-and-exit">
    <xsl:param name="message"/>
    <xsl:message terminate="yes">Error occurred:
    <xsl:value-of select="$message"/>
    </xsl:message>
  </xsl:template>

</xsl:stylesheet>
