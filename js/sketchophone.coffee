$(document).ready(() ->
    currentCanvas = new Canvas($('#canvas').get(0))
    
    $('#undo').mousedown((e) -> currentCanvas.undo())
    $('#clear').mousedown((e) -> currentCanvas.clear())

    f = () -> window.scrollTo(0,1)
    setTimeout(f,1)
)



