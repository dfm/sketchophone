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

factor = 255
tohex  = (r) -> (0+parseInt(factor*r).toString(16)).slice(-2)

class ColorPicker
    constructor: (@picker_img,@picker_button) ->
        this.$picker = $(this.picker_img)
        this.$button = $(this.picker_button)
        thispicker = this
        this.$button.mousedown((e) -> thispicker.toggle())
        this.color   = "#000000"
        this.clicked = false

        this.$picker.hide()
        this.$picker.css('position','absolute')

        this.$picker.mousedown((e) -> 
            thispicker.clicked = true
            return false
        )
        this.$picker.mousemove((e) -> thispicker.pick_new_color(e))
        this.$picker.mouseup((e) -> 
            thispicker.pick_new_color(e)
            thispicker.clicked = false
            thispicker.hide()
        )

    pick_new_color: (e) ->
        if this.clicked
            offset = this.$picker.offset()
            x = e.pageX-offset.left
            y = e.pageY-offset.top
            h = x/this.$picker.width()
            s = 1.0
            v = 1-y/this.$picker.height()
            [r,g,b] = hsv2rgb(h,s,v)
            color = '#'+tohex(r)+tohex(g)+tohex(b)
            this.color = color
        return false

    toggle: () ->
        if this.clicked
            this.hide()
        else
            this.show()

    show: () ->
        this.$button.addClass("selected")
        bpos = this.$button.position()
        moff = this.$button.offsetParent().offset()
        this.$picker
            .css('left',bpos.left+this.$button.width()/2-this.$picker.width()/2+"px")
        this.$picker.css('top',moff.top-this.$picker.height()+"px")
        this.$picker.show()

    hide: () ->
        this.$button.removeClass("selected")
        this.$picker.hide()

