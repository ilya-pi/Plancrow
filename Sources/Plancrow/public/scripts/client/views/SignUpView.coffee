define ['backbone', 'bootstrap', '../templates/LandingScreenTemplates'], (Backbone, bootstrap, templates) ->
    Backbone.View.extend( # SignUpView

        template: jade.compile(templates.SignUpView)

        events:
            'click button.signup': 'clicked_signup'

        initialize: ->
            _.bindAll this, 'clicked_signup'
            this

        render: ->
            @$el.html @template({})
            this

        clicked_signup: ->
            @render()
#            @$save_button.button('loading')
#            setTimeout(->
#                that.$save_button.button('reset')
#                console.info 'hihi-saved'
#            ,1000)
    )