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
            "click button.status": "rollStatus"

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
            @$el.find("[rel='tooltip']").tooltip()
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
            #            console.info "Task " + @model.attributes.id + " changed assignment to " + e.val
            AjaxRequests.syncAssignment
                task_id: @model.attributes.id
                userlinks: e.val
            , (resp) ->
                that.model.attributes.assignments = resp.assignments
                console.info(that.model.attributes)
#                console.info resp
#                console.info "Task " + that.model.attributes.id + " changed assignment to " + e.val

        deleteTask: ->
            that = this
            posted = @model.attributes.posted
            if posted? and posted isnt 0
                new window.app.CrowModalView(model: new window.app.CrowModal(
                    title: 'Sir,'
                    message: 'There is time posted (' + @model.attributes.posted_str + ') for this task. Do you want to delete task with all time posted?'
                    cb: (answ) ->
                        if answ
                            that.deleteTask1())).show()
            else
                @deleteTask1()

        deleteTask1: ->
            that = this
            AjaxRequests.deleteTask
                task_id: that.model.attributes.id
            , (response) ->
                if response.status? and response.status is "error"
                    new window.app.CrowInfoModalView(model: new window.app.CrowInfoModal(
                        title: 'Sir,'
                        message: 'Cannot delete a task with assigned people.'
                        cb: () ->
                    )).show()
                else
                    that.$el.hide('fast', ->
                        that.$el.remove())

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
                    when 'C' then new window.app.CrowModalView(model: new window.app.CrowModal(
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
            _.bindAll this, 'edit', 'save', 'render', 'toggle'
            _.bindAll this, 'addTask', 'addTask1', 'addPhase', 'addPhase1', 'rmPhase', 'rmPhase1'
            _.bindAll this, 'listener_deletedSubPhase', 'listen_estimateUpdate'
            _.bindAll this, 'view_setEstimate'
            @model.on({
                "change:estimate": @view_setEstimate
            });

        view_setEstimate: ->
            niceFloat = (val) ->
                Math.round(val * 100) / 100
            est = niceFloat(@model.attributes.estimate / (8 * 60 * 60 * 1000))
            pst = niceFloat(@model.attributes.posted / (8 * 60 * 60 * 1000))
            $(@$el.find('.estimate')[0]).html('' + pst + 'd / ' + est + 'd')
#            console.info('will update')

        edit: ->
            $(@$el.find(".name")[0]).css("width", "100%")
            $(@$el.find('.editable')[0]).html @editTemplate(@model.attributes)
            @$el.find("[rel='tooltip']").tooltip()
            @$el.find("[rel='popover']").popover()
            $(@el).find(".editname").focus()

        save: (target) ->
            that = this
            phaseId = $(target.toElement).data('phase-id')
            if phaseId is @model.attributes.id
                target.stopPropagation()
                #todo: and jquery-coin "saved" notification
                @model.attributes.name = @$el.find(".editname").val()
                @model.attributes.notes = @$el.find(".editnotes").val()
                @model.attributes.short_name = @$el.find(".editshort_name").val()
                AjaxRequests.updatePhase @model.attributes, (phase) ->
                    that.model.set(phase)
                    $(that.$el.find(".name")[0]).css("width", "auto")
                    $(that.$el.find('.editable')[0]).html that.doneEditingTemplate(that.model.attributes)

        addTask: (target) ->
            that = this
            phaseId = $(target.toElement).data("phase-id")
            if phaseId is @model.attributes.id
                target.stopPropagation()
                AjaxRequests.addTask
                    phase_id: phaseId
                , (task) ->
                    that.addTask1 task, true
            else
                return

        addTask1: (task_json, anim) ->
            if not @model.subtasks?
                @model.subtasks = new Array()
            task_model = new Task(task_json)
            @model.subtasks.push task_model
            $task_el = $ new TaskView(model: task_model).render().el
            if anim?
                $task_el.hide()
                @subTaskPhasePlace.prepend $task_el
                $task_el.show('fast')
            else
                @subTaskPhasePlace.prepend $task_el
            @listenTo(task_model, 'estimate_update', @listen_estimateUpdate)
            task_model.trigger('estimate_update', 'add', task_model.attributes.estimate, task_model.attributes.posted)
            return task_model

        listen_estimateUpdate: (op, inc_est, inc_pst)->
            if not @model.attributes.estimate?
                @model.attributes.estimate = 0
                @model.attributes.posted = 0
            cur_est = @model.attributes.estimate
            cur_pst = @model.attributes.posted

            switch op
                when 'del'
                    cur_est -= inc_est
                    cur_pst -= inc_pst
                when 'add'
                    cur_est += inc_est
                    cur_pst += inc_pst
            @model.set({estimate: cur_est, posted: cur_pst})
            console.info(cur_est + ' ' + cur_pst)
            @model.trigger('estimate_update', op, inc_est, inc_pst)

        addPhase: (target) ->
            that = this
            phaseId = $(target.toElement).data("phase-id")
            if phaseId is @model.attributes.id
                target.stopPropagation()
                AjaxRequests.addPhase
                    parent_phase_id: phaseId
                , (phase) ->
                    that.addPhase1 phase, true
            else
                return

        addPhase1: (phase_json, focus) ->
            if not @model.subphases?
                @model.subphases = new Array()
            phase_model = new Phase(phase_json)
            sub_phase_view = new PhaseView(model: phase_model)
            @model.subphases.push phase_model
            @listenTo(phase_model, 'deleted', @listener_deletedSubPhase)
            @listenTo(phase_model, 'estimate_update', @listen_estimateUpdate)
            @subTaskPhasePlace.prepend sub_phase_view.render().el
            if focus? && focus
                sub_phase_view.edit()
            return phase_model

        listener_deletedSubPhase: (target) ->
            console.info "boo"

        rmPhase: (target) ->
            that = this
            phase_id = $(target.toElement).data("phase-id")
            if phase_id is @model.attributes.id
                if @model.subphases? or @model.subtasks?
                    kiddies = new Array()
                    if @model.subtasks?
                        kiddies.push task.attributes.name for task in @model.subtasks
                    if @model.subphases?
                        kiddies.push phase.attributes.name for phase in @model.subphases
                    kiddies_str = kiddies.join ', '
                    new window.app.CrowModalView(model: new window.app.CrowModal(
                        title: 'Sir,'
                        message: 'There are subtasks and phases (' + kiddies_str + ') under current phase. Do you want to delete this phase?'
                        severe: true
                        cb: (answ) ->
                            if answ
                                that.rmPhase1(target))).show()
                else
                    @rmPhase1(target)

        rmPhase1: (target) ->
            that = this
            phaseId = $(target.toElement).data("phase-id")
            if phaseId is @model.attributes.id
                target.stopPropagation()
                AjaxRequests.rmPhase
                    phase_id: phaseId
                , (resp) ->
                    if resp.status and resp.status isnt 'error'
                        that.$el.hide('fast', ->
                            that.model.trigger('deleted', that)
                            that.$el.remove())
                    else
                        new window.app.CrowInfoModalView(model: new window.app.CrowInfoModal(
                            title: resp.status
                            message: 'Something went wrong: ' + JSON.stringify(resp.message, null, 2)
                            cb: () ->
                        )).show()
            else
                return

        render: ->
            @$el.addClass("phase prj-node").attr "phase-id", @model.attributes.id
            @$el.html @template(@model.attributes)
            if @model.attributes.subphases or @model.attributes.tasks
                @$el.find('i.toggle').click(@toggle)
            else
                @$el.find('i.toggle').removeClass('icon-minus-sign')
            @subTaskPhasePlace = @$el.find(".subtasksnphases")
            if @model.attributes.tasks
                @addTask1(task, false) for task in @model.attributes.tasks
                @model.attributes.tasks = undefined
            if @model.attributes.subphases
                @addPhase1(phase, false) for phase in @model.attributes.subphases
                @model.attributes.subphases = undefined
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