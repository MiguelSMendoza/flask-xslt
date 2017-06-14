#Transformaciones XSLT con Python y Flask
En el artículo [Transformaciones con XSLT](https://www.smendoza.net/transformaciones-con-xslt/) vimos una introducción al lenguaje de transformaciones, sin embargo, no explicamos como utilizar debidamente esta tecnología. En este artículo explicaremos como realizar transformaciones XSLT en Python haciendo uso de la biblioteca lxml y veremos como montar un servidor web con Flask para hacer uso de nuestro procesador XSLT desde cualquier lugar.
##Introducción
Tanto los documentos XML como las hojas de estilo en XSLT son completamente independientes de la plataforma que se vaya a utilizar para realizar las transformaciones. Podemos enlazar una hoja de estilos XSLT a un documento XML de forma permanente añadiendo un elemento `<?xml-stylesheet ..?>` justo después de la declaración XML como podemos ver en el Fragmento de Código 1. De esta forma, al abrir el documento con un navegador web, éste aplicará las transformaciones pertinentes de forma automática y podremos comprobar el resultado.

    <?xml version="1.0" encoding="UTF-8"?>
    <?xml-stylesheet type="text/xsl" href="hojaEstilos.xslt"?>
    <Coleccion>
    	<documento>
    		<titulo>El Titulo</titulo>
    		<autor>Miguel S. Mendoza</autor>
    		<fecha>1984</fecha>
    	</documento>
    	<documento>
    		<titulo>El Otro Titulo</titulo>
    		<autor>Marta S. Román</autor>
    		<fecha>2016</fecha>
    	</documento>
    </Coleccion>

Sin embargo, si lo que queremos es generar documentos independientes es necesario utilizar un procesador XSLT que se encargue de aplicar al documento XML las reglas de transformación incluidas en la hoja de estilo XSLT y genere un documento final. La transformación se realiza de la siguiente forma:

El procesador analiza el documento y construye el árbol del documento.
El procesador recorre todos los nodos desde el nodo raíz, aplicando a cada nodo una plantilla, sustituyendo el nodo por el resultado.
Cuando el procesador ha recorrido todos los nodos, se ha terminado la transformación.
Afortunadamente existen procesadores XSLT para casi todos los lenguajes de programación, como Perl, C, Java, etc. En nuestro caso hemos optado por implementar el procesador haciendo uso del lenguaje Python y su librería libxml.
##Python
Python es un lenguaje muy potente y fácil de aprender. Maneja eficientes estructuras de datos de alto nivel y cuenta con un enfoque simple pero efectivo de programación orientada a objetos. Posee una sintaxis muy elegante y tipado dinámico, que junto con su carácter interpretado lo convierte en un lenguaje ideal para desarrollo rápido de aplicaciones en innumerables áreas. Python se encuentra en un gran número de aplicaciones web y de escritorio, por lo que es un lenguaje de aprendizaje casi obligatorio para un desarrollador actual, ya que permite resolver problemas de una forma muy eficiente en un corto espacio de tiempo. Además, cuenta con un repositorio de paquetes que permiten extender la funcionalidad de las aplicaciones de una forma sencilla, muy similar a como se hace con NodeJS.

El gestor de paquetes recomendado para Python se denomina pip, y se utiliza de un modo similar a npm o apt-get. Con él, podemos instalar el paquete lxml que nos permitirá procesar documentos XML y HTML de forma sencilla.

    pip install lxml

En el Fragmento de Código 2 podemos ver cómo aplicar una plantilla XLST a un documento XML como el que vimos en el Fragmento de Código 1.

    import lxml.etree as ET
    
    def transforma_documento(XML):
      dom = ET.fromstring(XML)
      transform = ET.XSLT(ET.parse('hojaEstilos.xslt'))
      nuevodom = transform(dom)
      resultado = ET.tostring(nuevodom, pretty_print=True)
      return resultado

Como podemos observar, aunque no hayamos visto el lenguaje Python hasta ahora, simplemente leyendo el código entendemos perfectamente lo que hace. Inicialmente se lee el fichero de entrada que se pasa como parámetro al método transforma_documento. Seguidamente se utiliza el contenido del fichero para obtener el árbol de nodos del documento XML y almacenarlos en la variable dom. A continuación se obtiene un objeto de transformación leyendo el fichero de hoja de estilos “hojaEstilos.xslt” en el que se han definido las transformaciones, cuyo contenido podemos ver en el Fragmento de Código 3. Se aplican las transformaciones en el árbol de nodos y se obtiene un nuevo árbol de documento que podemos convertir en una cadena de texto para devolverla como resultado para, si quisiéramos, escribirla en un nuevo fichero obteniendo finalmente nuestro fichero transformado.

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

Así, si abriéramos el fichero XML en un navegador obtendríamos un resultado parecido al que podemos observar en la siguiente captura.

Python puede instalarse en cualquier sistema operativo actual. Sin embargo, si queremos utilizar código en este lenguaje desde un entorno web se hace necesario utilizar una infraestructura apropiada que permita desarrollar aplicaciones web o servicios sin necesidad de manejar detalles de bajo nivel como protocolos o manejo de procesos e hilos.

Entre las numerosas infraestructuras que podríamos utilizar nos hemos decantado por Flask, una infraestructura web minimalista que nos permite realizar peticiones a nuestro código de transformación de forma sencilla mediante el desarrollo de una API REST. En el Fragmento de Código 4 podemos ver un ejemplo sencillo de cómo podríamos utilizar nuestro código de transformación visto en el Fragmento de Código 2 utilizándolo como una biblioteca denominada publisher, que se corresponde con el nombre del fichero en el que hemos almacenado nuestras funciones transformadoras.

    import publisher
    from flask import Flask, render_template, request
    app = Flask(__name__)
    
    @app.route('/')
    def index():
        return render_template('index.html')
    
    @app.route("/transform", methods=['POST'])
    def transform():
    	file = request.files['uploadfile']
    	XML = file.read()
    	resultDocument = publisher.transforma_documento(XML)
    	return resultDocument
    
    if __name__ == "__main__":
    	app.run()

Para poder gestionar correctamente el servidor web, utilizamos las funciones render_template y request, con el objetivo de devolver ficheros estáticos, y de manejar las peticiones respectivamente. Como podemos observar es un código relativamente sencillo que nos permitirá obtener un documento transformado a partir de un documento que podemos enviar mediante un formulario HTML como el del Fragmento de Código 4.

    <form action="/transform" method="post">
        <input type="file" name="uploadfile" />
        <input type="submit" value="Transformar" />
    </form>

##Conclusión
Utilizar Flask nos permitirá, entre otras cosas, poder mejorar la modularidad de un sistema en diferentes máquinas en caso de que fuera necesario, es decir, podríamos perfectamente instalar nuestro servicio de transformaciones en un servidor, y la aplicación web que utilice éste en otro distinto. Sin embargo, si quisiéramos utilizar tanto Flask como NodeJS en una misma máquina tendremos que utilizar aplicaciones intermedias como Virtual Environment  para mantener la aplicación Flask ejecutándose como servicio, uWSGI como interfaz web entre servidores web y el servicio creado con Virtual Environment y NGINX como servidor web para controlar todas las peticiones entre la aplicación web y el servicio de transformaciones en Python.

Artículo Original: [SMendoza](https://www.smendoza.net/xslt-python-lxml/)