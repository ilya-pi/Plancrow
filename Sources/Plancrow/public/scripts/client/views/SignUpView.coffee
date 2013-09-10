define ['backbone', 'bootstrap', 'underscore', '../models/SignUpModel', '../templates/LandingScreenTemplates'], (Backbone, bootstrap, _, SignUpModel, templates) ->
    Backbone.View.extend(

        template: _.template(templates._SignUpView)
        template_signedUp: _.template(templates._SignUpView_signedUp)

        events:
            'click button.signup': 'clicked_signup'
            'click button.do_signup': 'clicked_doSignup'

        initialize: ->
            _.bindAll this, 'clicked_signup', 'clicked_doSignup', 'highlightErrors', 'dismissErrorMessages'
            @listenTo(@model, 'invalid', @highlightErrors)
            this

        render: ->
            @$el.html @template({})
            @$name = @$('#login-name')
            @$email = @$('#email-name')
            @$password = @$('#password-name')
            @$do_signup = @$('button.do_signup')
            this

        highlightErrors: (e) ->
            @dismissErrorMessages()
            $ve
            switch @model.validationError.field
                when "name" then $ve = @$name
                when "email" then $ve = @$email
                when "password" then $ve = @$password
            _popover = $ve.popover(
                trigger: "manual",
                placement: "top",
                content: @model.validationError.message,
                template: "<div class=\"popover\"><div class=\"arrow\"></div><div class=\"popover-inner\"><div class=\"popover-content\"><p></p></div></div></div>"
            )
            $ve.popover("show")
            $ve.focus()

        dismissErrorMessages: ->
            #was not able to get rid of them by other means
            @$('.popover').remove()

        render_signedUp: ->
            @$el.html @template_signedUp({})
            this

        clicked_signup: ->
            @render()

        clicked_doSignup: ->
            @model.set(
                email: @$email.val()
                name: @$name.val()
                password: @$password.val()
            )
            if @model.isValid()
                that = this
                @$do_signup.button('loading')
                @dismissErrorMessages()
                @model.save(
                    email: @$email.val()
                    name: @$name.val()
                    password: @$password.val()
                ,
                    success: ->
                        that.$do_signup.button('reset')
                        that.render_signedUp()
                    error: (model, error) ->
                        #todo error here
                        console.info model
                        console.info error
                )
    )