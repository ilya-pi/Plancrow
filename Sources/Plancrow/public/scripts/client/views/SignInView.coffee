define ['backbone', 'bootstrap', '../templates/LandingScreenTemplates'], (Backbone, bootstrap, templates) ->
    Backbone.View.extend( # SignInView

#        tag: 'form'

        template: jade.compile(templates.SignInView)

        events:
            'click .signin': 'clicked_signin'
            'click .do_signin': 'clicked_doSignin'

        initialize: ->
            _.bindAll this, 'clicked_signin'
            this

        render: ->
            @$el.html @template({})
            @$do_signin = this.$('.do_signin')
            @$error = this.$('.error')
            @$email = this.$('input.form-control#email-name')
            @$password = this.$('input.form-control#password-name')
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

        clicked_doSignin: ->
          if @$email.val().trim() is ""
            @$email.focus()
            return
          if @$password.val().trim() is ""
            @$password.focus()
            return
          that = this
          that.$do_signin.attr("disabled", "disabled")
          setTimeout(->
            that.$do_signin.removeClass("btn-primary").addClass("btn-danger")
            that.$error.css({visibility: "visible"});
            setTimeout(->
                that.$do_signin.removeAttr("disabled").removeClass("btn-danger").addClass("btn-primary")
                that.$email.focus()
            , 500)
          , 300 + Math.floor(Math.random() * (1000 - 500 + 1)) + 500)
    )