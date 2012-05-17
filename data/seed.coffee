
fs = require 'fs'
file = fs.readFileSync 'dict.txt', 'utf-8'
list = file.split '\n'

list = list.map (line) ->
  match = line.match /^([a-z]+):(.*)$/
  if not match? then console.log line else
    key: match[1], word: (match[2].split ','), count: 0

url = 'mongodb://nodejs:nodepasswd@localhost:27017/ime'
(require 'mongodb').connect url, (err, db) ->
  db.collection 'dict', (err, coll) ->
    throw err if err?
    for item in list
      if item? then coll.save item