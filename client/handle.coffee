
tag = (id) -> document.getElementById id

window.onload = ->

  window.socket = io.connect 'http://localhost:8000/ime'
  socket.on 'ready', (data) -> console.log data
  socket.on 'search', (data) -> console.log data

  paper = tag 'paper'
  window.box = tag 'box'
  words = 'erwerwerw\nwerwerwer333'
  popup = ['aaa', 'bbb', 'ccc']
  select = 0

  render = ->
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