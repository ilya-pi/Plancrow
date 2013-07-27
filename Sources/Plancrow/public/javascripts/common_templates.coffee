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
                button.btn.btn-default.yes(type='button', data-dismiss='modal') Yes
                button.btn.btn-primary.no(type='button') No
    '''