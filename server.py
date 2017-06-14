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