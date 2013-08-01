define ['backbone', '../models/TimePostingItemModel', '../templates/PostTimeScreenTemplates'], (Backbone, TimePostingItemModel, templates) ->
    Backbone.View.extend( # TimePostingItemView
        tagName: 'tr'
        template: jade.compile(templates.TimePostingItemView)
        events:
            'click .save': 'click_save'

        initialize: ->
            _.bindAll this, 'render', 'click_save'

        render: ->
            @$el.html @template(@model.attributes)
            this

        click_save: ->
            #update post time in model
            @model.save()
    )
