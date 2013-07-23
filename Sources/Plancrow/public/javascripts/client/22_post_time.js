(function ($) {

    var jade = require("jade");

    var Assigment = Backbone.Model.extend({
        defaults: {
            id: -1,
            name: 'n/a'
        }
    });

    var AssigmentView = Backbone.View.extend({
        tagName: "tr",

        template: jade.compile(templates.AssignmentView), /* defined in template.coffe */

        events: {
            "focus input.posttime_val": "clearPosttimeVal",
            "click .posttime": "postTime"
        },

        initialize: function () {
            _.bindAll(this, 'render', 'postTime', 'clearPosttimeVal');
        },

        render: function () {
            this.$el.html(this.template(this.model.attributes))
            return this;
        },

        clearPosttimeVal: function() {
            this.$el.find('.posttime_val').val('')
        },

        postTime: function (src) {
            var that = this;
            var time_inc = this.$el.find('.posttime_val').val();
            AjaxRequests.postTime({
                task_id: this.model.attributes.task_id,
                time_inc: time_inc,
                timing_date: new Date(),
                userlink_id: this.model.attributes.userlink_id}, function (data) {
                console.info(data);
                that.$el.find('.posttime_val').val(data.status);
            });
        }
    });

    var PostTimeScreen = Backbone.View.extend({
        el: $('body'),

        initialize: function () {
            _.bindAll(this, 'render');
        },

        render: function () {
            AjaxRequests.assignedTasks({}, function (data) {
                for (var i = 0; i < data.assignments.length; i++) {
                    $(".assignments").append(
                        new AssigmentView({model: new Assigment(data.assignments[i])}).render().el
                    );
                }
            });
        }
    });

    var PostTimeScreen = new PostTimeScreen();
    PostTimeScreen.render();

})(jQuery);
