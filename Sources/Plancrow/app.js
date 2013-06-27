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
app.get('/pages/04_sign_in_page', screens.screen04_sign_in_page);
app.get('/pages/05_company_admin', screens.screen05_company_admin);
app.get('/pages/06_user_settings', screens.screen06_user_settings);
app.get('/pages/07_user_list', screens.screen07_user_list);
app.get('/pages/08_invitation', screens.screen08_invitation);
app.get('/pages/09_project_list', screens.screen09_project_list);
app.get('/pages/10_project_creation', screens.screen10_project_creation);
app.get('/pages/11_project_settings', screens.screen11_project_settings);
app.get('/pages/12_project_details', screens.screen12_project_details);
app.get('/pages/13_customer', screens.screen13_customers);
app.get('/pages/14_edit_customer', screens.screen14_edit_customer);
app.get('/pages/15_invoicing_for_project', screens.screen15_invocing_for_project);
app.get('/pages/16_invoices_history', screens.screen16_invoices_history);
app.get('/pages/17_invoice_saving', screens.screen17_invoice_saving);
app.get('/pages/18_reports_page', screens.screen18_reports_page);
app.get('/pages/19_management_report_screen', screens.screen19_management_report_screen);
app.get('/pages/20_project_chart', screens.screen20_project_chart);
app.get('/pages/21_user_timing_history', screens.screen21_user_timing_history);
app.get('/pages/22_post_time', screens.screen22_post_time);
app.get('/pages/23_public_project_registration', screens.screen23_public_project_registration);
app.get('/pages/24_public_projects', screens.screen24_public_projects);


app.post('/json/task/update', crowapi.updateTask);
app.post('/json/task/move', crowapi.moveTask);
app.post('/json/task/delete', crowapi.deleteTask);

http.createServer(app).listen(app.get('port'), function () {
    console.log('Express server listening on port ' + app.get('port'));
});
