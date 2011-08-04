hsv2rgb = (h,s,v) ->
    # returns [R,G,B] (each value in [0,1]) for given [H,S,V]
    # http://en.wikipedia.org/wiki/HSL_and_HSV#Converting_to_RGB
    i = Math.floor(h*6)
    f = h*6-i
    p = v*(1-s)
    q = v*(1-f*s)
    t = v*(1-(1-f)*s)

    switch (i%6)
        when 0 then [v,t,p]
        when 1 then [q,v,p]
        when 2 then [p,v,t]
        when 3 then [p,q,v]
        when 4 then [t,p,v]
        when 5 then [v,p,q]
        else [0,0,0]

$picker_img = undefined
color_picker = undefined
colorTimeout = undefined
factor = 255
tohex = (r) -> (0+parseInt(factor*r).toString(16)).slice(-2)
pick_new_color = (e) ->
    if color_picker.clicked
        offset = $picker_img.offset()
        x = e.pageX-offset.left
        y = e.pageY-offset.top
        h = x/$picker_img.width()
        s = 1.0
        v = 1-y/$picker_img.height()
        [r,g,b] = hsv2rgb(h,s,v)
        color = '#'+tohex(r)+tohex(g)+tohex(b)
        color_picker.color = color
        $("#color").css('color':color_picker.color)
    false

$(document).ready(() ->
    $menu_img = $("#color")
    $picker_img = $('#color_picker')
    $picker_img.hide()
    $picker_img.css('position','absolute')
    $picker_img.css('left',$menu_img.offset().left+$menu_img.width()/2-$picker_img.width()/2+"px")
    $picker_img.css('top',$menu_img.offset().top-$picker_img.height()-5+"px")

    $picker_img.mousedown((e) -> false)
    $picker_img.mousemove(pick_new_color)
    $picker_img.mouseup((e) ->
        pick_new_color(e)
        clicked = false
        color_picker.hide()
    )
    
    color_picker = {color: "#000000"}
    color_picker.show = () ->
        if $picker_img?
            if colorTimeout?
                clearTimeout(colorTimeout)
            color_picker.clicked = true
            $picker_img.show()
            if color_picker.timeout?
                clearTimeout(color_picker.timeout)
            color_picker.timeout = setTimeout(color_picker.hide,3000)
            $picker_img.mouseover((e) -> 
                if color_picker.timeout?
                    clearTimeout(color_picker.timeout)
            )
            $picker_img.mouseout((e) -> 
                if color_picker.timeout?
                    clearTimeout(color_picker.timeout)
                color_picker.timeout = setTimeout(color_picker.hide,3000)
            )
    color_picker.hide = () ->
        if $picker_img?
            $picker_img.hide()
            if color_picker.timeout?
                clearTimeout(color_picker.timeout)
            if colorTimeout?
                clearTimeout(colorTimeout)
    
    $("#color").mouseover((e) ->
        if colorTimeout?
            clearTimeout(colorTimeout)
        colorTimeout = setTimeout(color_picker.show,200)
        $(this).mouseout((e) -> clearTimeout(colorTimeout))
    )
)

