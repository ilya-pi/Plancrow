define ['backbone', '../models/TimePostingItemModel'], (Backbone, TimePostingItemModel) ->
    TimePostingList = Backbone.Collection.extend(
        model: TimePostingItemModel

        initialize: ->
    )

    return TimePostingList