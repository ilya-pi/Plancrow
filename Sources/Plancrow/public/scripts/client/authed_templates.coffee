templates =
  {}

# Only CoffeScript supports nice identations for lines, so I had to switch to it in templates

templates.TaskView =
    '''
    div.row.task.node(id="#{t.id}", data-taskid="#{t.id}", data-taskname = "#{t.name}", data-tasknotes = "#{t.notes}")
        div.col-lg-3
            span.name(class=t.status)
                i.icon-tasks
                &nbsp;#{t.name}
            div.notes(style="display:none;")= t.notes
        div.col-lg-1
            small(rel='tooltip', data-toggle='tooltip', title='posted / estimate') #{t.posted_str} /&nbsp;#{t.estimate_str}
        div.col-lg-3
            select.assignment(style="width: 100%;", multiple)
                - for (var i = 0; i < u.length; i++) {
                    - var if_selected = ""; for (var k = 0; k < t.assignments.length; k++) { if (t.assignments[k].userlink_id == u[i].id){if_selected = "true";}}
                    option(value=u[i].id, selected=if_selected) #{u[i].user.first_name} #{u[i].user.second_name}
                - }
        div.col-lg-4.btn-toolbar
            div.btn-group
                button.btn.btn-default.btn-small.delete delete
                button.btn.btn-default.btn-small.details details
            div.btn-group.status
                button.btn.btn-default.btn-small.status
                    - if (t.status == "A"){
                        font Active
                    - }else if (t.status == "N"){
                        font Not Started
                    - }else if (t.status == "C"){
                        font Completed
                    - }
                button.btn.btn-default.btn-small.dropdown-toggle(data-toggle="dropdown")
                    span.caret
                ul.dropdown-menu(role = "menu")
                    li(role = "presentation")
                        a(role = "menuitem", data-status="A") Active
                    li(role = "presentation")
                        a(role = "menuitem", data-status="N") Not Started
                    li.divider
                    li(role = "presentation")
                            a(role = "menuitem", data-status="C") Completed
    '''

templates.TaskEditView =
    '''
    div.row.node
        div.col-lg-4
            span.name Task:&nbsp;
                input.editname(type="text", value=name)
    '''

templates.PhaseView =
  '''
  div.row.node
    div.col-lg-4
        span.name
            i.toggle.icon-minus-sign(title='Collapse this branch')
            span.editable
                span.editarea &nbsp; #{name}
    div.col-lg-2.estimateNOTSHOW
    div.col-lg-2.droppable(data-phase-id=id) [ drag here ]
    div.col-lg-4.btn-group
        button.btn.btn-default.btn-small.rmphase(type="button", data-phase-id=id) delete
        button.btn.btn-default.btn-small.addphase(type="button", data-phase-id=id)
            i.icon-plus
            &nbsp;sub-phase
        button.btn.btn-default.btn-small.addtask(type="button", data-phase-id=id)
            i.icon-plus
            &nbsp;task
  ul.subtasksnphases
  '''

templates.PhaseEditView =
    '''
    form
        fieldset
            .form-group
                label Name
                input.editname.form-control(type='text', value=name)
            .form-group(rel='tooltip', data-toggle='tooltip', data-placement='bottom', title='Short name is always visible when posting time. This differentiates tasks with same names in different phases')
                label Short name
                input.editshort_name.form-control(type='text', value=short_name)
            .form-group
                label Notes
                textarea.editnotes.form-control(type='text')= notes
            button.btn.btn-success.save(type="button", data-phase-id=id) Save
    '''

templates.PhaseDoneEditingView =
    '''
    span.editarea &nbsp; #{name}
    '''

templates.AssignmentView =
  '''
  td= task.name
  td.input-append(style='display: table-cell;')
    input.posttime_val(type='text', value=task.posted)
    button.btn.posttime(type='button') Post
  '''
