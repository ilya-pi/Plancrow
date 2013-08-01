define ['backbone'], (Backbone) ->
    TimePostingItemModel = Backbone.Model.extend(
        defaults:
            id: -1
            name: "not specified"

        initialize: ->
    )

    return TimePostingItemModel