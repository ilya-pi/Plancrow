common_templates =
    {}

common_templates.CrowModalView =
    '''
    .modal-dialog
        .modal-content
            .modal-header
                button.close(type='button', data-dismiss='modal', aria-hidden='true') ×
                h4.modal-title= title
            .modal-body
                p= message
            .modal-footer
                - if (typeof severe !== "undefined" && severe !== null && severe) {
                    button.btn.btn-danger.btn-mini.yes(type='button', data-dismiss='modal') Yes
                    button.btn.btn-primary.no(type='button') No
                    button.btn.btn-primary.btn-large.no(type='button') No
                - }else {
                    button.btn.btn-default.yes(type='button', data-dismiss='modal') Yes
                    button.btn.btn-primary.no(type='button') No
                - }
    '''

common_templates.CrowInfoModalView =
    '''
    .modal-dialog
        .modal-content
            .modal-header
                button.close(type='button', data-dismiss='modal', aria-hidden='true') ×
                h4.modal-title= title
            .modal-body
                p= message
            .modal-footer
                button.btn.btn-default.ok(type='button') Okay
    '''
