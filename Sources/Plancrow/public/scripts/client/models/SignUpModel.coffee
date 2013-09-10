define ['backbone'], (Backbone) ->
    SignUpModel = Backbone.Model.extend(
        url: '/rest-crow/signup'

        initialize: ->

#        validEmail: (email) ->
#            re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
#            return re.test(email);

#        validEmail: (email) ->
#            qtext = '[^\\x0d\\x22\\x5c\\x80-\\xff]'
#            dtext = '[^\\x0d\\x5b-\\x5d\\x80-\\xff]'
#            atom = '[^\\x00-\\x20\\x22\\x28\\x29\\x2c\\x2e\\x3a-'
#            atom += '\\x3c\\x3e\\x40\\x5b-\\x5d\\x7f-\\xff]+'
#            quoted_pair = '\\x5c[\\x00-\\x7f]'
#            domain_literal = "\\x5b(?:" + dtext + "|" + quoted_pair + ")*\\x5d"
#            quoted_string = "\\x22(?:" + qtext + "|" + quoted_pair + ")*\\x22"
#            domain_ref = atom
#            sub_domain = "(?:" + domain_ref + "|" + domain_literal + ")"
#            word = "(?:" + atom + "|" + quoted_string + ")"
#            domain = sub_domain + "(?:\\x2e" + sub_domain + ")*"
#            local_part = word + "(?:\\x2e" + word + ")*"
#            addr_spec = local_part + "\\x40" + domain
#            pattern = "^" + addr_spec + "$"
#            return (new RegExp(pattern)).test(email)

        validate: (attrs) ->
            if not attrs.name? or attrs.name.trim().length <= 0
                return {
                field: "name"
                message: "Please provide your name"
                }
#            if not attrs.email? or attrs.email.trim().length <= 0 or not @validEmail(attrs.email)
            if not attrs.email? or attrs.email.trim().length <= 0
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