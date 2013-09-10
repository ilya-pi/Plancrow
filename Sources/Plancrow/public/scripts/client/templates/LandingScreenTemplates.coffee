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
                            p.error(style="color: #e74c3c; visibility:hidden;") Wrong e-mail or password
                            a(href="forgot password") Forgot password?
                    .text-center.modal-footer
                        button.do_signin.btn.btn-primary(href='#') Sign In
        '''

    templates._SignInView =
        '''
        <span> or&nbsp;<a class="signin" href="#">Sign In</a></span>
        <div id="myModal" class="modal fade">
          <div class="modal-dialog">
            <div class="modal-content">
               <div class="modal-header">
                  <button class="close" type="button" data-dismiss="modal" aria-hidden="true">×</button>
                  <h4 class="modal-title">Sign In</h4></div>
                <div class="modal-body">
                  <form>
                    <fieldset>
                      <div class="form-group">
                        <input class="form-control" id="email-name" type="text" placeholder="E-Mail"></div>
                      <div class="form-group">
                        <input class="form-control" id="password-name" type="password" placeholder="Password"></div>
                        </fieldset>
                    <p class="error" style="color: #e74c3c; visibility:hidden;">Wrong e-mail or password</p>
                    <a href="forgot_password">Forgot password?</a></form></div>
                 <div class="text-center modal-footer">
                  <button class="do_signin btn btn-primary" href="#">Sign In</button></div></div></div></div>
        '''

    templates._SignUpView =
        '''
            <fieldset>
              <div class="form-group">
                <input class="form-control" id="login-name" type="text" placeholder="Enter your name"/></div>
              <div class="form-group">
                <input class="form-control" id="email-name" type="text" placeholder="E-Mail"/></div>
              <div class="form-group hidden">
                <input class="form-control" id="password-name" type="password" placeholder="Password" value="123qwerty"/></div>
              <div class="form-group">
                <input class="checkbox" type="checkbox" checked>
                  I accept <a href="/terms" target="_blank">Terms&nbsp;<span class="amp">&amp;&nbsp;</span>Privacy</a>
                  </input></div>
              <div class="form-group">
                <button class="do_signup btn btn-primary" data-loading-text="Signing up…">Sign Up</button></div></fieldset>
        '''


    templates._SignUpView_signedUp =
        '''
        <div class="well" style="display: inline-block; width: 75% !important">
          <h4>Thank you for your interest in our product!</h4>
          <p>We are going through private alpha at the moment, polishing and adding the awesomeness. Release is planned in mid-November 2013.</p></div>
        '''

    return templates
