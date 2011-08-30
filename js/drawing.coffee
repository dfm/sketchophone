context2D = (obj) -> obj.getContext('2d')
getTouchEvent = (touch) ->
    touch.originalEvent.touches[0] or touch.originalEvent.changedTouches[0]

class Canvas
    constructor: (@container, @colorPicker) ->
        $(this.container).append('<canvas id="canvas"></canvas>')
        this.canvas       = $("#canvas").get(0)
        this.context      = context2D(this.canvas)
        this.currentTool  = new Tool(this.context,this.colorPicker)
        this.undoStack    = new UndoStack(this)
        this.isPainting   = false

        # DOM object for saving current state
        this.state        = document.createElement('canvas')
        this.state.width  = this.canvas.width
        this.state.height = this.canvas.height
        this.stateContext = context2D(this.state)

        # bind mousedown events
        thisCanvas = this
        $(this.canvas)
            .bind('touchstart',(touch) -> thisCanvas.mouseDown(getTouchEvent(touch),thisCanvas,touch))
        $(this.canvas).mousedown((e) -> thisCanvas.mouseDown(e,thisCanvas))

        $(window).resize(() -> thisCanvas.resize(thisCanvas))
        this.resize()

    saveState: () ->
        this.state.width  = this.width()
        this.state.height = this.height()
        this.stateContext.drawImage(this.canvas,0,0)

    resize: (canvas=this) ->
        this.saveState()
        $canvas = $(canvas.canvas)
        width   = Math.max(Math.min($(window).width(),960),$canvas.width())
        height  = width*320/480 #$(window).height()
        $canvas.attr('width',width)
        $canvas.css('width',width+"px")
        $canvas.attr('height',height)
        $canvas.css('height',height+"px")
        if height < $(window).height()
            $(this.container).css('top',($(window).height()-height)/2+"px")
        else
            $(this.container).css('top',"0px")
        canvas.redraw()
        f = () -> window.scrollTo(0,1)
        setTimeout(f,1)

    getCoordinates: (x,y,canvas=this) ->
        offset = $(canvas.canvas).offset()
        [x-offset.left,y-offset.top]
    
    mouseDown: (e,canvas,touch) -> 
        [x,y] = canvas.getCoordinates(e.pageX,e.pageY,canvas)
        if x < 0 or y < 0 or x > this.width() or y > this.height()
            return true
        if touch?
            touch.preventDefault()
        canvas.attachDocumentBindings(canvas)
        canvas.isPainting = true
        canvas.startDrawing(x,y)
        this.resampling = 0
        false

    mousemove: (e,canvas,touch) ->
        if canvas.isPainting
            if touch?
                touch.preventDefault()
            if this.resampling = 3
                [x,y] = canvas.getCoordinates(e.pageX,e.pageY,canvas)
                canvas.moveTo(x,y)
            this.resampling += 1
            return false
        return true

    mouseup: (e,canvas,touch) ->
        if touch?
            touch.preventDefault()
        canvas.clearDocumentBindings()
        canvas.isPainting = false
        canvas.redraw()
        false

    attachDocumentBindings: (canvas) ->
        $(document).mousemove((e) -> canvas.mousemove(e,canvas))
        $(document).mouseup((e) -> canvas.mouseup(e,canvas))
        $(document)
            .bind('touchmove',(touch) -> canvas.mousemove(getTouchEvent(touch),canvas,touch))
        $(document)
            .bind('touchend',(touch) -> canvas.mouseup(getTouchEvent(touch),canvas,touch))

    clearDocumentBindings: () ->
        $(document).unbind('mousemove')
        $(document).unbind('mouseup')
        $(document).unbind('touchmove')
        $(document).unbind('touchend')

    width: () -> this.canvas.width
    height: () -> this.canvas.height

    clear: () ->
        this.canvas.width = this.canvas.width
        this.saveState()
        this.redraw()
        this.undoStack.clear()

    getImage: () ->
        this.canvas

    drawImage: (img,x=0,y=0) ->
        this.canvas.width = this.canvas.width
        this.context.drawImage(img,x,y)

    redraw: () ->
        this.drawImage(this.state)
        this.currentTool.finalize()

    startDrawing: (x,y) ->
        this.undoStack.update()
        this.saveState()
        this.currentTool.startDrawing(x,y)

    moveTo: (x,y) ->
        this.currentTool.moveTo(x,y)

    finalize: () ->
        this.drawImage(this.state)
        currentTool.finalize()

    undo: () -> this.undoStack.undo()

class UndoStack
    constructor: (@canvas) ->
        this.stack = []

    update: () ->
        tmp_canvas = document.createElement('canvas')
        tmp_canvas.width  = this.canvas.width()
        tmp_canvas.height = this.canvas.height()
        context2D(tmp_canvas).drawImage(this.canvas.getImage(),0,0)
        this.stack.push(tmp_canvas)
        if this.stack.length >= 10 # MAGIC: maximum stack size
            tmp_canvas = this.stack[0]
            this.stack.splice(0,1)
            $(tmp_canvas).remove()

    undo: () ->
        if this.stack.length >= 1
            tmp_canvas = this.stack.pop()
            this.canvas.drawImage(tmp_canvas)
            $(tmp_canvas).remove()

    clear: () ->
        for i in [0...this.stack.length]
            tmp_canvas = this.stack.pop()
            $(tmp_canvas).remove()

class Tool
    constructor: (@context,@colorPicker) ->
        this.currentPosition  = undefined
        this.previousPosition = undefined
        this.currentPath      = undefined

    setLineStyles: () ->
        this.context.strokeStyle = this.colorPicker.color || 'black'
        this.context.lineWidth = 3
        this.context.lineJoin = "round"
        this.context.lineCap = "round"

    startDrawing: (x,y) ->
        this.setLineStyles()
        this.context.beginPath()
        this.context.moveTo(x,y)
        this.currentPosition = {x:x-0.1,y:y-0.1}
        this.currentPath = [this.currentPosition]
        this.moveTo(x+0.1,y+0.1)
        this.resampling = 0

    moveTo: (x,y) ->
        pt0 = this.currentPosition
        this.context.quadraticCurveTo(pt0.x,pt0.y,pt0.x+(x-pt0.x)/2,pt0.y+(y-pt0.y)/2)
        this.context.stroke()
        this.currentPosition = {x:x,y:y}
        this.currentPath.push(this.currentPosition)

    finalize: () ->
        if this.currentPath? && this.currentPath.length > 1
            pt0 = this.currentPath[0]
            this.setLineStyles()
            this.context.beginPath()
            this.context.moveTo(pt0.x,pt0.y)
            for i in [1...this.currentPath.length]
                pt = this.currentPath[i]
                this.context.quadraticCurveTo(pt0.x,pt0.y,pt0.x+(pt.x-pt0.x)/2,pt0.y+(pt.y-pt0.y)/2)
                pt0 = this.currentPath[i]
            this.context.stroke()
            this.currentPath = undefined
            this.currentPosition = undefined

