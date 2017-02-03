# Contents

1. [git](#git)
---
# git <a name="git"></a>
* fork your own repo (from GUI), assume link is https://link_to_your_repo
* clone from origin:
```bash
git clone https://link_to_origin
```
* add downstream repo
```bash
git remote add downstream https://link_to_your_repo
```
* pull orgin master
```bash
git pull
```
* create new branch for new code
```bash
git checkout -b name_of_new_branch
```
* make changes
```bash
git add .
git commit -m ""
```
* push to downstream
```bash
git push downstream -u name_of_new_branch
```
* create pull request from GUI
* delete new created branch from GUI
* delete local branch
```bash
git branch -d name_of_new_branch
```
* prune remote branch
```bash
git remote prune downstream
```
* each time before make changes
```bash
git checkout master
git pull
```
