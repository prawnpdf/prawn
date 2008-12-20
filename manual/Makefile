.PHONY: all

all: pdf/manual.pdf

docbook/manual.xml: src/*.txt
	asciidoc -b docbook -d book -o docbook/manual.xml -a imagesdir=../figures/ src/index.txt 
pdf/manual.pdf: docbook/manual.xml
	dblatex -o pdf/manual.pdf docbook/manual.xml
