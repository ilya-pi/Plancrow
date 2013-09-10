###
Module dependencies.
###
express = require("express")
routes = require("./routes")
gzippo = require('gzippo')

screens = require("./routes/screens")
http = require("http")
path = require("path")
conf = require("./my_modules/crow-conf")
crowapi = require("./my_modules/crow-api")
orm = require("orm")
models = require("./my_modules/models")
passport = require("passport")
LocalStrategy = require("passport-local").Strategy
locale = require("locale")
supported = ["en", "en_US", "en_GB", "nl", "fr", "de", "it", "nb", "nn", "sv", "fr_CA"]
app = express()

AppUser = undefined
orm.connect conf.mysqlConnectionString(), (err, db) ->
    throw err  if err
    AppUser = db.define("APP_USER",
        id: Number
        login: String
        pwd: String
        first_name: String
        second_name: String
        salutation: String
        created_at: Date
        primary_email: String
        is_active: String
    ,
        methods:
            validPassword: (password) ->
                @pwd is password
    )

models.wireInModels app
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser("your secret here")
app.use express.session()
app.use passport.initialize()
app.use passport.session()
app.use locale(supported)
passport.use new LocalStrategy((username, password, done) ->
    AppUser.find
        login: username
    , (err, user) ->
        return done(err)  if err
        if user.length > 1
            return done(null, false,
                message: "Inconsistent data."
            )
        unless user[0]
            return done(null, false,
                message: "Incorrect username."
            )
        unless user[0].validPassword(password)
            return done(null, false,
                message: "Incorrect password."
            )
        done null, user[0]

)
passport.serializeUser (user, done) ->
    done null, user.id

passport.deserializeUser (id, done) ->
    AppUser.get id, (err, user) ->
        done err, user


app.use app.router
app.use require("less-middleware")(
    src: __dirname + "/public"
    dest:__dirname + "/public_compiled_css"
)
app.use require("connect-coffee-script")(
    src: __dirname + "/public"
    dest: __dirname + "/public_compiled_js"
    bare: true
)

app.use require("connect-coffee-script")(
    src: __dirname + "/public"
    dest: __dirname + "/public_compiled_js"
    bare: true
)
app.use express.static(path.join(__dirname, "public"))
app.use express.static(path.join(__dirname, "public_compiled_js"))
#app.use gzippo.staticGzip(path.join(__dirname, "public_compiled_packed_js"))
app.use gzippo.staticGzip(path.join(__dirname, "public_compiled_css"))
app.use express.errorHandler()  if "development" is app.get("env")
app.use express.compress()
#app.get "/", routes.index
app.get "/", routes.landing
app.get "/terms", routes.terms
app.get "/stat", routes.stat
#app.get "/pages/01_welcome_page", screens.screen01_welcome_page
#app.get "/pages/02_pricing_page", screens.screen02_pricing_page
#app.get "/pages/03_registration_page", screens.screen03_registration_page
#app.get "/pages/04_sign_in_page", screens.screen04_sign_in_page
#app.post "/pages/04_sign_in_page", passport.authenticate("local",
#    successRedirect: "/pages/09_project_list"
#    failureRedirect: "/pages/04_sign_in_page"
#)

ensureAuthenticated = (req, res, next) ->
    if req.isAuthenticated()
        return next()
    res.redirect('/pages/04_sign_in_page')

screens.wireIn app, ensureAuthenticated
#screens.wireIn app, (req, res, next) ->
#    next()
crowapi.wireIn app
http.createServer(app).listen app.get("port"), ->
    console.log "Express server listening on port " + app.get("port")

