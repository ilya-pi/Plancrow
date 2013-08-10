define [], () ->
    templates = new Array()

    templates.SignInView =
        '''
        span or&nbsp;
            a.signin(href='#') Sign In
        #myModal.modal.fade
            .modal-dialog
                .modal-content
                    .modal-header
                        button.close(type='button', data-dismiss='modal', aria-hidden='true') ×
                        h4.modal-title Sign In
                    .modal-body
                        form
                            fieldset
                            .form-group
                                input.form-control#email-name(type="text", placeholder="E-Mail")
                            .form-group
                                input.form-control#password-name(type="password", placeholder="Password")
                            a(href="forgot password") Forgot password?
                    .text-center.modal-footer
                        button.signup.btn.btn-primary(href='#') Sign In
        '''

    templates.SignUpView =
        '''
        fieldset
            .form-group
                input.form-control#login-name(type="text", placeholder="Enter your name")
            .form-group
                input.form-control#email-name(type="text", placeholder="E-Mail")
            .form-group
                input.form-control#password-name(type="password", placeholder="Password")
            .form-group
                button.do_signup.btn.btn-primary Sign Up
        '''

    templates.SignUpView_signedUp =
        '''
        .well(style="display: inline-block; width: 75% !important")
            h4 Thank you for your interest in our product!
            p We are going through private alpha at the moment,
            | release is planned in mid-September 2013.
        '''
    return templates
