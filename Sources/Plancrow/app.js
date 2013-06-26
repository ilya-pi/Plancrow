/**
 * Module dependencies.
 */

var express = require('express')
    , routes = require('./routes')
    , user = require('./routes/user')
    , screens = require('./routes/screens')
    , http = require('http')
    , path = require('path')
    , conf = require('./my_modules/crow-conf.js')
    , crowapi= require('./my_modules/crow-api.js')
    , orm = require('orm');

var app = express();

//orm
app.use(orm.express(conf.mysqlConnectionString(), {
    define: function (db, models) {
        models.project = db.define("PROJECT", {
            id: Number,
            name: String,
            is_active: Boolean,
            estimate: Number
        });

        models.project_phase = db.define("PROJECT_PHASE", {
            id: Number,
            amnd_date: Date,
            amnd_user: Number,
            project_id: Number,
            name: String,
            notes: String
        });

        models.task = db.define("TASK", {
            id: Number,
            company_id: Number,
            amnd_date: Date,
            amnd_user: Number,
            project_phase_id: Number,
            project_id: Number,
            name: String,
            notes: String,
            estimate: Number,
            posted: Number,
            status: String
        });

        models.project_phase.topPhases = function (projectId, callback) {
            this.find({ project_id: projectId, parent_id: null }, callback);
        };

        models.project_phase.phases = function (projectId, callback) {
            this.find({ project_id: projectId}, callback);
        };

        models.task.tasksByProject = function (projectId, callback) {
            this.find({ project_id: projectId}, callback);
        };

        models.project_phase.hasOne("project", models.project);
        models.project.hasMany("phases", models.project_phase);

        models.project_phase.hasOne("parent", models.project_phase, {
            reverse: "children"
        });
    }
}));

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(express.cookieParser('your secret here'));
app.use(express.session());
app.use(app.router);
app.use(require('less-middleware')({ src: __dirname + '/public' }));
app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
    app.use(express.errorHandler());
}

app.get('/', routes.index);
app.get('/users', user.list);
app.get('/pages/01_welcome_page', screens.screen01_welcome_page);
app.get('/pages/02_pricing_page', screens.screen02_pricing_page);
app.get('/pages/03_registration_page', screens.screen03_registration_page);
app.get('/pages/09_project_list', screens.screen09_project_list);
app.get('/pages/12_project_details', screens.screen12_project_details);


app.post('/json/task/update', crowapi.updateTask);
app.post('/json/task/move', crowapi.moveTask);
app.post('/json/task/delete', crowapi.deleteTask);

http.createServer(app).listen(app.get('port'), function () {
    console.log('Express server listening on port ' + app.get('port'));
});
