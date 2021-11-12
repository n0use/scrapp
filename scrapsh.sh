#!/usr/local/bin/bash 

UA="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)"
site="https://wallpaperaccess.com/"

section="$1"
[[ "$2" == "-r" ]] && related="yes"

if [ -z "${section}" ] ; then
    echo "Usage: $0 section [-r]"
    echo ".. will scrape all the big images from specified section on wallpaperaccess.com"
    echo ".. the optional -r argument at the end will scrape not only the category you specified but also wallpaper.com's list of 'related' categories"
    exit 1
fi



grab_related()
{
    local section="$1"
    local _html="r-${RANDOM}.html"

    echo "generating list of sections related to '$section'.."

    section="${section}#related"
    echo wget --user-agent="${UA}" -O index.html -S -nH "${site}/${section}"
    wget --show-progress --quiet  --user-agent="${UA}" -O "${_html}" -S -nH "${site}/${section}"
    gawk '/class="ui fluid image" href="\/[0-9A-Za-z\-_]*"/ { u = gensub(/^(.*)href="\/([0-9A-Za-z\-_]*)".*/, "\\2", "g"); print u; }' "${_html}"| \
    while read -r l ; do 
        _cwd=$(pwd)
        make_dir "${l}"
        grab_pics "${l}" 
        cd "${_cwd}" 
    done
    rm -f "${_html}"
}

grab_pics()
{

    local section="$1"
    local _html="p-${RANDOM}.html"
    
    echo "..scraping ${section}.."
    wget --show-progress --quiet  --user-agent="${UA}" -O "${_html}" -S -nH "${site}/${section}"
    grep -o '.full\/[0-9]*.jpg' "${_html}" | sort -u | sed 's#^#https://wallpaperaccess.com#' | \
    while read -r l ; do 
        wget --show-progress --quiet --user-agent="${UA}" $l ; 
    done
    rm -f "${_html}"
}

make_dir()
{
    mkdir "${1}" && cd "${1}" || { echo "fatal error creating/accessing directory $(pwd)/${1}.."; exit 2; }
}


if [ -z "${related}" ] ; then 
    make_dir "${section}" 
    grab_pics "${section}"
else
    make_dir "${section}.related"
    grab_related "${section}"

fi

 #   || mkdir "${section}.${related}"




# vim:ts=4:sts=4:ai:et:syntax=bash:ft=bash:
