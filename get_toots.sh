#!/usr/bin/env bash
# quick and dirty example of how to get all or the latest toots from a mastodon account in markdown format
# installation and usage steps
# 1. install https://github.com/McKael/madonctl
# 2. create config
# 3. create of modify a template (beware this script has only be tested with the template in this repo)
# 4. set the correct path variables to fit your needs
#
# a word of advice
# if you download attachments and use git it is better to use git lfs for the attachments. See the documentation on how to use git-lfs with your git remote service
# if you don't use git lfs you will have to commit the attachments to your git repo which will bloat it and make it slow
#
# else if you have significantly rewritten the script yourself and want to contribute please fork and open up a pull request or post me your script
# contact @ybaumy@digitalcourage.social

mode=$1
dl=$2
curpath="/home/ybaumy/git/obsidian-mastodon-test"
tootpath="toots"
tmppath="tmp"
attachmentpath="/home/ybaumy/git/obsidian-mastodon-test/attachments"
picturespath="pictures"
videopath="videos"
audiopath="audio"
config="/home/ybaumy/config.yaml"
template="/home/ybaumy/git/obsidian-mastodon-test/status.tmpl"
bin='/home/ybaumy/go/bin/madonctl'

if [ ! -z $dl ] && [ "$dl" == "-d" ]
then
  download="true"
elif [ -z $dl ]
then
  download="false"
else 
  echo "Usage: ./get_toots.sh [all|latest] [-d]"
  exit 1
fi

mkdir -p ${curpath}/${tmppath}
mkdir -p ${curpath}/${tootpath}

download_attachments () {
  cd ${curpath}/${tmppath} || exit 1
  grep -A1 Attachment tmptoot-*md | perl -ne 'if (/Attachment ID: \!\[\[(.+)\]\]/) { $id = $1; } elsif (/URL: \[\](.+)/) { $url = $1; $url =~ s/\(|\)//g; print "$id $url\n"; }' > linklist.tmp

  [ ! -d ${attachmentpath}/${picturespath} ] && mkdir -p ${attachmentpath}/${picturespath}
  [ ! -d ${attachmentpath}/${audiopath} ] && mkdir -p ${attachmentpath}/${audiopath}
  [ ! -d ${attachmentpath}/${videopath} ] && mkdir -p ${attachmentpath}/${videopath}

  while read -r line
  do
    id=$(echo $line | cut -d" " -f1)
    url=$(echo $line | cut -d" " -f2)
    extension=$(echo $url | grep -oE '\.[^./]+$' | grep -oE '[^.]+$')

    case "$extension" in
        mp3|ogg)
            [ ! -f "${attachmentpath}/${audiopath}/${id}.${extension}" ] && wget -q -O ${attachmentpath}/${audiopath}/${id}.${extension} $url
              echo "${id} ${extension}" >> idext.tmp
            ;;
        png|jpg|jpeg)
            [ ! -f "${attachmentpath}/${picturespath}/${id}.${extension}" ] && wget -q -O ${attachmentpath}/${picturespath}/${id}.${extension} $url
              echo "${id} ${extension}" >> idext.tmp
            ;;
        mp4|webp)
            [ ! -f "${attachmentpath}/${videopath}/${id}.${extension}" ] && wget -q -O ${attachmentpath}/${videopath}/${id}.${extension} $url
              echo "${id} ${extension}" >> idext.tmp
            ;;
        *)
            echo "unknown file extension: $extension"
            ;;
    esac
  done < linklist.tmp
  [ -f linklist.tmp ] && rm -f linklist.tmp

  while read -r line
  do
    id=$(echo $line | cut -d" " -f1)
    ext=$(echo $line | cut -d" " -f2)
    [ "${mode}" == "all" ] && perl -p -i -e 's/(\!\[\[$ENV{id})(\]\])/$1\.$ENV{ext}$2/g' ${curpath}/${tootpath}/*.md
    perl -p -i -e 's/(\!\[\[$ENV{id})(\]\])/$1\.$ENV{ext}$2/g' ${curpath}/${tmppath}/tmptoot-*.md
  done < idext.tmp
  [ -f idext.tmp ] && rm -f idext.tmp
}

case $mode in
  all)
    cd ${curpath}/${tmppath} || exit 1
    $bin account statuses --config $config --template-file $template --all \
      | awk -v RS='---' 'NF {print > ("tmptoot-" NR ".md")}'
    ;;
  latest)
    cd ${curpath}/${tootpath} || exit 1
    lasttoot=$(ls -1 | cut -d. -f1 | sort -u | tail -1)
    mkdir -p ${curpath}/${tmppath}
    cd ${curpath}/${tmppath} || exit 1
    $bin account statuses --config $config --template-file $template --since-id $lasttoot \
      | awk -v RS='---' 'NF {print > ("tmptoot-" NR ".md")}'
    ;;
  *)
    exit 1
    ;;
esac

cd ${curpath}/${tmppath} || exit 1

[ "$download" == "true" ] && download_attachments

for file in $(ls -1 tmptoot*md)
do
  fileid=$(cat $file | head -4 |grep -E "^# " | cut -d" " -f2)
  mv $file ${curpath}/${tootpath}/${fileid}.md
done

