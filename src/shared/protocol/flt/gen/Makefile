all: base class

base:
	xsltproc base-message.xsl ../spec/fields.xml > ../src/Message.py

class:
	xsltproc class-message.xsl ../spec/header.xml > ../src/Header.py

