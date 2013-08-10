define ['backbone', 'bootstrap', '../models/SignUpModel', '../templates/LandingScreenTemplates'], (Backbone, bootstrap, SignUpModel, templates) ->
    Backbone.View.extend( # SignUpView

        template: jade.compile(templates.SignUpView)
        template_signedUp: jade.compile(templates.SignUpView_signedUp)

        events:
            'click button.signup': 'clicked_signup'
            'click button.do_signup': 'clicked_doSignup'

        initialize: ->
            _.bindAll this, 'clicked_signup', 'clicked_doSignup'
            @model.on(
                "invalid": (msg) ->
                    console.info(msg.validationError)
            );
            this

        render: ->
            @$el.html @template({})
            @$name = @$('#login-name')
            @$email = @$('#email-name')
            @$password = @$('#password-name')
            this

        render_signedUp: ->
            @$el.html @template_signedUp({})
            this

        clicked_signup: ->
            @render()

        clicked_doSignup: ->
            that = this
            @model.save(
                email: @$email.val()
                name: @$name.val()
                password: @$password.val()
            ,
                success: ->
                    that.render_signedUp()
                error: (model, error) ->
                    #todo error here
                    console.info model
                    console.info error
            )
    )