define ['backbone', '../collections/TimePostingList', './TimePostingItemView', '../templates/PostTimeScreenTemplates'], (Backbone, TimePostingList, TimePostingItemView, templates) ->
    Backbone.View.extend( # PostTimeView

        el: '#posttimescreen',

        template: jade.compile(templates.PostTimeScreenView)

        initialize: ->
            @render()
            @$timepostings = this.$('#timepostings');
            @posting_items = new TimePostingList()
            this.listenTo(@posting_items, 'add', @addPostingItemView)
            @posting_items.fetch({url: '/json/task/assigned'})

        render: ->
            #timepostings
            @$el.html @template({})
            this

        addPostingItemView: (time_posting_model) ->
            new_view = new TimePostingItemView
                model: time_posting_model
            @$timepostings.append new_view.render().el

    )