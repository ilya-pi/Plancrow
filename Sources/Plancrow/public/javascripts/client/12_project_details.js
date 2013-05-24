(function ($) {

    var jade = require("jade");

    var Task = Backbone.Model.extend({
        defaults: {
            id: -1,
            name: 'n/a'
        }
    });

    var TaskView = Backbone.View.extend({
//        template:jade.compile('\ndiv.num #{number}\ndiv.img\n\tdiv\n\t\timg(alt="logo", width="105px", src="http://graph.facebook.com/" + fb_id + "/picture?type=large")\ndiv.description\n\th3 #{name}\n\tdiv\n\t\tp.time #{time}\n\t\tp.location #{venue}\n\tp.desc #{description}\na.button(href="http://facebook.com/" + fb_id,target="_blank")\n\tdiv.arrow'),
        template: jade.compile('div.row-fluid\n\tdiv.name.span2= name\n\tdiv.span4 there is no saving yet'),
        editTemplate: jade.compile('div.row-fluid\n\tdiv.span4\n\t\tinput.editname(type="text", value=name)'),

        events: {
            "click .name": "rename",
            "blur": "saveRenamed"
        },

        initialize: function () {
            _.bindAll(this, 'rename', 'saveRenamed');
        },

//        render:function () {
//            return $(this.el).html(this.template(this.model));
//        },

        rename: function () {
            $(this.el).html(this.editTemplate(this.model.attributes));
            $(this.el).find(".editname").focus();
            this.el.addEventListener('blur', this.saveRenamed, true);
        },

        saveRenamed: function(){
            //and jquery-coin "saved" notification
            $(this.el).html(this.template(this.model.attributes));
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
