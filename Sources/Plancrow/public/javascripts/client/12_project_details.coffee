(($) ->
    jade = require("jade")

    Task = Backbone.Model.extend({})
    TaskView = Backbone.View.extend(
        tagName: "li"
        template: jade.compile(templates.TaskView) # defined in template.coffe
        editTemplate: jade.compile(templates.TaskEditView)
        events:
            "click .name": "rename"
            "blur": "saveRenamed"
            "click button.delete": "deleteTask"
            "click button.details": "details"
            "click .status a[role = 'menuitem']": "changeStatus"
            "change .assignment": "syncAssignment"
            "click a.status": "rollStatus"

        initialize: ->
            _.bindAll this, "render", "rename", "saveRenamed", "syncAssignment", "deleteTask", "details", "changeStatus", "_dragStartEvent"
            _.bindAll this, "rollStatus", "updateTask1"

            #draggable kitchen
            @$el.attr "draggable", "true"
            @$el.bind "dragstart", _.bind(@_dragStartEvent, this)

        # Draggable kitchen {
        _dragStartEvent: (e) ->
            data = undefined
            e = e.originalEvent  if e.originalEvent
            e.dataTransfer.effectAllowed = "copy"
            # default to copy
            data = @dragStart(e.dataTransfer, e)
            window._backboneDragDropObject = null
            window._backboneDragDropObject = data  if data isnt `undefined` # we cant bind an object directly because it has to be a string, json just won't do

        dragStart: (dataTransfer, e) ->
            # console.info(this.model.attributes);
            # override me, return data to be bound to drag
            # probably json wont do, json only
            @model.attributes

        # } Draggable kitchen
        render: ->
            @$el.addClass('task prj-node').attr "data-taskid", @model.attributes.id
            @$el.html @template(
                t: @model.attributes
                u: projectDetailsScreen.userlinks
            )
            @$el.find(".assignment").select2()
            this

        rename: ->
            $(@el).html @editTemplate(@model.attributes)
            $(@el).find(".editname").focus()
            @el.addEventListener "blur", @saveRenamed, true

        saveRenamed: ->
            that = this
            #and jquery-coin "saved" notification
            newName = $(@el).find(".editname").val()
            @model.attributes.name = newName
            AjaxRequests.updateTask @model.attributes, (task) ->
                $.extend that.model.attributes, task
                that.render()

        syncAssignment: (e) ->
            that = this
            console.info "Task " + @model.attributes.id + " changed assignment to " + e.val
            AjaxRequests.syncAssignment
                task_id: @model.attributes.id
                userlinks: e.val
            , (resp) ->
                console.info resp
                console.info "Task " + that.model.attributes.id + " changed assignment to " + e.val

        #todo: show here that tasks were synced
        deleteTask: ->
            that = this
            AjaxRequests.deleteTask
                task_id: that.model.attributes.id
            , (response) ->
                if response.status? and response.status is "error"
                    window.alert response.message
                else
                    that.$el.hide('fast', -> that.$el.remove())

        details: ->
            @$el.find(".notes").toggle()

        rollStatus: ->
            that = this
            if @model.attributes.status?
                switch @model.attributes.status
                    when 'N'
                        @model.attributes.status = 'A'
                        @updateTask1()
                    when 'A'
                        @model.attributes.status = 'C'
                        @updateTask1()
                    when 'C' then new window.app.CrowModalView(model : new window.app.CrowModal(
                        title: 'Sir,'
                        message: 'Do you want to reopen task?'
                        cb: (answ) ->
                            if answ
                                that.model.attributes.status = 'A'
                                that.updateTask1())).show()

        changeStatus: (src) ->
            that = this
            @model.attributes.status = $(src.target).data("status")
            @updateTask1()

        updateTask1: () ->
            that = this
            AjaxRequests.updateTask @model.attributes, (task) ->
                $.extend that.model.attributes, task
                that.render()
        #and jquery-coin "saved" notification
    )

    Phase = Backbone.Model.extend(defaults:
            id: -1
            name: "n/a"
    )
    PhaseView = Backbone.View.extend(
        tagName: "li"
        template: jade.compile(templates.PhaseView)
        editTemplate: jade.compile(templates.PhaseEditView)
        doneEditingTemplate: jade.compile(templates.PhaseDoneEditingView)
        events:
            "click .editarea": "edit"
            "click .save": "save"
            "click .addtask": "addTask"
            "click .addphase": "addPhase"
            "click .rmphase": "rmPhase"

        initialize: ->
            _.bindAll this, 'edit', 'save', 'addTask', 'addPhase', 'rmPhase', 'render', 'toggle'

        edit: ->
            $(@$el.find('.editable')[0]).html @editTemplate(@model.attributes)
            $(@el).find(".editname").focus()

        save: (target) ->
            that = this
            console.info(target.toElement)
            phaseId = $(target.toElement).data('phase-id')
            if phaseId is @model.attributes.id
                #todo: and jquery-coin "saved" notification
                @model.attributes.name = @$el.find(".editname").val()
                @model.attributes.notes = @$el.find(".editnotes").val()
                AjaxRequests.updatePhase @model.attributes, (phase) ->
                    $.extend that.model.attributes, phase
                    $(that.$el.find('.editable')[0]).html that.doneEditingTemplate(that.model.attributes)

        addTask: (target) ->
            that = this
            phaseId = $(target.toElement).data("phase-id")
            if phaseId is @model.attributes.id
                AjaxRequests.addTask
                    phase_id: phaseId
                , (task) ->
                    $el = $ new TaskView(model: new Task(task)).render().el
                    $el.hide()
                    that.subTaskPhasePlace.prepend $el
                    $el.show('fast')

            else
                return

        addPhase: (target) ->
            that = this
            phaseId = $(target.toElement).data("phase-id")
            if phaseId is @model.attributes.id
                AjaxRequests.addPhase
                    parent_phase_id: phaseId
                , (phase) ->
                    that.subTaskPhasePlace.prepend new PhaseView(model: new Phase(phase)).render().el

            else
                return

        rmPhase: (target) ->
            that = this
            phaseId = $(target.toElement).data("phase-id")
            if phaseId is @model.attributes.id
                AjaxRequests.rmPhase
                    phase_id: phaseId
                , (phase) ->
                    that.$el.remove()
            else
                return

        render: ->
            @$el.addClass("phase prj-node").attr "phase-id", @model.attributes.id
            if @model.attributes.children or @model.attributes.tasks
                @model.attributes.canrm = false
            else
                @model.attributes.canrm = true
            @$el.html @template(@model.attributes)
            if @model.attributes.children or @model.attributes.tasks
                @$el.find('i.toggle').click(@toggle)
            else
                @$el.find('i.toggle').removeClass('icon-minus-sign')
            @subTaskPhasePlace = @$el.find(".subtasksnphases")
            @subTaskPhasePlace = @subTaskPhasePlace
            if @model.attributes.tasks
                tasks = @model.attributes.tasks
                i = 0
                while i < tasks.length
                    @subTaskPhasePlace.append new TaskView(model: new Task(tasks[i])).render().el
                    i++
            if @model.attributes.children
                kids = @model.attributes.children
                kiddies = new Array()
                i = 0

                while i < kids.length
                    kiddies[i] = new PhaseView(model: new Phase(kids[i]))
                    i++
                i = 0

                while i < kids.length
                    @subTaskPhasePlace.append kiddies[i].render().el
                    i++
                @model.attributes.children = `undefined`
            this

        toggle: (e) ->
            children = @$el.find(' > ul > li')
            if children.is(':visible')
                children.hide('fast')
                @$el.find('i.toggle').first().attr('title',
                    'Expand this branch').addClass('icon-plus-sign').removeClass('icon-minus-sign')
            else
                children.show('fast')
                @$el.find('i.toggle').first().attr('title',
                    'Collapse this branch').addClass('icon-minus-sign').removeClass('icon-plus-sign')
            e.stopPropagation
    )
    DroppableView = Backbone.View.extend(
        template: jade.compile("div.row-fluid.droppable\n\tdiv.name.span2 drag here [   ]")
        initialize: ->
            @$el.bind "dragover", _.bind(@_dragOverEvent, this)
            @$el.bind "dragenter", _.bind(@_dragEnterEvent, this)
            @$el.bind "dragleave", _.bind(@_dragLeaveEvent, this)
            @$el.bind "drop", _.bind(@_dropEvent, this)
            @_draghoverClassAdded = false

        _dragOverEvent: (e) ->
            e = e.originalEvent  if e.originalEvent
            data = @_getCurrentDragData(e)
            if @dragOver(data, e.dataTransfer, e) isnt false
                e.preventDefault()  if e.preventDefault
                e.dataTransfer.dropEffect = "copy" # default

        _dragEnterEvent: (e) ->
            e = e.originalEvent  if e.originalEvent
            e.preventDefault()  if e.preventDefault

        _dragLeaveEvent: (e) ->
            e = e.originalEvent  if e.originalEvent
            data = @_getCurrentDragData(e)
            @dragLeave data, e.dataTransfer, e

        _dropEvent: (e) ->
            e = e.originalEvent  if e.originalEvent
            data = @_getCurrentDragData(e)
            e.preventDefault()  if e.preventDefault
            e.stopPropagation()  if e.stopPropagation
            # stops the browser from redirecting
            @$el.removeClass "draghover"  if @_draghoverClassAdded
            @drop data, e.dataTransfer, e

        _getCurrentDragData: (e) ->
            data = null
            data = window._backboneDragDropObject  if window._backboneDragDropObject
            data

        dragOver: (data, dataTransfer, e) -> # optionally override me and set dataTransfer.dropEffect, return false if the data is not droppable
            @$el.addClass "draghover"
            @_draghoverClassAdded = true

        dragLeave: (data, dataTransfer, e) -> # optionally override me
            @$el.removeClass "draghover"  if @_draghoverClassAdded

        drop: (data, dataTransfer, e) ->
            console.info data
            to_phase = $(e.toElement).data("phase-id")
            AjaxRequests.moveTask
                task_id: data.id
                to_phase: to_phase
            , (task) ->
                $("div[data-taskid=" + data.id + "]").remove()
                $("li.phase[id=" + to_phase + "]").append new TaskView(model: new Task(task)).render()

                #                console.info(new TaskView({model: new Task(task)}).render());
                #                $.extend(that.model.attributes, task);
                #                that.render();
                console.info "Saved"
                console.info task


        # overide me!  if the draggable class returned some data on 'dragStart' it will be the first argument
        #     /* } Draggable kitchen */
        render: ->
            $(@$el).html @template(@model.attributes)
    )
    ProjectDetailsScreen = Backbone.View.extend(
        el: $("body")
        initialize: ->
            _.bindAll this, "render"


        #            var renderedTasks = $(".task");
        #            for (var k = 0; k < renderedTasks.size(); k++) {
        #                var task = $(renderedTasks[k]);
        #                new TaskView({el: renderedTasks[k], model: new Task({id: task.data("taskid"), name: task.data("taskname"),
        #                    notes: task.data("tasknotes")})});
        #            }
        #
        #            var renderedDroppables = $(".droppable");
        #            for (var k = 0; k < renderedDroppables.size(); k++) {
        #                var droppable = $(renderedDroppables[k]);
        #                new DroppableView({el: renderedDroppables[k]});
        #            }
        #
        #            var phases = $(".phase");
        #            for (var k = 0; k < phases.size(); k++) {
        #                var phase = $(phases[k]);
        #                new PhaseView({el: phase[k]});
        #            }

        #DroppableView

        #            this.render();

        #            $(".assignment").select2();

        #            this.$el.find(".notes").toggle();
        render: ->
            that = this
            AjaxRequests.allTasks {}, (data) ->
                i = 0

                while i < data.root.length

                    # store userlinks for later use
                    that.userlinks = data.userlinks
                    $(".details-container").append new PhaseView(model: new Phase(data.root[i])).render().el
                    i++

    )
    projectDetailsScreen = new ProjectDetailsScreen()
    projectDetailsScreen.render()
) jQuery