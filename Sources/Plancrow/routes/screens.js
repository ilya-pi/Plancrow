/*
 * GET screen 09 projets list.
 */

var conf = require('../my_modules/crow-conf.js');

exports.screen01_welcome_page = function (req, res) {
    res.render('screens/01_welcome_page', { title: 'Plancrow', screen_name: '01 Welcome Page'});
};

exports.screen02_pricing_page = function (req, res) {
    res.render('screens/02_pricing_page', { title: 'Plancrow', screen_name: '01 Pricing Page'});
};

exports.screen03_registration_page = function (req, res) {
    res.render('screens/03_registration_page', { title: 'Plancrow', screen_name: '03 Registration Page'});
};

exports.screen09_project_list = function (req, res) {
    req.models.project.find({ }, function (err, projects) {
        if (projects == undefined) {
            projects = new Array()
        }
        res.render('screens/09_project_list', { title: 'Plancrow', screen_name: '09 Project List', projects: projects});
    });
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