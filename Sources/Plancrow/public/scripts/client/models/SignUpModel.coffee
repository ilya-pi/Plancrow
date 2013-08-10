define ['backbone'], (Backbone) ->
    SignUpModel = Backbone.Model.extend(
        url: '/rest-crow/signup'

        initialize: ->

        validate: (attrs) ->
            if not attrs.name? or attrs.name.trim().length <= 0
                return {
                field: "name"
                message: "Please provide your name"
                }
            if not attrs.email? or attrs.email.trim().length <= 0
                return {
                    field: "email"
                    message: "Please provide your email"
                }
            if not attrs.password? or attrs.password.trim().length < 6
                return {
                    field: "password"
                    message: "Please provide password no shorter then 6 characters"
                }
    )

    return SignUpModel