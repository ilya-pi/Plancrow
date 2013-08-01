define ['backbone', 'bootstrap', '../models/TimePostingItemModel', '../templates/PostTimeScreenTemplates'], (Backbone, bootstrap, TimePostingItemModel, templates) ->
    Backbone.View.extend( # TimePostingItemView
        tagName: 'tr'
        template: jade.compile(templates.TimePostingItemView)
        events:
            'click .save': 'clicked_save'
            'click .more_info': 'clicked_more_info'

        initialize: ->
            _.bindAll this, 'render', 'clicked_save', 'clicked_more_info'

        render: ->
            @$el.html @template(@model.attributes)
            #don't need tooltips for the moment
            this.$("[data-toggle='tooltip']").tooltip()
            @$sqn = this.$('.more_info')
            @$sqn.addClass('expanded')
            @clicked_more_info() # to pick up logic for changing views
            this

        clicked_save: ->
            #update post time in model
            @model.save()

        clicked_more_info: ->
            if @$sqn.hasClass('collapsed')
                @$sqn.attr('title', 'Hide full phase names').addClass('expanded').removeClass('collapsed').html @model.get('names').fqn.join('&nbsp;&rarr; ')
            else
                sqname = @model.get('names').sqn.join('&nbsp;&rarr; ')
                @$sqn.attr('title', 'Show full phase names').addClass('collapsed').removeClass('expanded')
                if sqname.length > 0
                    @$sqn.html sqname
                else
                    @$sqn.html '<span class=\'icon-info pull-right\'> </span>'

    )
