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

        template: jade.compile(
            'td= task.name\n' +
            'td.input-append(style="display: table-cell;")\n' +
            '\tinput.posttime(type="text", value=task.posted)\n' +
            '\tbutton.btn(type="button") Post'),

        events: {
            "blur": "postTime"
        },

        initialize: function () {
            _.bindAll(this, 'render', 'postTime');
        },

        render: function () {
            this.$el.html(this.template(this.model.attributes))
            return this;
        },

        postTime: function () {
            console.info("called post time");
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
