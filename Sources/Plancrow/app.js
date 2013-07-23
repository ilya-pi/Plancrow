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
    , models = require('./my_modules/models.js')
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

models.wireInModels(app);

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
    done(null, user.id);
});

passport.deserializeUser(function (id, done) {
    AppUser.get(id, function (err, user) {
        done(err, user);
    });
});

app.use(app.router);
app.use(require('less-middleware')({ src: __dirname + '/public' }));
app.use(require('connect-coffee-script')({ src: __dirname + '/public', dest: __dirname + '/public', bare: true }));
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

screens.wireIn(app, check_auth);
crowapi.wireIn(app);

http.createServer(app).listen(app.get('port'), function () {
    console.log('Express server listening on port ' + app.get('port'));
});
