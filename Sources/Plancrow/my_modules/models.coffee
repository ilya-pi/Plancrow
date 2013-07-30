orm = require("orm")
conf = require("./crow-conf")
exports.wireInModels = (app) ->
    app.use orm.express(conf.mysqlConnectionString(),
        define: (db, models) ->

            # no transactions atm
            #             db.use(transaction);
            #
            db.settings.set "instance.cache", false
            models.assignment = db.define("ASSIGNMENT",
                id: Number
                company_id: Number
                amnd_date: Date
                amnd_user: Number
                project_id: Number
                userlink_id: Number
                task_id: Number
                type: String
                notes: String
            ,
                cache: false
            )
            models.company = db.define("COMPANY",
                id: Number
                name: String
                url_ext: String
                currency_id: Number
                plan: String
                plan_expires: Date
                limit_projects: Number
                limit_users: Number
                notiff_day: Number
                time_unit: String
                created_at: Date
            )
            models.appUser = db.define("APP_USER",
                id: Number
                login: String
                pwd: Boolean
                first_name: String
                second_name: String
                salutation: String
                created_at: Date
                primary_email: String
                is_active: String
            )
            models.project = db.define("PROJECT",
                id: Number
                name: String
                is_active: Boolean
                estimate: Number
                invoice_name: String
                order_num: Number
            )
            models.project_phase = db.define("PROJECT_PHASE",
                id: Number
                amnd_date: Date
                amnd_user: Number
                project_id: Number
                parent_id: Number
                name: String
                notes: String
                short_name: String
                order_num: Number
            ,
                cache: false # nb!: otherwise phase movements are screwed
            )
            models.task = db.define("TASK",
                id: Number
                company_id: Number
                amnd_date: Date
                amnd_user: Number
                project_phase_id: Number
                project_id: Number
                name: String
                notes: String
                estimate: Number
                posted: Number
                status: String
                order_num: Number
            ,
                cache: false # nb!: otherwise assignments are not picked up quick enough
            )
            models.timing = db.define("TIMING",
                id: Number
                company_id: Number
                amnd_date: Date
                amnd_user: Number
                task_id: Number
                value: Number
                timing_date: Number
                userlink_id: Number
                rate_id: Number
                project_id: Number
                notes: String
            ,
                cache: false # nb!: otherwise assignments are not picked up quick enough
            )
            models.userlink = db.define("USERLINK",
                id: Number
                company_id: Number
                user_id: Number
                amnd_date: Date
                amnd_user: Number
                email: String
                role: String
                is_active: String
                job_title: String
            )
            models.project_phase.topPhases = (projectId, callback) ->
                @find
                    project_id: projectId
                    parent_id: null
                , callback

            models.project_phase.phases = (projectId, callback) ->
                @find
                    project_id: projectId
                , callback

            models.task.tasksByProject = (projectId, callback) ->
                @find
                    project_id: projectId
                , callback

            models.assignment.hasOne "task", models.task,
                autoFetch: true

            models.userlink.hasOne "user", models.appUser,
                required: true
                autoFetch: true

            models.project_phase.hasOne "parent", models.project_phase,
                reverse: "children"

    )