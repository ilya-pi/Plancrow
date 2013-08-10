define ['backbone'], (Backbone) ->
    SignUpModel = Backbone.Model.extend(
        url: '/rest-crow/signup'

        initialize: ->

        validate: (attrs) ->
            if not attrs.email?
                return "Please provide your email"
            if not attrs.password?
                return "Please provide preferred password"
            if not attrs.name?
                return "Please provide name"
    )

    return SignUpModel