redmine_git_mirror不支援 url auth 的原因，是因為安全性問題，這裡我不需要擔心這個，所以直接修改原始碼，把這個限制拿掉。
> 有找到一個分支 sharpSteff/redmine_git_mirror 就是把 urls auth 限制拿掉，可是偏偏它又有bug，我就在分支出來，修了這一個 bug

Webhook: http://192.168.100.70:8083/sys/git_mirror/fetch?url=URLEncode{URL}

EX:
> Identifier: mars-host-setup  
> URL: http://gitlab+deploy-token-5:pUvtimjxkhXyB165Ny31@gitlab.uj.com.tw/doc-msdk/mars/mars-host-setup.git
>
> Webhook: http://192.168.100.70:8083/sys/git_mirror/fetch?url=http%3A%2F%2Fgitlab%2Bdeploy-token-5%3ApUvtimjxkhXyB165Ny31%40gitlab.uj.com.tw%2Fdoc-msdk%2Fmars%2Fmars-host-setup.git

==================

Redmine Git Mirror plugin 
==================

Adds ability to clone and fetch remote git repositories to redmine.

## Key Features
* Easy install (just clone to redmine plugins folder)
* Webhooks integration (gitlab and custom)
* Works well with enabled autofetch changesets setting and in mix with other scm types  
* Automatic deletes unreachable commits

# Install

    cd [redmine-root]/plugins
    git clone https://github.com/linniksa/redmine_git_mirror

Restart redmine, and enable `Git Mirror` scm type at `redmine.site/settings?tab=repositories`

## Accessing private repositories

At this moment only ssh access with redmine user ssh key is supported. 

# Fetching changes

This plugin supports 2 ways of fetching changes, via cronjob or via hooks.
You can use only one or both of them together.

## Cronjob

Run ```./bin/rails runner "Repository::GitMirror.fetch"```, for example: 

    5,20,35,50 * * * * cd /usr/src/redmine && ./bin/rails runner "Repository::GitMirror.fetch"  -e production >> log/cron_rake.log 2>&1

## Hooks

Hooks is preferred way because you can immediately see changes of you repository.

### GitLab hooks

You can setup per-project or system wide hook, for both variants use `redmine.site/sys/git_mirror/gitlab` as `URL`

###### For system wide setup

Go to `gitlab.site/admin/hooks`, and select only `Repository update events` trigger.

###### For per-project setup

Go to `gitlab.site/user/project/settings/integrations`, and select only `Push` and `Tags` events

### GitHub hooks

You can setup per-project or group wide hook, for both variants 
use `redmine.site/sys/git_mirror/github` as `Payload URL` and `Just the push event` option.

Don't worry about `Content type` both `application/json` and `application/x-www-form-urlencoded` are supported.
