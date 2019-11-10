import utils from "utils"
import message from "./message.coffee"

class Item
	constructor: ({ @i, @w, @s, @sc, @r, @t = Date.now() }) ->
	save: () ->
		new Promise (resolve) =>
			chrome.storage.sync.set({
				"w-#{@i}": { @i, @w, @s, @sc, @r, @t }
			}, resolve)
	update: ({w, s, sc, r, t}) ->
		@w = w if w?
		@s = s if s?
		@s = sc if sc?
		@r = r if r?
		@t = t if t?
		@save()

	@getAll: () ->
		new Promise (resolve) ->
			chrome.storage.sync.get null, (data) ->
				resolve Object.keys(data).filter((item) -> item.startsWith('w-')).map((k) -> new Item(data[k]))

	@delete: (w) ->
		new Promise (resolve) ->
			chrome.storage.sync.remove "w-#{w}", resolve

manager = {
	maxLength: 200,
	history: [],
	init: ()->
		@history = await Item.getAll()

	getInHistory: (word) ->
		return @history.find (item) ->
			return item.w == word

	getPrevious: (w) ->
		return @history[@history.length - 1] if not w
		idx = @history.findIndex (item) ->
			return item.w == w
		return @history[idx - 1] if idx > 0


	addRating: (word, rating)->
		item = @getInHistory(word)
		if item
			await item.update {r: rating}

	addHistory: ({w, s, sc, r, t})->
		item = @getInHistory(w)
		if not item
			if @history.length >= @maxLength
				@history.shift()

			i = @history.length
			item = new Item({i, w, s, sc, r, t})
			@history.push(item)
			await item.save()
		return item

	deleteHistory: (word)->
		idx = @history.findIndex (item)->
			return item.w == word
		if idx >= 0
			@history.splice(idx, 1)
			await Item.delete(word)

	clearAll: () ->
		new Promise (resolve) ->
			chrome.storage.sync.clear resolve

	set: (data) ->
		new Promise (resolve) ->
			chrome.storage.sync.set(data, resolve)
	get: (k) ->
		new Promise (resolve) ->
			chrome.storage.sync.get k, (data) ->
				resolve(data)
	remove: (k) ->
		new Promise (resolve) ->
			chrome.storage.sync.remove k, resolve
}

message.on 'history', () ->
	manager.history

export default manager