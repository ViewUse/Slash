app = require 'app'
browserWindow = require 'browser-window'
path = require 'path'
fs = require 'fs'
dialog = require 'dialog'
ipc = require 'ipc'
menu = require 'menu'
tray = require 'tray'
Promise = require 'bluebird'
http = require 'http'

args = require './args'
defaultDocPort = args.docport or 33300
defaultApiPort = args.apiport or 33400
args.docsetdir = args.docsetdir or path.join(process.cwd(), "Docsets")

# check if there is already an Slash is running
mainWindow = null


app.on 'ready', ->
    new Promise (resolve, reject)->
        fs.readFile path.join(args.profiledir, 'docsetApi.port'), (err, data)->
            return reject(err) if err
            port = parseInt data
            resolve port
    .catch ->
        true
    .then (oldPort)->
        new Promise (resolve, reject)->
            options =
                hostname: 'localhost'
                port: oldPort
                path: '/focus'
                method: 'GET'
            req = http.request options, ->
                console.log 'Slash is already running !'
                reject(new Error('Slash is already running'))
            req.on 'error', (e)->
                console.log e
                resolve()
            req.end()
            setTimeout ->
                resolve()
            , 1000
    .catch ->
        app.quit()
    .then ->
        require('./server/doc-server').run(defaultDocPort, args.docsetdir)
    .then ->
        require('./server/api').run(defaultApiPort)
    .then (apiPort)->
        fs.writeFileSync path.join(args.profiledir, 'docsetApi.port'), apiPort
    .then ->
        args.mainWindow = mainWindow = new browserWindow
            width: 1000
            height: 710
            "web-preferences":
                "direct-write": true
                "overlay-scrollbars": false
            icon: path.join(path.dirname(__dirname), 'Slash.png')
        mainWindow.openDevTools() if args.debug
        mainWindow.loadUrl 'file://' + __dirname + '/../browser/index.html'
app.on 'window-all-closed', ->
    app.quit()
ipc.on 'showMainWindow', ->
    args.mainWindow.focus()
    args.mainWindow.focusOnWebView()