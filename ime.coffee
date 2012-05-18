
app = (require 'http').createServer (req, res) ->
  res.end 'world?'

io = (require 'socket.io').listen app, {origins: '*:*'}
io.set 'log level', 1

app.listen 8000

url = 'mongodb://nodejs:nodepasswd@localhost:27017/ime'
(require 'mongodb').connect url, (err, db) ->
  throw err if err?
  db.collection 'dict', (err, coll) ->
    throw err if err?
    coll.ensureIndex {key: 1}, (err, indexName) ->
      throw err if err?
      io.of('/ime').on 'connection', (socket) ->
        socket.emit 'ready', 'hello world'

        socket.on 'search', (list) ->
          console.log list
          q1 = {key: {$in: list}}
          q2 = {key: new RegExp "^#{list[0]}\\w+"}
          coll.find({$or: [q1, q2]}, {_id:0}).sort({count:-1})
            .toArray (err, data) ->
              console.log 'data::', data.length
              socket.emit 'search', data

        socket.on 'single', (str) ->
          if str.length is 1
            q = new RegExp "^#{str}\\w\\w$"
          else if str.length is 2
            q = new RegExp "^#{str}\\w$"
          coll.find({key: q}, {_id:0}).sort({count:-1})
            .toArray (err, data) ->
              console.log 'data::', data.length
              socket.emit 'search', data

        socket.on 'result', (obj) ->
          coll.update {key:obj.key, word:obj.word},
            {$inc: {count:1}},
            {upsert: true}