<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  <xsl:template match="/">
    <html>
      <body>
        <h1>Los Documentos</h1>
        <table>
          <tr>
            <th>Titulo</th>
            <th>Autor</th>
          </tr>
          <xsl:for-each select="Coleccion/documento">
            <tr>
              <td><xsl:value-of select="titulo" /></td>
              <xsl:choose>
                <xsl:when test="fecha > 2010">
                  <td style="color: grey">
                    <xsl:value-of select="autor" />
                  </td>
                </xsl:when>
                <xsl:otherwise>
                  <td style="color: green">
                    <xsl:value-of select="autor" />
                  </td>
                </xsl:otherwise>
              </xsl:choose>
            </tr>
          </xsl:for-each>
        </table>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>