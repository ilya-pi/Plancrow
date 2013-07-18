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
    , crowapi = require('./my_modules/crow-api.js')
    , orm = require('orm')
//    , transaction = require("orm-transaction")
    , passport = require('passport')
    , LocalStrategy = require('passport-local').Strategy;

var app = express();

//move to separate module
orm.connect(conf.mysqlConnectionString(), function (err, db) {
    if (err) throw err;
    AppUser = db.define("APP_USER", {
        id: Number,
        login: String,
        pwd: String,
        first_name: String,
        second_name: String,
        salutation: String,
        created_at: Date,
        primary_email: String,
        is_active: String
    }, {
        methods: {
            validPassword: function (password) {
                return (this.pwd === password);
            }
        }});
});

//orm
app.use(orm.express(conf.mysqlConnectionString(), {
    define: function (db, models) {

//        db.use(transaction);
        db.settings.set('instance.cache', false);

        models.assignment = db.define("ASSIGNMENT", {
                id: Number,
                company_id: Number,
                amnd_date: Date,
                amnd_user: Number,
                project_id: Number,
                userlink_id: Number,
                task_id: Number,
                type: String,
                notes: String
            },
            {cache: false}
        );

        models.appUser = db.define("APP_USER", {
            id: Number,
            login: String,
            pwd: Boolean,
            first_name: String,
            second_name: String,
            salutation: String,
            created_at: Date,
            primary_email: String,
            is_active: String
        });

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
            parent_id: Number,
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
            }
            ,
            {cache: false} /* nb!: otherwise assignments are not picked up quick enough */
        );

        models.timing = db.define("TIMING", {
                id: Number,
                company_id: Number,
                amnd_date: Date,
                amnd_user: Number,
                task_id: Number,
                value: Number,
                timing_date: Date,
                userlink_id: Number,
                rate_id: Number,
                project_id: Number
            },
            {cache: false} /* nb!: otherwise assignments are not picked up quick enough */
        );

        models.userlink = db.define("USERLINK", {
            id: Number,
            company_id: Number,
            user_id: Number,
            amnd_date: Date,
            amnd_user: Number,
            email: String,
            role: String,
            is_active: String,
            job_title: String
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

        models.assignment.hasOne("task", models.task, { //reverse: "assignments", -- doesn't work for some reason on save
            autoFetch: true});
        //the follow up line might be required, though not sure
//        models.assignment.hasOne("userlink", models.userlink, { required: true,  autoFetch: true }); //column 'userlink_id' in 'assignment' table

        models.userlink.hasOne("user", models.appUser, { required: true, autoFetch: true }); //column 'userlink_id' in 'assignment' table

//        models.project_phase.hasOne("project", models.project);
//        models.project.hasMany("phases", models.project_phase);

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
app.use(passport.initialize());
app.use(passport.session());

passport.use(new LocalStrategy(
    function (username, password, done) {
        AppUser.find({login: username }, function (err, user) {
            if (err) {
                return done(err);
            }
            if (user.length > 1) {
                return done(null, false, { message: 'Inconsistent data.' });
            }
            if (!user[0]) {
                return done(null, false, { message: 'Incorrect username.' });
            }
            if (!user[0].validPassword(password)) {
                return done(null, false, { message: 'Incorrect password.' });
            }
            return done(null, user[0]);
        });
    }
));

passport.serializeUser(function (user, done) {
//    console.log(user)
//    console.log(user.id)
    done(null, user.id);
});

passport.deserializeUser(function (id, done) {
    AppUser.get(id, function (err, user) {
        done(err, user);
    });
});

app.use(app.router);
app.use(require('less-middleware')({ src: __dirname + '/public' }));
app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
    app.use(express.errorHandler());
}

function check_auth(req, res, next) {
    console.info(req.user);
    if (req.user == undefined) {
        console.info(user);
        res.redirect("/pages/04_sign_in_page");
    } else {
        next();
    }
}

app.get('/', routes.index);
app.get('/users', user.list);
app.get('/pages/01_welcome_page', screens.screen01_welcome_page);
app.get('/pages/02_pricing_page', screens.screen02_pricing_page);
app.get('/pages/03_registration_page', screens.screen03_registration_page);
app.get('/pages/04_sign_in_page', screens.screen04_sign_in_page);

app.post('/pages/04_sign_in_page',
    passport.authenticate('local', { successRedirect: '/pages/09_project_list',
        failureRedirect: '/pages/04_sign_in_page'
//        ,
//        failureFlash: 'Invalid username or password.'
    })
);

app.get('/pages/05_company_admin', screens.screen05_company_admin);
app.get('/pages/06_user_settings', screens.screen06_user_settings);
app.get('/pages/07_user_list', screens.screen07_user_list);
app.get('/pages/08_invitation', screens.screen08_invitation);
app.get('/pages/09_project_list', check_auth, screens.screen09_project_list);
//app.get('/pages/09_project_list', screens.screen09_project_list);
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


app.post('/json/assignment/sync', crowapi.syncAssignment);

app.get('/json/userlinks/all', crowapi.allUserlinks);
app.post('/json/task/posttime', crowapi.postTime);
app.get('/json/task/assigned', crowapi.assignedTasks);
app.get('/json/task/all', crowapi.allTasks);

app.post('/json/phase/add', crowapi.addPhase);

app.post('/json/task/add', crowapi.addTask);
app.post('/json/task/update', crowapi.updateTask);
app.post('/json/task/move', crowapi.moveTask);
app.post('/json/task/delete', crowapi.deleteTask);

http.createServer(app).listen(app.get('port'), function () {
    console.log('Express server listening on port ' + app.get('port'));
});
