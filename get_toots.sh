#!/usr/bin/env bash
# quick and dirty example of how to get all or the latest toots from a mastodon account in markdown format
# installation and usage steps
# 1. install https://github.com/McKael/madonctl
# 2. create config
# 3. create of modify a template
# 4. set the correct path variables to fit your needs

mode=$1
curpath="/home/ybaumy/git/obsidian-mastodon-test"
tootpath="toots"
tmppath="tmp"
config="/home/ybaumy/config.yaml"
template="/home/ybaumy/status.tmpl"
bin='/home/ybaumy/go/bin/madonctl'

mkdir -p ${curpath}/${tmppath}
mkdir -p ${curpath}/${tootpath}

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

for file in $(ls -1 tmptoot*md)
do
  fileid=$(cat $file | head -4 |grep -E "^# " | cut -d" " -f2)
  mv $file ${curpath}/${tootpath}/${fileid}.md
done

