import lxml.etree as ET

def transforma_documento(XML):
  dom = ET.fromstring(XML)
  transform = ET.XSLT(ET.parse('hojaEstilos.xslt'))
  nuevodom = transform(dom)
  resultado = ET.tostring(nuevodom, pretty_print=True)
  return resultado