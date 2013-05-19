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
    , orm = require('orm');

var app = express();

//orm
app.use(orm.express(conf.mysqlConnectionString(), {
    define: function (db, models) {
        models.project = db.define("PROJECT", {
            name    : String,
            is_active: Boolean,
            estimate : Number
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
app.get('/screens/09_project_list', screens.screen09_project_list);

http.createServer(app).listen(app.get('port'), function () {
    console.log('Express server listening on port ' + app.get('port'));
});
