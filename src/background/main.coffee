import $ from "jquery"
import setting from "./setting.coffee"
import ext from "./ext.coffee"
import storage from  "./storage.coffee"
import dictwindow from "./dictwindow.coffee"
import message from "./message.coffee"


onClickedContextMenu = (info, tab)->
    if info.selectionText
        dictWindow.lookup(info.selectionText)

chrome.browserAction.onClicked.addListener (tab)->
    if setting.getValue('browserActionType') == 'openDictWindow'
        return dictWindow.lookup()

    b = !setting.getValue('enableMinidict')
    setting.setValue('enableMinidict', b)
    ext.setBrowserIcon(b)

setting.init().done (c)->
    ext.setBrowserIcon(c.enableMinidict)

storage.init()

chrome.contextMenus.create {
    title: "使用 FairyDict 查询 '%s'",
    contexts: ["selection"],
    onclick: onClickedContextMenu
        }
