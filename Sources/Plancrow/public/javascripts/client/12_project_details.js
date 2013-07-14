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
        template: jade.compile('div.row-fluid.task(id ="#{id}", data-taskid="#{id}", data-taskname = "#{name}", data-tasknotes = "#{notes}")' +
            '\n\tdiv.name.span1' +
            '\n\t\ti.icon-tasks.pull-right' +
            '\n\tdiv.name.span5 Task: #{name}' +
            '\n\t\tdiv.notes(style="display:none;")= notes' +
            '\n\tdiv.span3' +
            '\n\t\tp [est.: #{estimate}, posted: #{posted}]' +
            '\n\tdiv.span1' +
            '\n\t\tbutton.btn.btn-mini.btn-danger.delete delete' +
            '\n\tdiv.span1' +
            '\n\t\tbutton.btn.btn-mini.btn-info.details details' +
            '\n\tdiv.span1' +
            '\n\t\tdiv.btn-group.status' +
            '\n\t\t\ta.btn.btn-mini.btn-primary' +
            '\n\t\t\t\t- if (status == "A"){' +
            '\n\t\t\t\t\tfont Active' +
            '\n\t\t\t\t- }else if (status == "N"){' +
            '\n\t\t\t\t\tfont Not Started' +
            '\n\t\t\t\t- }else if (status == "C"){' +
            '\n\t\t\t\t\tfont Completed' +
            '\n\t\t\t\t- }' +
            '\n\t\t\ta.btn.btn-mini.btn-primary.dropdown-toggle(data-toggle="dropdown")' +
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
            "click button.delete" : "deleteTask",
            "click button.details" : "details",
            "click .status a[role = 'menuitem']": "changeStatus"
        },

        initialize: function () {
            _.bindAll(this, 'render', 'rename', 'saveRenamed', 'deleteTask', 'details', 'changeStatus', '_dragStartEvent');

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

        render:function () {
            $(this.el).addClass("task").attr("data-taskid", this.model.attributes.id);
//            $.data(this.el, "taskid", this.model.attributes.id);
//            $(this.el).data("taskid") = this.model.attributes.id;
//                (id = "#{id}, data-taskid = "#{id}").task
            return $(this.el).html(this.template(this.model.attributes));
        },

        rename: function () {
            $(this.el).html(this.editTemplate(this.model.attributes));
            $(this.el).find(".editname").focus();
            this.el.addEventListener('blur', this.saveRenamed, true);
        },

        saveRenamed: function(){
            var that = this
            //and jquery-coin "saved" notification
            var newName = $(this.el).find(".editname").val();
            this.model.attributes.name = newName;
            AjaxRequests.updateTask(this.model.attributes, function(task){
                $.extend(that.model.attributes, task);
                that.render();
            })
        },

        deleteTask: function(){
            var that = this;
            AjaxRequests.deleteTask(this.model.attributes, function(response){
                if (response.status !== "undefined" && response.status === "error"){
                    window.alert(response.message);
                }else{
                    that.$el.remove();
                }
            })
        },

        details: function(){
            this.$el.find(".notes").toggle();
        },

        changeStatus: function(src){
            var that = this
            //and jquery-coin "saved" notification
            this.model.attributes.status = $(src.target).data("status");
            AjaxRequests.updateTask(this.model.attributes, function(task){
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
            '\tdiv.name.span2.droppable(data-phase-id=id) drag here [   ]\n' +
            '\tdiv.name.span2\n' +
            '\t\tbutton.btn.btn-primary.addphase(type="button", data-phase-id=id) + phase\n' +
            '\tdiv.name.span2\n' +
            '\t\tbutton.btn.btn-primary.addtask(type="button", data-phase-id=id) + task\n' +
            'ul'),

        events: {
            "click .addtask": "addTask",
            "click .addphase": "addPhase"
        },

        initialize: function () {
            _.bindAll(this, 'addTask', 'addPhase', 'render');
        },

        addTask: function(target){
           var phase_id = $(target.toElement).data("phase-id");
            AjaxRequests.addTask({phase_id: phase_id}, function(task){
                $("li.phase[id=" + phase_id + "]").append(
                    new TaskView({model: new Task(task)}).render()
                );
            })
        },

        addPhase: function(target){
            var phase_id = $(target.toElement).data("phase-id");
            AjaxRequests.addPhase({parent_phase_id: phase_id}, function(phase){
                $("li.phase[id=" + phase_id + "] ul").prepend(
                    new PhaseView({model: new Phase(phase)}).render()
                );
            });
        },

        render:function () {
            $(this.el).addClass("phase").attr("phase-id", this.model.attributes.id);
            return $(this.el).html(this.template(this.model.attributes));
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
            AjaxRequests.moveTask({task_id: data.id, to_phase: to_phase}, function(task){
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

        render:function () {
            return $(this.$el).html(this.template(this.model.attributes));
        }
    });

    var ProjectDetailsScreen = Backbone.View.extend({
        el: $('body'),
        initialize: function () {
            _.bindAll(this, 'render');

            var renderedTasks = $(".task");
            for (var k = 0; k < renderedTasks.size(); k++) {
                var task = $(renderedTasks[k]);
//                console.info(task.data("taskid"));
//                console.info(task.data("taskname"));
                new TaskView({el: renderedTasks[k], model: new Task({id: task.data("taskid"), name: task.data("taskname"),
                    notes: task.data("tasknotes")})});
            }

            var renderedDroppables = $(".droppable");
            for (var k = 0; k < renderedDroppables.size(); k++) {
                var droppable = $(renderedDroppables[k]);
                new DroppableView({el: renderedDroppables[k]});
            }

            var phases = $(".phase");
            for (var k = 0; k < phases.size(); k++) {
                var phase = $(phases[k]);
                new PhaseView({el: phase[k]});
            }

            //DroppableView

//            this.render();

            this.$el.find(".notes").toggle();
//            $('.dropdown-toggle').dropdown();
        },
        render: function () {
//            $(this.el).append("<button id='add'>Add list item</button>");
        }
    });

    var ProjectDetailsScreen = new ProjectDetailsScreen();

})(jQuery);
