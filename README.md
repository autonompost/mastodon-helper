# mastodon download help for obsidian

quick and dirty example of how to get all or the latest toots from a mastodon account in markdown format
installation and usage steps
1. install https://github.com/McKael/madonctl
2. create config
3. create of modify a template (beware this script has only be tested with the template in this repo)
4. set the correct path variables to fit your needs

**a word of advice**

if you download attachments and use git it is better to use git lfs for the attachments. See the documentation on how to use git-lfs with your git remote service

if you don't use git lfs you will have to commit the attachments to your git repo which will bloat it and make it slow

else if you have significantly rewritten the script yourself and want to contribute please fork and open up a pull request or post me your script
contact @ybaumy@digitalcourage.social


## export and import tags when moving accounts
1. install [toot](https://github.com/ihabunek/toot)
2. login to your old account with ```toot login```
3. get your tags ```toot tags_followed | awk '{print $2}' > tags```
4. login to your new account ```toot login```
5. make sure that your new account is active ```toot auth```
6. best start a tmux session
7. then run the script ```./import_tags.sh tags``` to import the tags

**you can try to modify and use other wait times, but i wanted to make sure to import all my ~550 tags i follow without running in the API limit**
