canvas  = $('#canvas').get(0)
context = canvas.getContext('2d')

# create out-of-DOM canvas to save state so that we don't have to keep re-drawing
# http://stackoverflow.com/questions/5697617/drawimage-using-todataurl-of-an-html5-canvas
state        = document.createElement('canvas')
state.width  = canvas.width
state.height = canvas.height
statecontext = state.getContext('2d')

# drawing
path = []
startPath = (x,y) ->
    state.width = state.width
    statecontext.drawImage(canvas,0,0)
    path = [[x,y]]
    redraw()
pathTo = (x,y) ->
    path.push([x,y])
    redraw()
redraw = () ->
    canvas.width = canvas.width
    context.drawImage(state,0,0)
    context.strokeStyle = "#df4b26"
    context.lineWidth = 3
    context.lineJoin = "round"
    context.beginPath()
    context.moveTo(path[0][0],path[0][1])
    for i in [1...path.length]
        context.lineTo(path[i][0],path[i][1])
    context.stroke()
window.undo = () ->
    canvas.width = canvas.width
    context.drawImage(state,0,0)
window.clear = () ->
    canvas.width = canvas.width

# event handling
paint = false
$('#canvas')
    .mousedown((e) ->
        offset = $(this).offset()
        x = e.pageX - offset.left
        y = e.pageY - offset.top
        paint = true
        startPath(x,y)
        false
    )
$('#canvas')
    .mousemove((e) ->
        if paint
            offset = $(this).offset()
            x = e.pageX - offset.left
            y = e.pageY - offset.top
            pathTo(x,y)
    )
$('#canvas')
    .mouseup((e) ->
        paint = false
    )

