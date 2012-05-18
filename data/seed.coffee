
fs = require 'fs'
file = fs.readFileSync 'dict.txt', 'utf-8'
list = file.split '\n'

copy = []

for line in list
  match = line.match /^([a-z]+):(.*)$/
  if not match? then console.log line else
    for item in match[2].split ','
      copy.push key:match[1], word:item, count:0

url = 'mongodb://nodejs:nodepasswd@localhost:27017/ime'
(require 'mongodb').connect url, (err, db) ->
  db.collection 'dict', (err, coll) ->
    throw err if err?
    for item in copy
      if item? then coll.save item
    db.close()