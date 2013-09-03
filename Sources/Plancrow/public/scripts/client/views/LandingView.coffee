define ['backbone', 'bootstrap', 'jquery', './SignInView', '../models/SignUpModel',
        './SignUpView'], (Backbone, bootstrap, $, SignInView, SignUpModel, SignUpView) ->
    Backbone.View.extend(# LandingView

        el: 'body',

        events:
            'click .bottomsignup button.signup': 'clicked_bottomSignUp'
            'click .moreinfo': 'clicked_moreInfo'
            'click #one_import': 'clicked_import'
            'click #two_enter': 'clicked_enter'
            'click #three_analyze': 'clicked_analyze'

        initialize: ->
            _.bindAll this, 'clicked_bottomSignUp', 'clicked_moreInfo'
            _.bindAll this, 'clicked_import', 'clicked_enter', 'clicked_analyze', 'signedUp'
            @$signin = this.$('#signin')
            @$signup = this.$('#signup')
            @$bottonsignup = this.$('.bottomsignup')
            @signInView = new SignInView({el: @$signin})
            signUpModel = new SignUpModel()
            @signUpView = new SignUpView({el: @$signup, model: signUpModel})
            @listenTo(signUpModel, 'sync', @signedUp)
            @post_render()
            this

        signedUp: ->
            @$signin.remove()
            @$bottonsignup.remove()

        post_render: ->
            that = this
            @$('#one_import').animate(
                opacity: "1"
            , 750, ->
                that.$('#two_enter').animate(
                    opacity: "1"
                , 750, ->
                    that.$('#three_analyze').animate(
                        opacity: "1"
                    , 750, ->
                        setTimeout(->
                            that.$('#one_import, #two_enter, #three_analyze').removeClass('btn-warning').addClass('btn-danger')
                            setTimeout(->
                                that.$('#one_import, #two_enter, #three_analyze').removeClass('btn-danger').addClass('btn-warning')
                                that.$('#one_import, #two_enter, #three_analyze').tooltip()
                            , 300)
                        , 150)
                    )
                )
            )

        clicked_moreInfo: ->
            $('body').animate
                scrollTop: $("article#importmpp").offset().top
            , 500

        clicked_import: ->
            $('body').animate
                scrollTop: $("article#importmpp").offset().top
            , 500

        clicked_enter: ->
            $('body ').animate
                scrollTop: $("article#tracktime").offset().top
            , 500

        clicked_analyze: ->
            $('body ').animate
                scrollTop: $("article#analyze").offset().top
            , 500

        clicked_bottomSignUp: ->
            that = this
            $('html, body').animate
                scrollTop: $("#signupsection").offset().top
            , 1000, ->
                that.signUpView.clicked_signup()
    )