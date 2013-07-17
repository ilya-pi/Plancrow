(function ($) {

    var jade = require("jade");

    var Task = Backbone.Model.extend({
        defaults: {
            id: -1,
            name: 'n/a'
        }
    });

    var TaskView = Backbone.View.extend({
//        template: jade.compile('div.row-fluid\n\tdiv.span1\n\t\ti.icon-tasks.pull-right\n\tdiv.name.span5 Task: #{name}\n\tdiv.span6 \n\t\tp [est.: #{estimate}, posted: #{posted}]'),
        template: jade.compile('div.row-fluid.task(id ="#{t.id}", data-taskid="#{t.id}", data-taskname = "#{t.name}", data-tasknotes = "#{t.notes}")' +
            '\n\tdiv.span1' +
            '\n\t\ti.icon-tasks.pull-right' +
            '\n\tdiv.name.span2 Task: #{t.name}' +
            '\n\t\tdiv.notes(style="display:none;")= t.notes' +
            '\n\tdiv.span2' +
            '\n\t\tp [est.: #{t.estimate}, posted: #{t.posted}]' +

            '\n\tdiv.span3\n' +
            '\t\tselect.assignment(style="width: 100%;", multiple)\n' +
            '\t\t\t- for (var i = 0; i < u.length; i++) {\n' +
            '\t\t\t\t- var if_selected = ""; for (var k = 0; k < t.assignments.length; k++) { if (t.assignments[k].userlink_id == u[i].id){if_selected = "true";}} \n' +
            '\t\t\t\toption(value=u[i].id, selected=if_selected) #{u[i].user.first_name} #{u[i].user.second_name}\n' +
            '\t\t\t- }\n' +

            '\n\tdiv.span2.input-prepend.input-append' +
            '\n\t\tbutton.btn.btn-mini.delete delete' +
            '\n\t\tbutton.btn.btn-mini.details details' +
            '\n\tdiv.span1' +
            '\n\t\tdiv.btn-group.status' +
            '\n\t\t\ta.btn.btn-mini' +
            '\n\t\t\t\t- if (t.status == "A"){' +
            '\n\t\t\t\t\tfont Active' +
            '\n\t\t\t\t- }else if (t.status == "N"){' +
            '\n\t\t\t\t\tfont Not Started' +
            '\n\t\t\t\t- }else if (t.status == "C"){' +
            '\n\t\t\t\t\tfont Completed' +
            '\n\t\t\t\t- }' +
            '\n\t\t\ta.btn.btn-mini.dropdown-toggle(data-toggle="dropdown")' +
            '\n\t\t\t\tspan.caret' +
            '\n\t\t\tul.dropdown-menu(role = "menu")' +
            '\n\t\t\t\tli(role = "presentation")' +
            '\n\t\t\t\t\ta(role = "menuitem", data-status="A") Active' +
            '\n\t\t\t\tli(role = "presentation")' +
            '\n\t\t\t\t\ta(role = "menuitem", data-status="N") Not Started' +
            '\n\t\t\t\tli.divider' +
            '\n\t\t\t\tli(role = "presentation")' +
            '\n\t\t\t\t\ta(role = "menuitem", data-status="C") Completed'
        ),


        editTemplate: jade.compile('div.row-fluid\n\tdiv.span1\n\t\ti.icon-tasks.pull-right\n\tdiv.span4 Task:&nbsp;\n\t\tinput.editname(type="text", value=name)'),

        events: {
            "click .name": "rename",
            "blur": "saveRenamed",
            "click button.delete": "deleteTask",
            "click button.details": "details",
            "click .status a[role = 'menuitem']": "changeStatus",
            "change .assignment": "syncAssignment"
        },

        initialize: function () {
            _.bindAll(this, 'render', 'rename', 'saveRenamed', 'syncAssignment', 'deleteTask', 'details', 'changeStatus', '_dragStartEvent');

            //draggable kitchen
            this.$el.attr("draggable", "true")
            this.$el.bind("dragstart", _.bind(this._dragStartEvent, this))
        },


        /* Draggable kitchen { */
        _dragStartEvent: function (e) {
            var data
            if (e.originalEvent) e = e.originalEvent
            e.dataTransfer.effectAllowed = "copy" // default to copy
            data = this.dragStart(e.dataTransfer, e)

            window._backboneDragDropObject = null
            if (data !== undefined) {
                window._backboneDragDropObject = data // we cant bind an object directly because it has to be a string, json just won't do
            }
        },

        dragStart: function (dataTransfer, e) {
//            console.info(this.model.attributes);
            // override me, return data to be bound to drag
            // probably json wont do, json only
            return this.model.attributes;
        },
        /* } Draggable kitchen */

        render: function () {
            this.$el.addClass("task").attr("data-taskid", this.model.attributes.id);
            this.$el.html(this.template({t: this.model.attributes, u: projectDetailsScreen.userlinks}));
            this.$el.find(".assignment").select2();
            return this;
        },

        rename: function () {
            $(this.el).html(this.editTemplate(this.model.attributes));
            $(this.el).find(".editname").focus();
            this.el.addEventListener('blur', this.saveRenamed, true);
        },

        saveRenamed: function () {
            var that = this
            //and jquery-coin "saved" notification
            var newName = $(this.el).find(".editname").val();
            this.model.attributes.name = newName;
            AjaxRequests.updateTask(this.model.attributes, function (task) {
                $.extend(that.model.attributes, task);
                that.render();
            })
        },

        syncAssignment: function (e){
            console.info("Task " + this.model.attributes.id + " changed assignment to " + e.val);
            AjaxRequests.syncAssignment({task_id: this.model.attributes.id, userlinks: e.val}, function (resp) {
                console.info(resp);
                console.info("Task " + this.model.attributes.id + " changed assignment to " + e.val);
                //todo: show here that tasks were synced
            })
        },

        deleteTask: function () {
            var that = this;
            AjaxRequests.deleteTask(this.model.attributes, function (response) {
                if (response.status !== "undefined" && response.status === "error") {
                    window.alert(response.message);
                } else {
                    that.$el.remove();
                }
            })
        },

        details: function () {
            this.$el.find(".notes").toggle();
        },

        changeStatus: function (src) {
            var that = this
            //and jquery-coin "saved" notification
            this.model.attributes.status = $(src.target).data("status");
            AjaxRequests.updateTask(this.model.attributes, function (task) {
                $.extend(that.model.attributes, task);
                that.render();
            })
        }


    });

    var Phase = Backbone.Model.extend({
        defaults: {
            id: -1,
            name: 'n/a'
        }
    });

    var PhaseView = Backbone.View.extend({

        tagName: 'li',

        template: jade.compile('font Phase: #{name}\n' +
            'div.row-fluid\n' +
            '\tdiv.span2.droppable(data-phase-id=id) [ drag here ]\n' +
            '\tdiv.span2.input-prepend.input-append\n' +
            '\t\tbutton.btn.btn-mini.addphase(type="button", data-phase-id=id) + phase\n' +
            '\t\tbutton.btn.btn-mini.addtask(type="button", data-phase-id=id) + task\n' +
            'ul.children\n' +
            'ul.tasks'),

        events: {
            "click .addtask": "addTask",
            "click .addphase": "addPhase"
        },

        initialize: function () {
            _.bindAll(this, 'addTask', 'addPhase', 'render');
        },

        addTask: function (target) {
            var that = this;
            var phaseId = $(target.toElement).data("phase-id");
            if (phaseId == this.model.attributes.id) {
                AjaxRequests.addTask({phase_id: phaseId}, function (task) {
                    that.taskPlace.prepend(
                        new TaskView({model: new Task(task)}).render().el
                    );
                });
            } else {
                return;
            }
        },

        addPhase: function (target) {
            var that = this;
            var phaseId = $(target.toElement).data("phase-id");
            if (phaseId == this.model.attributes.id) {
                AjaxRequests.addPhase({parent_phase_id: phaseId}, function (phase) {
                    that.kidPlace.append(
                        new PhaseView({model: new Phase(phase)}).render().el
                    );
                });
            } else {
                return;
            }
        },

        render: function () {
            this.$el.addClass("phase").attr("phase-id", this.model.attributes.id);
            this.$el.html(this.template(this.model.attributes));
            this.kidPlace = this.$el.find(".children");
            this.taskPlace = this.$el.find(".tasks");

            if (this.model.attributes.tasks != undefined) {
                var tasks = this.model.attributes.tasks;
                for (var i = 0; i < tasks.length; i++) {
                    this.taskPlace.append(new TaskView({model: new Task(tasks[i])}).render().el);
                }
            }

            if (this.model.attributes.children != undefined) {
                var kids = this.model.attributes.children;
                var kiddies = new Array();
                for (var i = 0; i < kids.length; i++) {
                    kiddies[i] = new PhaseView({model: new Phase(kids[i])});
                }
                for (var i = 0; i < kids.length; i++) {
                    this.kidPlace.append(kiddies[i].render().el);
                }

                this.model.attributes.children = undefined;
            }
            return this;
        }
    });

    var DroppableView = Backbone.View.extend({
        template: jade.compile('div.row-fluid.droppable\n\tdiv.name.span2 drag here [   ]'),

        initialize: function () {
            this.$el.bind("dragover", _.bind(this._dragOverEvent, this))
            this.$el.bind("dragenter", _.bind(this._dragEnterEvent, this))
            this.$el.bind("dragleave", _.bind(this._dragLeaveEvent, this))
            this.$el.bind("drop", _.bind(this._dropEvent, this))
            this._draghoverClassAdded = false
        },

        _dragOverEvent: function (e) {
            if (e.originalEvent) e = e.originalEvent
            var data = this._getCurrentDragData(e)

            if (this.dragOver(data, e.dataTransfer, e) !== false) {
                if (e.preventDefault) e.preventDefault()
                e.dataTransfer.dropEffect = 'copy' // default
            }
        },

        _dragEnterEvent: function (e) {
            if (e.originalEvent) e = e.originalEvent
            if (e.preventDefault) e.preventDefault()
        },

        _dragLeaveEvent: function (e) {
            if (e.originalEvent) e = e.originalEvent
            var data = this._getCurrentDragData(e)
            this.dragLeave(data, e.dataTransfer, e)
        },

        _dropEvent: function (e) {
            if (e.originalEvent) e = e.originalEvent
            var data = this._getCurrentDragData(e)

            if (e.preventDefault) e.preventDefault()
            if (e.stopPropagation) e.stopPropagation() // stops the browser from redirecting

            if (this._draghoverClassAdded) this.$el.removeClass("draghover")

            this.drop(data, e.dataTransfer, e)
        },

        _getCurrentDragData: function (e) {
            var data = null
            if (window._backboneDragDropObject) data = window._backboneDragDropObject
            return data
        },

        dragOver: function (data, dataTransfer, e) { // optionally override me and set dataTransfer.dropEffect, return false if the data is not droppable
            this.$el.addClass("draghover")
            this._draghoverClassAdded = true
        },

        dragLeave: function (data, dataTransfer, e) { // optionally override me
            if (this._draghoverClassAdded) this.$el.removeClass("draghover")
        },

        drop: function (data, dataTransfer, e) {
            console.info(data);
            var to_phase = $(e.toElement).data("phase-id");
            AjaxRequests.moveTask({task_id: data.id, to_phase: to_phase}, function (task) {
                $("div[data-taskid=" + data.id + "]").remove();
                $("li.phase[id=" + to_phase + "]").append(
                    new TaskView({model: new Task(task)}).render()
                );
//                console.info(new TaskView({model: new Task(task)}).render());
//                $.extend(that.model.attributes, task);
//                that.render();
                console.info("Saved");
                console.info(task);
            })

        }, // overide me!  if the draggable class returned some data on 'dragStart' it will be the first argument
        //     /* } Draggable kitchen */

        render: function () {
            return $(this.$el).html(this.template(this.model.attributes));
        }
    });

    var ProjectDetailsScreen = Backbone.View.extend({
        el: $('body'),
        initialize: function () {
            _.bindAll(this, 'render');

//            var renderedTasks = $(".task");
//            for (var k = 0; k < renderedTasks.size(); k++) {
//                var task = $(renderedTasks[k]);
//                new TaskView({el: renderedTasks[k], model: new Task({id: task.data("taskid"), name: task.data("taskname"),
//                    notes: task.data("tasknotes")})});
//            }
//
//            var renderedDroppables = $(".droppable");
//            for (var k = 0; k < renderedDroppables.size(); k++) {
//                var droppable = $(renderedDroppables[k]);
//                new DroppableView({el: renderedDroppables[k]});
//            }
//
//            var phases = $(".phase");
//            for (var k = 0; k < phases.size(); k++) {
//                var phase = $(phases[k]);
//                new PhaseView({el: phase[k]});
//            }

            //DroppableView

//            this.render();

//            $(".assignment").select2();

//            this.$el.find(".notes").toggle();

        },
        render: function () {
            var that = this;
            AjaxRequests.allTasks({}, function (data) {
                for (var i = 0; i < data.root.length; i++) {
                    /* store userlinks for later use */
                    that.userlinks = data.userlinks;

                    $(".details-container").append(
                        new PhaseView({model: new Phase(data.root[i])}).render().el
                    );
                }
            });
        }
    });

    var projectDetailsScreen = new ProjectDetailsScreen();
    projectDetailsScreen.render();

})(jQuery);
