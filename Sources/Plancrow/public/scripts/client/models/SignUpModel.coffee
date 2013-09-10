define ['backbone'], (Backbone) ->
    SignUpModel = Backbone.Model.extend(
        url: '/rest-crow/signup'

        initialize: ->

        validEmail: (email) ->
            re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
            return re.test(email);

        validate: (attrs) ->
            if not attrs.name? or attrs.name.trim().length <= 0
                return {
                field: "name"
                message: "Please provide your name"
                }
            if not attrs.email? or attrs.email.trim().length <= 0 or not @validEmail(attrs.email)
                return {
                field: "email"
                message: "Please provide valid email"
                }
            if not attrs.password? or attrs.password.trim().length < 6
                return {
                field: "password"
                message: "Please provide password no shorter then 6 characters"
                }
    )

    return SignUpModel