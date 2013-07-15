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
            'td= name\n' +
            'td\n' +
            '\tinput.posttime(type="text", value=posted)\n'),

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
