jade = require("jade") #yet to be refactored as an AMD dependency. currently relying on CommonJS

requirejs.config
    paths:
        "jquery": "/scripts/vendor/jquery/jquery"
        "underscore": "/scripts/vendor/underscore-amd/underscore"
        "backbone": "/scripts/vendor/backbone-amd/backbone"

requirejs ['views/PostTimeView'], (PostTimeScreenView) ->
    new PostTimeScreenView()