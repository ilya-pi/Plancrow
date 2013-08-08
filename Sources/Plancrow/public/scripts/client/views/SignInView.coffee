define ['backbone', 'bootstrap', '../templates/LandingScreenTemplates'], (Backbone, bootstrap, templates) ->
    Backbone.View.extend( # SignInView

#        tag: 'form'

        template: jade.compile(templates.SignInView)

        events:
            'click .signin': 'clicked_signin'

        initialize: ->
            _.bindAll this, 'clicked_signin'
            this

        render: ->
            @$el.html @template({})
            this

        clicked_signin: ->
            that = this
            console.info("clicked signin")
            @render()
            @$('#myModal').modal()
#            @$save_button.button('loading')
#            setTimeout(->
#                that.$save_button.button('reset')
#                console.info 'hihi-saved'
#            ,1000)
    )