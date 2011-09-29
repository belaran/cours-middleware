#!/bin/sh
#
# Script to build the slides-show from tex files
#
readonly src="src"
readonly prefix="middleware"
readonly book="${prefix}-book"
readonly slides="${prefix}-slides"
readonly work="target"
readonly pdflatex="pdflatex -output-format=pdf -interaction=nonstopmode"
readonly site_dir="rules-site"

export out=""
if [ "${2}" = "-silent" ] ; then
	export out="2> /dev/null"
	export 1=""
fi
# cleaning
if [ "${1}" = "clean" ] ; then
	rm -rf "${work}"
	rm -f "${slides}.pdf"
	exit 0
fi

mkdir -p "${work}"
cp -R ${src}/* "${work}"
cd "${work}"
echo "Build slides..."
if [ "${1}" = "slides"  ] ; then
	${pdflatex} ${slides}.tex ${out}
	# run twice to build table of content
	${pdflatex} ${slides}.tex 2> /dev/null
	mv ${slides}.pdf ..
fi

if [ "${1}" = "book" ] ; then
	echo "Build book"
	${pdflatex}  ${book}.tex ${out}
	${pdflatex}  ${book}.tex 2> /dev/null
	mv ${book}.pdf ..
fi
