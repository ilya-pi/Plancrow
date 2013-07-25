templates =
  {}

# Only CoffeScript supports nice identations for lines, so I had to switch to it in templates

templates.TaskView =
    '''
    div.row-fluid.task.node(id="#{t.id}", data-taskid="#{t.id}", data-taskname = "#{t.name}", data-tasknotes = "#{t.notes}")
        div.span3
            span.name Task:&nbsp;#{t.name}
            div.notes(style="display:none;")= t.notes
        div.span2
            p [est.: #{t.estimate}, posted: #{t.posted}]
        div.span3
            select.assignment(style="width: 100%;", multiple)
                - for (var i = 0; i < u.length; i++) {
                    - var if_selected = ""; for (var k = 0; k < t.assignments.length; k++) { if (t.assignments[k].userlink_id == u[i].id){if_selected = "true";}}
                    option(value=u[i].id, selected=if_selected) #{u[i].user.first_name} #{u[i].user.second_name}
                - }
        div.span2.input-prepend.input-append
            button.btn.btn-mini.delete delete
            button.btn.btn-mini.details details
        div.span1
            div.btn-group.status
                a.btn.btn-mini
                    - if (t.status == "A"){
                        font Active
                    - }else if (t.status == "N"){
                        font Not Started
                    - }else if (t.status == "C"){
                        font Completed
                    - }
                a.btn.btn-mini.dropdown-toggle(data-toggle="dropdown")
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
    div.row-fluid.node
        div.span4
            span.name Task:&nbsp;
                input.editname(type="text", value=name)
    '''

templates.PhaseView =
  '''
  div.row-fluid.node
    div.span2
        span.name
            i.toggle.icon-minus-sign(title='Collapse this branch')
            &nbsp; #{name}

    div.span2.droppable(data-phase-id=id) [ drag here ]
    div.span2.input-prepend.input-append
      - if (canrm) {
        button.btn.btn-mini.rmphase(type="button", data-phase-id=id) - phase
      - }
      button.btn.btn-mini.addphase(type="button", data-phase-id=id) + subphase
      button.btn.btn-mini.addtask(type="button", data-phase-id=id) + task
  ul.subtasksnphases
  '''

templates.AssignmentView =
  '''
  td= task.name
  td.input-append(style='display: table-cell;')
    input.posttime_val(type='text', value=task.posted)
    button.btn.posttime(type='button') Post
  '''
