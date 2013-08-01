define ['backbone'], (Backbone) ->
    TimePostingItemModel = Backbone.Model.extend(
        initialize: ->
            console.info(@get 'task_name')
    )

    return TimePostingItemModel