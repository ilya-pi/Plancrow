define ['backbone', 'bootstrap', 'jquery', './SignInView', './SignUpView'], (Backbone, bootstrap, $, SignInView, SignUpView) ->
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
            @$signin.html new SignInView({}).render().el
            @signUpView = new SignUpView({el: @$signup})
            this

        clicked_moreInfo: ->
            $('html, body').animate
                scrollTop: $("#detailed").offset().top
            , 250

        clicked_bottomSignUp: ->
            that = this
            $('html, body').animate
                scrollTop: 0
            , 1000, ->
                console.info('ee')
                that.signUpView.clicked_signup()
    )