$(document).ready(() ->
    window.scrollTo(0,0)
)

aspect = 1.61803399

$canvas = $('#canvas')
width = $(window).width()-50
height = width/aspect
if height > $(window).height() - 100
    height = $(window).height() - 100
    width = height*aspect
$canvas.attr('width',width)
$canvas.css('width',width+"px")
$canvas.attr('height',height)
$canvas.css('height',height+"px")
$here = $("#here")
$arrow = $("#arrow")
$arrow.css('position','absolute')
$arrow.css('top',$here.offset().top+"px")
$arrow.css('left',$here.offset().left+"px")

canvas  = $('#canvas').get(0)
context = canvas.getContext('2d')

# create out-of-DOM canvas to save state so that we don't have to keep re-drawing
# http://stackoverflow.com/questions/5697617/drawimage-using-todataurl-of-an-html5-canvas
state        = document.createElement('canvas')
state.width  = canvas.width
state.height = canvas.height
statecontext = state.getContext('2d')

# config
amplitude = 3
elasticity = 0.5

# drawing
path = []
setLineStyles = () ->
    context.strokeStyle = color_picker.color || 'black'
    context.lineWidth = 3
    context.lineJoin = "round"
    context.lineCap = "round"
startPath = (x,y) ->
    state.width = state.width
    statecontext.drawImage(canvas,0,0)
    setLineStyles()
    context.beginPath()
    context.moveTo(x,y)
    path = [{x:x-0.1,y:y-0.1}]
    path.push({x:x+0.1,y:y+0.1})
dist = (x0,y0,x,y) ->
    dx = x-x0
    dy = y-y0
    Math.sqrt(dx*dx+dy*dy)
pathTo = (x,y) ->
    pt0 = path[path.length-1]
    context.quadraticCurveTo(pt0.x,pt0.y,pt0.x+(x-pt0.x)/2,pt0.y+(y-pt0.y)/2)
    context.stroke()
    pt = {x:x,y:y}
    path.push(pt)
redraw = () ->
    canvas.width = canvas.width
    context.drawImage(state,0,0)
    if path.length > 1
        pt0 = path[0]
        setLineStyles()
        context.beginPath()
        context.moveTo(pt0.x,pt0.y)
        for i in [1...path.length]
            pt = path[i]
            context.quadraticCurveTo(pt0.x,pt0.y,pt0.x+(pt.x-pt0.x)/2,pt0.y+(pt.y-pt0.y)/2)
            pt0 = path[i]
        context.stroke()
        path = []

undo_sketch = () ->
    redraw()
clear_sketch = () ->
    canvas.width = canvas.width
    state.width = state.width
    redraw()

# event handling
paint = false
getcanvascoords = (x,y) ->
    offset = $("#canvas").offset()
    return [x-offset.left,y-offset.top]
mousedown = (e) -> 
    set_bindings()
    [x,y] = getcanvascoords(e.pageX,e.pageY)
    paint = true
    startPath(x,y)
    false
mousemove = (e) ->
    if paint
        [x,y] = getcanvascoords(e.pageX,e.pageY)
        pathTo(x,y)
    false
mouseup = (e) ->
    clear_bindings()
    paint = false
    redraw()
    false

# binding
getTouchEvent = (touch) ->
    touch.preventDefault()
    touch.originalEvent.touches[0] or touch.originalEvent.changedTouches[0]
$('#canvas')
    .bind('touchstart',(touch) -> mousedown(getTouchEvent(touch)))
$('#canvas').mousedown(mousedown)

set_bindings = () ->
    $(document).mousemove(mousemove)
    $(document).mouseup(mouseup)
    $(document)
        .bind('touchmove',(touch) -> mousemove(getTouchEvent(touch)))
    $(document)
        .bind('touchend',(touch) -> mouseup(getTouchEvent(touch)))
clear_bindings = () ->
    $(document).unbind('mousemove')
    $(document).unbind('mouseup')
    $(document).unbind('touchmove')
    $(document).unbind('touchend')


