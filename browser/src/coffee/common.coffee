window.S = window.S or {}
window.ipc = require 'ipc'
window.Vue = window.Vue or require './bower_components/vue/dist/vue.js'
window.$ = require './bower_components/jquery/dist/jquery.js'
remote = require 'remote'
S.ds = remote.require './docset'
S.docPort = remote.require('./server/doc-server').docPort
S.cfg = remote.require('./config').config
S.bookmarks = remote.require('./bookmark').bookmarks
S.profileDir = remote.require('./args').profiledir
S.ds.getDocsets().then (docsets)->
    S.docsets = docsets
S.args = remote.require('./args')