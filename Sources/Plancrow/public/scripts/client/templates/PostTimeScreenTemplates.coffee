define [], () ->
    templates.TimePostingItemView =
        '''
        td= task.name
        td
            input(type='text', value=task.posted)
            button.btn.default-button.save(type='button') Post
        '''

    templates.PostTimeScreenView =
        '''
        table.table.table-bordered
            caption Assigned tasks, and those you've posted before
            thead
                tr
                    th Full qualified task name
                    th Time (millis)
            tbody#timepostings
        '''
    return templates