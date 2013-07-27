(($) ->
    jade = require("jade")

    if not window.app?
        window.app =
            {}

    window.app.CrowModal = Backbone.Model.extend({
    title: "Crow Modal Window",
    message: "Crow modal window question"
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
) jQuery