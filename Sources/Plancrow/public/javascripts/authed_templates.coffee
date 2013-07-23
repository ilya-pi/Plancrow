templates =
  {}

# Only CoffeScript supports nice identations for lines, so I had to switch to it in templates

templates.PhaseView =
  """
  font Phase: #{name}
  div.row-fluid
    div.span2.droppable(data-phase-id=id) [ drag here ]
    div.span2.input-prepend.input-append
      - if (canrm) {
        button.btn.btn-mini.rmphase(type="button", data-phase-id=id) - phase
      - }
      button.btn.btn-mini.addphase(type="button", data-phase-id=id) + subphase
      button.btn.btn-mini.addtask(type="button", data-phase-id=id) + task
  ul.children
  ul.tasks
  """

templates.AssignmentView =
  """
  td= task.name
  td.input-append(style='display: table-cell;')
    input.posttime_val(type='text', value=task.posted)
    button.btn.posttime(type='button') Post
  """
