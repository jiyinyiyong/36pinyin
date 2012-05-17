
app = (require 'http').createServer (req, res) ->
  res.end 'world?'

io = (require 'socket.io').listen app, {origins: '*:*'}
io.set 'log level', 1

app.listen 8000

url = 'mongodb://nodejs:nodepasswd@localhost:27017/ime'
(require 'mongodb').connect url, (err, db) ->
  throw err if err?
  io.of('/ime').on 'connection', (socket) ->
    socket.emit 'ready', 'hello world'