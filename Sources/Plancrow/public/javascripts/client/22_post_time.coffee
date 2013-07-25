(($) ->
    jade = require("jade")

    Assigment = Backbone.Model.extend()

    AssigmentView = Backbone.View.extend(
        tagName: "tr"
        template: jade.compile(templates.AssignmentView) # defined in template.coffe
        events:
            "focus input.posttime_val": "clearPosttimeVal"
            "click .posttime": "postTime"

        initialize: ->
            _.bindAll this, "render", "postTime", "clearPosttimeVal"

        render: ->
            @$el.html @template(@model.attributes)
            this

        clearPosttimeVal: ->
            @$el.find(".posttime_val").val ""

        postTime: ->
            that = this
            time_inc = @$el.find(".posttime_val").val()
            AjaxRequests.postTime
                task_id: @model.attributes.task_id
                time_inc: time_inc
                timing_date: new Date()
                userlink_id: @model.attributes.userlink_id
            , (data) ->
                console.info data
                that.$el.find(".posttime_val").val data.status
    )

    PostTimeScreen = Backbone.View.extend(
        el: $("body")

        initialize: ->
            _.bindAll this, "render"

        render: ->
            assignment_place = @$el.find(".assignments")
            AjaxRequests.assignedTasks {}, (data) ->
                assignment_place.append new AssigmentView(model: new Assigment(assignment)).render().el for assignment in data.assignments
    )

    PostTimeScreen = new PostTimeScreen()
    PostTimeScreen.render()
) jQuery