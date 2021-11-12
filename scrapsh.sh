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

    section="${section}#related"
    echo wget  --user-agent="${UA}" -O index.html -S -nH "${site}/${section}"
    wget  --user-agent="${UA}" -O index.html -S -nH "${site}/${section}"
    gawk '/class="ui fluid image" href="\/[0-9A-Za-z\-_]*"/ { u = gensub(/^(.*)href="\/([0-9A-Za-z\-_]*)".*/, "\\2", "g"); print u; }' index.html | \
    while read -r l ; do 
        _cwd=$(pwd)
        mkdir "$l" && cd "$l"
        echo grab_pic_urls "${l}" 
        cd "${_cwd}" 
    done
}

grab_pic_urls()
{

    local collection=$1

    wget  --user-agent="${UA}" -O index.html -S -nH "${site}/${section}"
    grep -o '.full\/[0-9]*.jpg' index.html | sort -u | sed 's#^#https://wallpaperaccess.com#' | \
    while read -r l ; do 
        wget $l ; 
    done
}


if [ -z "${related}" ] ; then 
    mkdir "${section}" 
    cd "${section}"
    grab_pic_urls "${section}"
else
    mkdir "${section}.related"
    cd "${section}.related"
    grab_related "${section}"

fi

 #   || mkdir "${section}.${related}"




# vim:ts=4:sts=4:ai:et:syntax=bash:ft=bash:
