define ['backbone', 'bootstrap', 'jquery', './SignInView', '../models/SignUpModel', './SignUpView'], (Backbone, bootstrap, $, SignInView, SignUpModel, SignUpView) ->
    Backbone.View.extend( # LandingView

        el: 'body',

        events:
            'click .bottomsignup button.signup': 'clicked_bottomSignUp'
            'click .moreinfo': 'clicked_moreInfo'

        initialize: ->
            _.bindAll this, 'clicked_bottomSignUp', 'clicked_moreInfo'
            @$signin = this.$('#signin')
            @$signup = this.$('#signup')
            @$bottonsignup = this.$('#bottomsignup')
            @signInView = new SignInView({el: @$signin})
            @signUpView = new SignUpView({el: @$signup, model: new SignUpModel()})
            @post_render()
            this

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
                                that.$('#one_import, #two_enter, #three_analyze').addClass('btn-warning')
                                that.$('#one_import, #two_enter, #three_analyze').tooltip()
                            , 300)
                        , 100)
                    )
                )
            )

        clicked_moreInfo: ->
            $('body ').animate
                scrollTop: $("#importmpp").offset().top
            , 500

        clicked_bottomSignUp: ->
            that = this
            $('html, body').animate
                scrollTop: 0
            , 1000, ->
                that.signUpView.clicked_signup()
    )