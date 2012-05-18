
tag = (id) -> document.getElementById id
chars = 'qwertyuiasdfghjk'
point = undefined
ch_mode = yes
waiting = no

window.onload = ->
  window.socket = io.connect 'http://localhost:8000/ime'
  socket.on 'ready', (data) -> console.log data

  paper = tag 'paper'
  window.article =
    text: 'article:'
    elem: tag 'article'
  window.typing =
    text: ''
    elem: tag 'typing'
  window.popup =
    list: []
    elem: tag 'popup'
  chosen = []

  do render = ->
    console.log typing.text
    article.elem.innerHTML = article.text.replace(/\n/g, '<br>') +
      '<span id="cursor"></span>'
    if ch_mode
      window.cursor             = tag 'cursor'
      typing.elem.style.display = 'block'
      typing.elem.style.left    = cursor.offsetLeft
      typing.elem.style.top     = cursor.offsetTop
      typing.elem.innerText = typing.text
      
      popup.elem.style.display  = 'block'
      popup.elem.style.left     = cursor.offsetLeft
      popup.elem.style.top      = cursor.offsetTop + 18

      html = ''
      for item, index in popup.list
        insert = if index is point then " id='select'" else ''
        html += "<p#{insert}>#{item.word}</p>"
      popup.elem.innerHTML = html

      if select = tag 'select'
        length = popup.elem.clientHeight + popup.elem.scrollTop
        if select.offsetTop + 36 > length
          popup.elem.scrollTop += 18
        if select.offsetTop - 36 < popup.elem.scrollTop
          popup.elem.scrollTop -= 18
      else
        popup.elem.style.display  = 'none'
    else
      typing.elem.style.display = 'none'
      popup.elem.style.display = 'none'

  socket.on 'search', (list) ->
    if ch_mode and typing.text.length > 0
      popup.list = list.sort (x, y) ->
        (Math.abs (x.key.length - typing.text.length)) -
        (Math.abs (y.key.length - typing.text.length))
      if list.length > 0 then point = 0
      do render

  search = ->
    point = undefined
    list = [typing.text]
    piece = typing.text
    while piece.length > 3
      left = piece.length % 3
      tail = if left is 0 then piece.length-3 else piece.length-left
      piece = typing.text[0...tail]
      list.push piece
    if typing.text.length>2 then socket.emit 'search', list
    do render

  single = ->
    socket.emit 'single', typing.text

  down = ->
    if ch_mode and popup.list.length > 0
      if point < popup.list.length-1
        point += 1
        do render

  goup = -> if point?
    if ch_mode and popup.list.length > 0
      if point > 0
        point -= 1
        do render

  back = ->
    if ch_mode
      typing.text = typing.text[0...typing.text.length-1]
      if typing.text.length > 2 then do search
      else if typing.text.length > 0 then do single
      else
       typing.text = ''
       popup.list = []
       do render
    else
      article.text = article.text[0...article.text.length-1]
      do render

  enter = ->
    if ch_mode and typing.text.length > 0
      chosen.push popup.list[point]
      article.text += popup.list[point].word
      len1 = popup.list[point].key.length
      len2 = typing.text.length
      if len1 >= len2
        typing.text = ''
        popup.list = []
        do render
        result =
          key: chosen.map((x)->x.key).join ''
          word: chosen.map((x)->x.word).join ''
        socket.emit 'result', result
        chosen = []
      else
        typing.text = typing.text[len1..]
        if typing.text.length > 2
          do search
        else do single

  flip = ->
    ch_mode = if ch_mode then no else yes
    do render

  document.onkeydown = (e) ->
    code = e.keyCode
    char = (String.fromCharCode code).toLowerCase()
    if code is 38 then goup()
    else if code is 40 then down()
    else if code is 13 then enter()
    else if code is 16 then flip()
    else if code is 8  then back()
    else console.log code

  document.onkeypress = (e) ->
    char = String.fromCharCode e.charCode
    if ch_mode
      if char in chars
        typing.text += char
        if typing.text.length > 2 then do search
        else do single
    else
      article.text += char
      do render