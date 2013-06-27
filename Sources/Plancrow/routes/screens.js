/*
 * GET screen 09 projets list.
 */

var conf = require('../my_modules/crow-conf.js');

exports.screen01_welcome_page = function (req, res) {
    res.render('screens/01_welcome_page', { title: 'Plancrow', screen_name: '01 Welcome Page'});
};

exports.screen02_pricing_page = function (req, res) {
    res.render('screens/02_pricing_page', { title: 'Plancrow', screen_name: '02 Pricing Page'});
};

exports.screen03_registration_page = function (req, res) {
    res.render('screens/03_registration_page', { title: 'Plancrow', screen_name: '03 Registration Page'});
};

exports.screen04_sign_in_page = function (req, res) {
    res.render('screens/04_sign_in_page', { title: 'Plancrow', screen_name: '04 Sign In Page'});
};

exports.screen05_company_admin = function (req, res) {
    res.render('screens/05_company_admin', { title: 'Plancrow', screen_name: '05 Company Admin'});
};

exports.screen06_user_settings = function (req, res) {
    res.render('screens/06_user_settings', { title: 'Plancrow', screen_name: '06 User Settings'});
};

exports.screen07_user_list = function (req, res) {
    res.render('screens/07_user_list', { title: 'Plancrow', screen_name: '07 User List'});
};

exports.screen08_invitation = function (req, res) {
    res.render('screens/08_invitation', { title: 'Plancrow', screen_name: '08 Invitation'});
};

exports.screen09_project_list = function (req, res) {
    req.models.project.find({ }, function (err, projects) {
        if (projects == undefined) {
            projects = new Array()
        }
        res.render('screens/09_project_list', { title: 'Plancrow', screen_name: '09 Project List', projects: projects});
    });
};

exports.screen10_project_creation = function (req, res) {
    res.render('screens/10_project_creation', { title: 'Plancrow', screen_name: '10 Project Creation'});
};

exports.screen11_project_settings= function (req, res) {
    res.render('screens/11_project_settings', { title: 'Plancrow', screen_name: '11 Project Settings'});
};


var tree_from_list = function (list, tasks) {
    var map = new Array();
    var result = new Array();
    var missed = new Array();
    for (i in list) {
        list[i].children = undefined
        list[i].tasks = undefined
    }
    for (i in list) {
        var node = list[i];
        map[node.id] = node;
        if (node.parent_id == null) {
            result.push(node);
        } else {
            if (map[node.parent_id] != undefined) {
                if (map[node.parent_id].children == undefined) {
                    map[node.parent_id].children = new Array()
                }
                map[node.parent_id].children.push(node)
            } else {
                missed.push(node);
            }
        }
    }
    for (i in tasks) {
        var task = tasks[i];
        task.completed = task.posted / task.estimate * 100;
        if (task.completed > 100) {
            task.overdue = task.completed - 100;
        }
        if (map[task.project_phase_id] != undefined) {
            var phase = map[task.project_phase_id];
            if (phase.tasks == undefined) {
                phase.tasks = new Array();
            }
            phase.tasks.push(task);
        }
    }
    return result;
}

exports.screen12_project_details = function (req, res) {
    req.models.project.get(conf.currentlyAuthorized().project_id, function (err, project) {
        req.models.project_phase.phases(project.id, function (err, phases) {
            req.models.task.tasksByProject(project.id, function (err, tasks) {
                res.render('screens/12_project_details', { title: 'Plancrow', screen_name: '12 Project Details', project: project, phases: tree_from_list(phases, tasks)});
            });
        });
    });
};

exports.screen13_customers= function (req, res) {
    res.render('screens/13_customers', { title: 'Plancrow', screen_name: '13 Customers'});
};

exports.screen14_edit_customer = function (req, res) {
    res.render('screens/14_edit_customer', { title: 'Plancrow', screen_name: '14 Edit Customer'});
};

exports.screen15_invocing_for_project= function (req, res) {
    res.render('screens/15_invoicing_for_project', { title: 'Plancrow', screen_name: '15 Invoicing For Project'});
};

exports.screen16_invoices_history = function (req, res) {
    res.render('screens/16_invoices_history', { title: 'Plancrow', screen_name: '16 Invoices History'});
};

exports.screen17_invoice_saving = function (req, res) {
    res.render('screens/17_invoice_saving', { title: 'Plancrow', screen_name: '17 Invoice Saving'});
};

exports.screen18_reports_page = function (req, res) {
    res.render('screens/18_reports_page', { title: 'Plancrow', screen_name: '18 Reports Page'});
};

exports.screen19_management_report_screen = function (req, res) {
    res.render('screens/19_management_report_screen', { title: 'Plancrow', screen_name: '19 Management Report Screeen'});
};

exports.screen20_project_chart = function (req, res) {
    res.render('screens/20_project_chart', { title: 'Plancrow', screen_name: '20 Project Chart'});
};

exports.screen21_user_timing_history = function (req, res) {
    res.render('screens/21_user_timing_history', { title: 'Plancrow', screen_name: '21 User Timing History'});
};

exports.screen22_post_time = function (req, res) {
    res.render('screens/22_post_time', { title: 'Plancrow', screen_name: '22 Post Time'});
};

exports.screen23_public_project_registration = function (req, res) {
    res.render('screens/23_public_project_registration', { title: 'Plancrow', screen_name: '23 Public Project Registration'});
};

exports.screen24_public_projects = function (req, res) {
    res.render('screens/24_public_projects', { title: 'Plancrow', screen_name: '24 Public Projects'});
};

