(($) ->
    jade = require("jade")

    HackedDragModel = Backbone.Model.extend(
        defaults:
            type: "TASK" #'TASK', 'PHASE'
    )
    HackedDragView = window.app.DraggableView.extend(
        initialize: (options) ->
            this.constructor.__super__.initialize.apply(this, [options])
            _.bindAll this, 'dragStart'

        dragStart: (dataTransfer, e) ->
            @_dragged_view._dragged_type = @model.attributes.type
            @_dragged_view
    )

    Task = Backbone.Model.extend({})
    TaskView = Backbone.View.extend(
        tagName: "li"
        template: jade.compile(templates.TaskView) # defined in template.coffe
        editTemplate: jade.compile(templates.TaskEditView)
        events:
            "click .editarea": "edit"
            "click .save": "save"
            "click button.delete": "deleteTask"
            "click .status a[role = 'menuitem']": "changeStatus"
            "change .assignment": "syncAssignment"
            "click button.status": "rollStatus",
            "click i.status": "rollStatus"

        initialize: ->
            _.bindAll this, 'render', 'syncAssignment', 'deleteTask', 'changeStatus'
            _.bindAll this, 'edit', 'save'
            _.bindAll this, 'rollStatus', 'updateTask1'

        render: ->
            @$el.addClass('task prj-node').attr "data-taskid", @model.attributes.id
            @$el.html @template(
                t: @model.attributes
                u: projectDetailsScreen.userlinks
            )
            @$el.find(".assignment").select2()
            @$el.find("[rel='tooltip']").tooltip()
            drag_view = new HackedDragView({model: new HackedDragModel({type: 'TASK'}), el: @$el.find('.reorder')[0]})
            drag_view._dragged_view = this
            this

        edit: (e) ->
            if e?
                e.stopPropagation()
            $(@$el.find(".name")[0]).css("width", "100%")
            $(@$el.find('.editable')[0]).html @editTemplate(@model.attributes)
            $(@el).find(".editname").focus()

        save: (target) ->
            that = this
            target.stopPropagation()
            #todo: and jquery-coin "saved" notification
            @model.attributes.name = @$el.find(".editname").val()
            @model.attributes.notes = @$el.find(".editnotes").val()
            $(that.$el.find(".name")[0]).css("width", "auto")
            @updateTask1()

        syncAssignment: (e) ->
            that = this
            AjaxRequests.syncAssignment
                task_id: @model.attributes.id
                userlinks: e.val
            , (resp) ->
                that.model.attributes.assignments = resp.assignments

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
                        that.model.trigger('estimate_update', 'del', that.model.attributes.estimate,
                            that.model.attributes.posted)
                        that.$el.remove())

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
            @model.attributes.status = $(src.target).data("status")
            @updateTask1()

        updateTask1: () ->
            that = this
            AjaxRequests.updateTask @model.attributes, (task) ->
                that.model.set(task)
                that.render()
        #and jquery-coin "saved" notification
    )

    Phase = Backbone.Model.extend(defaults:
            id: -1
            name: "n/a"
    )

    PhaseDropAreaView = window.app.DroppableView.extend(
        initialize: (options) ->
            this.constructor.__super__.initialize.apply(this, [options])
            _.bindAll this, 'drop'

        drop: (dragged_view, dataTransfer, e) ->
            that = this
            switch dragged_view._dragged_type
                when 'TASK'
                    if  dragged_view.model.attributes.project_phase_id isnt @_target_view.model.attributes.id
                        AjaxRequests.moveTask
                                task_id: dragged_view.model.attributes.id
                                to_phase: @_target_view.model.attributes.id
                                ,
                                (resp) ->
                                    if resp.status? and resp.status is 'success'
                                        dragged_view._parent.rmTask11(dragged_view)
                                        dragged_view._parent.enableToggles()
                                        that._target_view.addTask11(dragged_view, false, true)
                                        that._target_view.enableToggles()
                                    else
                                        new window.app.CrowInfoModalView(model: new window.app.CrowInfoModal(
                                            title: resp.status
                                            message: 'Something went wrong: ' + JSON.stringify(resp.message, null, 2)
                                            cb: () ->
                                        )).show()
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
            "click .toggle": "toggle"

        initialize: (options) ->
            _.bindAll this, 'edit', 'save', 'render', 'toggle'
            _.bindAll this, 'addTask', 'addTask1', 'addTask11', 'addPhase', 'addPhase1', 'rmPhase', 'rmPhase1'
            _.bindAll this, 'listener_deletedSubPhase', 'listen_estimateUpdate'
            _.bindAll this, 'view_setEstimatePosted'
            _.bindAll this, 'rmTask11', 'enableToggles'
            @model.on(
                "change:estimate change:posted": @view_setEstimatePosted
            );

        view_setEstimatePosted: ->
            est_str = window.app._formatEstimate(@model.attributes.estimate)
            pst_str = window.app._formatEstimate(@model.attributes.posted)
            $(@$el.find('.estimate')[0]).html("<small rel='tooltip' data-toggle='tooltip' title='subtree posted/estimate'>" + pst_str + ' / ' + est_str + '</small>')
            $(@$el.find('.estimate')[0]).find("[rel='tooltip']").tooltip()

        edit: ->
            $(@$el.find(".name")[0]).css("width", "100%")
            $(@$el.find('.editable')[0]).html @editTemplate(@model.attributes)
            @$el.find("[rel='tooltip']").tooltip()
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
                    that.addTask1 task, true, true
            else
                return

        addTask1: (task_json, focus, anim) ->
            task_model = new Task(task_json)
            task_view = new TaskView({model: task_model})
            task_view.render()
            @addTask11(task_view, focus, anim)

        addTask11: (task_view, focus, anim) ->
            if not @model.subtasks?
                @model.subtasks = new Array()
            @model.subtasks.push task_view.model
            task_view.model.set({project_phase_id: @model.attributes.id})
            task_view._parent = this
            if anim?
                task_view.$el.hide()
                @subTaskPhasePlace.prepend task_view.el
                task_view.$el.show('fast', ->
                    if focus? && focus then task_view.edit())
            else
                @subTaskPhasePlace.prepend task_view.el
                if focus? && focus then task_view.edit()
            @listenTo(task_view.model, 'estimate_update', @listen_estimateUpdate)
            task_view.model.trigger('estimate_update', 'add', task_view.model.attributes.estimate, task_view.model.attributes.posted)
            return task_view.model

        rmTask11: (task_view) ->
            task_view.el.remove
            @model.subtasks.splice($.inArray(@model.subtasks, task_view), 1)
            task_view.model.trigger('estimate_update', 'del', task_view.model.attributes.estimate, task_view.model.attributes.posted)
            @stopListening(task_view.model)
            task_view.model.set({project_phase_id: undefined})

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
            @model.trigger('estimate_update', op, inc_est, inc_pst)

        addPhase: (target) ->
            that = this
            phaseId = $(target.toElement).data("phase-id")
            if phaseId is @model.attributes.id
                target.stopPropagation()
                AjaxRequests.addPhase
                    parent_phase_id: phaseId
                , (phase) ->
                    that.addPhase1 phase, true, true
            else
                return

        addPhase1: (phase_json, focus, anim) ->
            if not @model.subphases?
                @model.subphases = new Array()
            phase_model = new Phase(phase_json)
            sub_phase_view = new PhaseView(model: phase_model)
            @model.subphases.push phase_model
            @listenTo(phase_model, 'deleted', @listener_deletedSubPhase)
            @listenTo(phase_model, 'estimate_update', @listen_estimateUpdate)
            $phase_el = $ sub_phase_view.render().el
            if anim?
                $phase_el.hide()
                @subTaskPhasePlace.prepend $phase_el
                $phase_el.show('fast', ->
                    if focus? && focus then sub_phase_view.edit())
            else
                @subTaskPhasePlace.prepend $phase_el
                if focus? && focus then sub_phase_view.edit()
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

        enableToggles: ->
            if @model.attributes.subphases or @model.attributes.tasks or (@model.subtasks and @model.subtasks.length > 0)
                @$el.find('i.toggle').first().attr('title', 'Collapse this branch').addClass('icon-minus-sign')
            else
                @$el.find('i.toggle').first().removeClass('icon-minus-sign')

        render: ->
            @$el.addClass("phase prj-node").attr "phase-id", @model.attributes.id
            @$el.html @template(@model.attributes)
            @enableToggles()
            #drag n drop {
            drop_view = new PhaseDropAreaView({el: @$el.find('.drop_point')[0]})
            drop_view._target_view = this
            #drag and drop }

            @subTaskPhasePlace = @$el.find(".subtasksnphases")
            if @model.attributes.tasks
                @addTask1(task) for task in @model.attributes.tasks
                @model.attributes.tasks = undefined
            if @model.attributes.subphases
                @addPhase1(phase) for phase in @model.attributes.subphases
                @model.attributes.subphases = undefined
            this

        toggle: (target) ->
            phaseId = $(target.toElement).data("phase-id")
            if phaseId is @model.attributes.id
                children = @$el.find(' > ul > li')
                if children.is(':visible')
                    children.hide('fast')
                    @$el.find('i.toggle').first().attr('title',
                        'Expand this branch').addClass('icon-plus-sign').removeClass('icon-minus-sign')
                else
                    children.show('fast')
                    @$el.find('i.toggle').first().attr('title',
                        'Collapse this branch').addClass('icon-minus-sign').removeClass('icon-plus-sign')
                target.stopPropagation
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