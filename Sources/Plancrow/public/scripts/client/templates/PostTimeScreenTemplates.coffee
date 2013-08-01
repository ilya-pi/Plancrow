define [], () ->
    templates.TimePostingItemView =
        '''
        td
            small.more_info.text-muted
            p &nbsp;#{name}
        td
            input(type='text', value='')
        td
            input(type='text', value='')
        td
            input(type='text', value='')
        td
            input(type='text', value='')
        td
            input(type='text', value='')
        '''

    templates.PostTimeScreenView =
        '''
        table.table.table-bordered.table-hover
            caption Assigned tasks, and those you've posted to before
            thead
                tr
                    th(rowspan='2') Full qualified task name
                    th(colspan='5').text-center Time (millis)
                tr
                    th.text-center Monday
                    th.text-center Tuesday
                    th.text-center Wednesday
                    th.text-center Thursday
                    th.text-center Friday
            tbody#timepostings
        button.pull-right(type="button", data-loading-text="Saving...").btn.btn-success.save Save
        '''
    return templates