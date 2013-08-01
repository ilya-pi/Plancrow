define ['backbone', 'bootstrap', '../collections/TimePostingList', './TimePostingItemView', '../templates/PostTimeScreenTemplates'], (Backbone, bootstrap, TimePostingList, TimePostingItemView, templates) ->
    Backbone.View.extend( # PostTimeView

        el: '#posttimescreen',

        template: jade.compile(templates.PostTimeScreenView)

        events:
            'click button.save': 'clicked_save'

        initialize: ->
            _.bindAll this, 'clicked_save'
            @render()
            @$timepostings = this.$('#timepostings');
            @$save_button = this.$('button.save');
            @posting_items = new TimePostingList()
            this.listenTo(@posting_items, 'add', @addPostingItemView)
            @posting_items.fetch({url: '/rest-crow/timeposting/'}) # will fetch current week

        render: ->
            #timepostings
            @$el.html @template({})
            this

        addPostingItemView: (time_posting_model) ->
            new_view = new TimePostingItemView
                model: time_posting_model
            @$timepostings.append new_view.render().el

        clicked_save: ->
            that = this
            @$save_button.button('loading')
            setTimeout(->
                that.$save_button.button('reset')
                console.info 'hihi-saved'
            ,1000)
    )