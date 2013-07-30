(($) ->
    jade = require("jade")

    if not window.app?
        window.app =
            {}

    window.app.CrowModal = Backbone.Model.extend({
    title: "Crow Modal Window",
    message: "Crow modal window question"
    severe: false
    cb: ->
        console.info "empty callback"
    })

    window.app.CrowModalView = Backbone.View.extend(
        events:
            "click .yes": "yes"
            "click .no": "no"
        template: jade.compile(common_templates.CrowModalView)

        initialize: ->
            _.bindAll this, "render", "show", "yes", "no", "close"

        render: ->
            @$el.addClass "modal"
            @$el.html @template(@model.attributes)
            this

        show: ->
            that = this
            $(document.body).append @render().el
            @$el.modal('show')
            @$el.on 'hidden.bs.modal', ->
                that.close()

        yes: ->
            @model.attributes.cb(true)
            @close()

        no: ->
            @model.attributes.cb(false)
            @close()

        close: ->
            @$el.modal('hide')
            @remove()
    )

    window.app.CrowInfoModal = Backbone.Model.extend({
    title: "Crow Info Modal Window",
    message: "Crow info modal window question"
    cb: ->
        console.info "empty callback"
    })
    window.app.CrowInfoModalView = Backbone.View.extend(
        events:
            "click .ok": "ok"
        template: jade.compile(common_templates.CrowInfoModalView)

        initialize: ->
            _.bindAll this, "render", "show", "ok", "close"

        render: ->
            @$el.addClass "modal"
            @$el.html @template(@model.attributes)
            this

        show: ->
            that = this
            $(document.body).append @render().el
            @$el.modal('show')
            @$el.on 'hidden.bs.modal', ->
                that.close()

        ok: ->
            @model.attributes.cb()
            @close()

        close: ->
            @$el.modal('hide')
            @remove()
    )

    window.app.DraggableView = Backbone.View.extend(
        initialize: ->
            @$el.attr "draggable", "true"
            @$el.bind "dragstart", _.bind(@_dragStartEvent, this)

        _dragStartEvent: (e) ->
            data = undefined
            e = e.originalEvent  if e.originalEvent
            e.dataTransfer.effectAllowed = "copy"
            # default to copy
            data = @dragStart(e.dataTransfer, e)
            window._backboneDragDropObject = null
            window._backboneDragDropObject = data  if data isnt `undefined` # we cant bind an object directly because it has to be a string, json just won't do

        dragStart: (dataTransfer, e) ->
            this
    )

    window.app.DroppableView = Backbone.View.extend(
        initialize: ->
            @$el.bind "dragover", _.bind(@_dragOverEvent, this)
            @$el.bind "dragenter", _.bind(@_dragEnterEvent, this)
            @$el.bind "dragleave", _.bind(@_dragLeaveEvent, this)
            @$el.bind "drop", _.bind(@_dropEvent, this)
            @_draghoverClassAdded = false

        _dragOverEvent: (e) ->
            e = e.originalEvent  if e.originalEvent
            data = @_getCurrentDragData(e)
            if @dragOver(data, e.dataTransfer, e) isnt false
                e.preventDefault()  if e.preventDefault
                e.dataTransfer.dropEffect = "copy" # default

        _dragEnterEvent: (e) ->
            e = e.originalEvent if e.originalEvent
            e.preventDefault() if e.preventDefault

        _dragLeaveEvent: (e) ->
            e = e.originalEvent if e.originalEvent
            data = @_getCurrentDragData(e)
            @dragLeave data, e.dataTransfer, e

        _dropEvent: (e) ->
            e = e.originalEvent if e.originalEvent
            data = @_getCurrentDragData(e)
            e.preventDefault() if e.preventDefault
            e.stopPropagation() if e.stopPropagation
            # stops the browser from redirecting
            @$el.removeClass "draghover"  if @_draghoverClassAdded
            @drop data, e.dataTransfer, e

        _getCurrentDragData: (e) ->
            data = null
            data = window._backboneDragDropObject  if window._backboneDragDropObject
            data

        dragOver: (data, dataTransfer, e) ->
            # optionally override me and set dataTransfer.dropEffect, return false if the data is not droppable
            @$el.addClass "draghover"
            @_draghoverClassAdded = true

        dragLeave: (data, dataTransfer, e) ->
            # optionally override me
            @$el.removeClass "draghover"  if @_draghoverClassAdded

        drop: (data, dataTransfer, e) ->
            console.info 'override me'
    )

    formatFloat = (val) ->
        Math.round(val * 100) / 100

    window.app._formatEstimate = (millis) ->
        #glob is set up in the page earlier
        switch glob.time_unit
            when 'D', 'd'
                return '' + formatFloat(millis / (8 * 60 * 60 * 1000)) + 'd'
            when 'H', 'h'
                return '' + formatFloat(millis / (60 * 60 * 1000)) + 'h'
        return 'n/a d'
) jQuery