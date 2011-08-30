$(document).ready(() ->
    colorPicker   = new ColorPicker($('#color_picker').get(0),$('#color').get(0))
    currentCanvas = new Canvas($('#content').get(0),colorPicker)
    
    $('#undo').mousedown((e) -> currentCanvas.undo())
    $('#clear').mousedown((e) -> currentCanvas.clear())

    tools = 1
    toggleTools = () ->
        if tools
            $('#menu').animate({left: -$('#menu').width()+'px'},
                {duration: 200, complete: () -> $('#menu').hide()})
            $('#arrow').css({"background-position": "0px 0px"})
            tools = 0
        else
            $('#menu').show().animate({left: '0px'},
                {duration: 200})
            $('#arrow').css({"background-position": "-32px 0px"})
            tools = 1
    $('#arrow').mousedown((e) -> toggleTools())

    f = () -> window.scrollTo(0,1)
    setTimeout(f,1)
)



