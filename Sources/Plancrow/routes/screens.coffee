#
# * GET screen 09 projets list.
# 
conf = require("../my_modules/crow-conf.coffee")
exports.wireIn = (app, auth) ->
    app.get "/pages/05_company_admin", exports.screen05_company_admin
    app.get "/pages/06_user_settings", exports.screen06_user_settings
    app.get "/pages/07_user_list", exports.screen07_user_list
    app.get "/pages/08_invitation", exports.screen08_invitation
    app.get "/pages/09_project_list", auth, exports.screen09_project_list
    app.get "/pages/10_project_creation", exports.screen10_project_creation
    app.get "/pages/11_project_settings", exports.screen11_project_settings
    app.get "/pages/12_project_details", exports.screen12_project_details
    app.get "/pages/13_customer", exports.screen13_customers
    app.get "/pages/14_edit_customer", exports.screen14_edit_customer
    app.get "/pages/15_invoicing_for_project", exports.screen15_invocing_for_project
    app.get "/pages/16_invoices_history", exports.screen16_invoices_history
    app.get "/pages/17_invoice_saving", exports.screen17_invoice_saving
    app.get "/pages/18_reports_page", exports.screen18_reports_page
    app.get "/pages/19_management_report_screen", exports.screen19_management_report_screen
    app.get "/pages/20_project_chart", exports.screen20_project_chart
    app.get "/pages/21_user_timing_history", exports.screen21_user_timing_history
    app.get "/pages/22_post_time", exports.screen22_post_time
    app.get "/pages/23_public_project_registration", exports.screen23_public_project_registration
    app.get "/pages/24_public_projects", exports.screen24_public_projects

exports.screen01_welcome_page = (req, res) ->
    res.render "screens/01_welcome_page",
        title: "Plancrow"
        screen_name: "01 Welcome Page"


exports.screen02_pricing_page = (req, res) ->
    res.render "screens/02_pricing_page",
        title: "Plancrow"
        screen_name: "02 Pricing Page"


exports.screen03_registration_page = (req, res) ->
    res.render "screens/03_registration_page",
        title: "Plancrow"
        screen_name: "03 Registration Page"


exports.screen04_sign_in_page = (req, res) ->
    res.render "screens/04_sign_in_page",
        title: "Plancrow"
        screen_name: "04 Sign In Page"


exports.screen05_company_admin = (req, res) ->
    res.render "screens/05_company_admin",
        title: "Plancrow"
        screen_name: "05 Company Admin"


exports.screen06_user_settings = (req, res) ->
    res.render "screens/06_user_settings",
        title: "Plancrow"
        screen_name: "06 User Settings"


exports.screen07_user_list = (req, res) ->
    res.render "screens/07_user_list",
        title: "Plancrow"
        screen_name: "07 User List"


exports.screen08_invitation = (req, res) ->
    res.render "screens/08_invitation",
        title: "Plancrow"
        screen_name: "08 Invitation"


exports.screen09_project_list = (req, res) ->
    req.models.project.find {}, (err, projects) ->
        projects = new Array()  if projects is `undefined`
        res.render "screens/09_project_list",
            title: "Plancrow"
            screen_name: "09 Project List"
            projects: projects



exports.screen10_project_creation = (req, res) ->
    res.render "screens/10_project_creation",
        title: "Plancrow"
        screen_name: "10 Project Creation"


exports.screen11_project_settings = (req, res) ->
    res.render "screens/11_project_settings",
        title: "Plancrow"
        screen_name: "11 Project Settings"


tree_from_list = (list, tasks) ->
    map = new Array()
    result = new Array()
    missed = new Array()
    for i of list
        list[i].children = `undefined`
        list[i].tasks = `undefined`
    for i of list
        node = list[i]
        map[node.id] = node
        unless node.parent_id?
            result.push node
        else
            unless map[node.parent_id] is `undefined`
                map[node.parent_id].children = new Array()  if map[node.parent_id].children is `undefined`
                map[node.parent_id].children.push node
            else
                missed.push node
    for i of tasks
        task = tasks[i]
        task.completed = task.posted / task.estimate * 100
        task.overdue = task.completed - 100  if task.completed > 100
        unless map[task.project_phase_id] is `undefined`
            phase = map[task.project_phase_id]
            phase.tasks = new Array()  if phase.tasks is `undefined`
            phase.tasks.push task
    result

exports.screen12_project_details = (req, res) ->
    conf.withCompany req, (company) ->
        req.models.project.get conf.currentlyAuthorized(req).project_id, (err, project) ->
            req.models.project_phase.phases project.id, (err, phases) ->
                req.models.task.tasksByProject project.id, (err, tasks) ->
                    res.render "screens/12_project_details",
                        title: "Plancrow"
                        screen_name: "12 Project Details"
                        project: project
                        phases: tree_from_list(phases, tasks)
                        cur_config: company





exports.screen13_customers = (req, res) ->
    res.render "screens/13_customers",
        title: "Plancrow"
        screen_name: "13 Customers"


exports.screen14_edit_customer = (req, res) ->
    res.render "screens/14_edit_customer",
        title: "Plancrow"
        screen_name: "14 Edit Customer"


exports.screen15_invocing_for_project = (req, res) ->
    res.render "screens/15_invoicing_for_project",
        title: "Plancrow"
        screen_name: "15 Invoicing For Project"


exports.screen16_invoices_history = (req, res) ->
    res.render "screens/16_invoices_history",
        title: "Plancrow"
        screen_name: "16 Invoices History"


exports.screen17_invoice_saving = (req, res) ->
    res.render "screens/17_invoice_saving",
        title: "Plancrow"
        screen_name: "17 Invoice Saving"


exports.screen18_reports_page = (req, res) ->
    res.render "screens/18_reports_page",
        title: "Plancrow"
        screen_name: "18 Reports Page"


exports.screen19_management_report_screen = (req, res) ->
    res.render "screens/19_management_report_screen",
        title: "Plancrow"
        screen_name: "19 Management Report Screeen"


exports.screen20_project_chart = (req, res) ->
    res.render "screens/20_project_chart",
        title: "Plancrow"
        screen_name: "20 Project Chart"


exports.screen21_user_timing_history = (req, res) ->
    res.render "screens/21_user_timing_history",
        title: "Plancrow"
        screen_name: "21 User Timing History"


exports.screen22_post_time = (req, res) ->
    res.render "screens/22_post_time",
        title: "Plancrow"
        screen_name: "22 Post Time"


exports.screen23_public_project_registration = (req, res) ->
    res.render "screens/23_public_project_registration",
        title: "Plancrow"
        screen_name: "23 Public Project Registration"


exports.screen24_public_projects = (req, res) ->
    res.render "screens/24_public_projects",
        title: "Plancrow"
        screen_name: "24 Public Projects"
