define [], () ->
    templates = new Array()

    templates.SignInView =
        '''
        p Sign In Form :tbd
        '''

    templates.SignUpView =
        '''
        form
            fieldset
                .form-group
                    input.form-control#login-name(type="text", placeholder="Enter your name")
                .form-group
                    input.form-control#email-name(type="text", placeholder="E-Mail")
                .form-group
                    input.form-control#password-name(type="password", placeholder="Password")
                .form-group
                    button.signup.btn.btn-primary(href='#') Sign Up
        '''
    return templates
