#!/bin/sh
#
# Script to build the slides-show from tex files
#
readonly src='src'
readonly prefix='middleware'
readonly work='target'
readonly pdflatex="pdflatex -output-format=pdf -interaction=nonstopmode"
readonly site_dir="../rules-site"
readonly delivery_folder="../delivery"

usage() {
    echo "$(basename ${0}) [-H] [-d] [-b|-s|-a]"
    echo "default is -a (all), and builds both handout(-b) and slides(-s)"
}

setBuildSlides() {
    if [ -z ${slides} ] ; then readonly slides="${prefix}-slides" ; fi
}

setBuildBook() {
    if [ -z ${book} ] ; then readonly book="${prefix}-book"; fi
}

setQcm() {
    if [ -z ${qcm} ] ; then readonly qcm="qcm"; fi
}

run_latex() {
    local file="${1}"
    local verbose="${2}"

    if [ -z ${verbose} ]; then
        ${pdflatex} "${file}.tex" > /dev/null
    else
        ${pdflatex} "${file}.tex"
    fi

    if [ $? -ne 0 ]; then
        echo "BUILD FAILED"
        exit $?
    fi

}

buildDoc() {
    local file="${1}"
    local runtwice="${2}"

    run_latex "${file}" "${debug}"
    if [ "${runtwice}" != "" ] ; then
      run_latex "${file}" ""
    fi
    mv "${file}.pdf" "${delivery_folder}"
}

generateDoc() {
    local toggle="${1}"
    local file="${2}"

    if [ -z ${3} ]; then
        run_twice=false
    else
        run_twice=true
    fi

    if [ "${toggle}" != "" ] ; then
        echo -n "Building ${toggle}... "
        buildDoc "${file}" "${run_twice}"
        echo "Done: ${file}.pdf"
    fi
}

clean() {
  # cleaning
  if [ "${clean}" != "" ] ; then
    echo -n "Cleaning..."
    rm -rf "${work}"
    rm -f *.pdf
    rm -rf "${delivery_folder}"
    echo "Done."
  fi
}

mkdir -p "${work}"
cp -R "${src}"/* "${work}"


#set -e
while getopts dcsbHaq OPT; do
    case "$OPT" in
        H)
            echo "help requested:"
            usage
            exit 0
            ;;
        c)
            readonly clean='true'
            ;;
        s)
            setBuildSlides
            ;;
        b)
            setBuildBook
            ;;
        q)
            setQcm
            ;;
        d)
            readonly debug='true'
            ;;
        a)
            readonly clean='true'
            setBuildSlides
            setBuildBook
            setQcm
            ;;
        *)
            echo "unknown option ${OPT}"
            usage
            exit 1
            ;;
    esac
done

clean

mkdir -p "${work}"
cp -R "${src}"/* "${work}"
cp -R 'img/' "${work}"
cd ${work}
mkdir -p "${delivery_folder}"

generateDoc "${slides}" "${slides}" 'true'
generateDoc "${book}" "${book}" 'true'
generateDoc "${qcm}" "${qcm}" 'false'
