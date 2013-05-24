(function ($) {

    var jade = require("jade");

    var Task = Backbone.Model.extend({
        defaults: {
            id: -1,
            name: 'n/a'
        }
    });

    var TaskView = Backbone.View.extend({
        template: jade.compile('div.row-fluid\n\tdiv.name.span2= name\n\tdiv.span4 \n\t\tp [posted #{posted}, estimate #{estimate}]'),
        editTemplate: jade.compile('div.row-fluid\n\tdiv.span4\n\t\tinput.editname(type="text", value=name)'),

        events: {
            "click .name": "rename",
            "blur": "saveRenamed"
        },

        initialize: function () {
            _.bindAll(this, 'render', 'rename', 'saveRenamed');
        },

        render:function () {
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
                new TaskView({el: renderedTasks[k], model: new Task({id: task.data("taskid"), name: task.data("taskname")})});
            }

//            this.render();
        },
        render: function () {
//            $(this.el).append("<button id='add'>Add list item</button>");
        }
    });

    var ProjectDetailsScreen = new ProjectDetailsScreen();

})(jQuery);
