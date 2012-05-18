
tag = (id) -> document.getElementById id

chars = 'qwertyuiasdfghjk'

window.onload = ->

  window.socket = io.connect 'http://localhost:8000/ime'
  socket.on 'ready', (data) -> console.log data

  paper = tag 'paper'
  window.box = tag 'box'
  words = 'erwerwerw\nwerwerwer333'
  using = ''
  fetch = []
  popup = ['aaa', 'bbb', 'ccc']
  select = 0
  result = []

  render = ->
    popup = [using].concat (item.word for item in fetch)

    paper.innerHTML = words.replace(/\n/g, '<br>')
    paper.innerHTML+= '<span id="cursor"></span>'
    window.cursor = tag 'cursor'
    box.style.left = cursor.offsetLeft
    box.style.top = cursor.offsetTop
    html = ''
    for item, index in popup
      insert = if index is select then " id='select'" else ''
      html += "<p#{insert}>#{item}</p>"
    box.innerHTML = html

  do render
  socket.on 'search', (list) ->
    fetch = list
    do render

  search = (using) ->
    list = [using]
    piece = using
    while piece.length > 3
      left = piece.length % 3
      tail = if left is 0 then piece.length-3 else piece.length-left
      piece = using[0...tail]
      list.push piece
    if using.length>2 then socket.emit 'search', list else
      fetch = []
      do render

  add = (char) ->
    using+= char
    search using

  down = ->
    console.log 'down'

  goup = ->
    console.log 'goup'

  back = ->
    using = using[0...using.length-1]
    search using

  enter = ->
    console.log 'enter'

  document.onkeydown = (e) ->
    code = e.keyCode
    char = (String.fromCharCode code).toLowerCase()
    if char in chars then add char
    else if code is 38 then goup()
    else if code is 40 then down()
    else if code is 13 then enter()
    else if code is 8  then back()
    else console.log code