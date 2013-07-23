var orm = require('orm'),
    conf = require('../my_modules/crow-conf.js');

exports.wireIn = function(app){
    app.post('/json/assignment/sync', exports.syncAssignment);

    app.get('/json/userlinks/all', exports.allUserlinks);
    app.post('/json/task/posttime', exports.postTime);
    app.get('/json/task/assigned', exports.assignedTasks);
    app.get('/json/task/all', exports.allTasks);

    app.post('/json/phase/add', exports.addPhase);
    app.post('/json/phase/rm', exports.rmPhase);

    app.post('/json/task/add', exports.addTask);
    app.post('/json/task/update', exports.updateTask);
    app.post('/json/task/move', exports.moveTask);
    app.post('/json/task/delete', exports.deleteTask);
}

exports.postTime = function (req, res) {
    var projectId = conf.currentlyAuthorized().project_id;
    var companyId = conf.currentlyAuthorized().company_id;
    var customerId = conf.currentlyAuthorized().customer_id;

    var data = JSON.parse(req.body.data)
    var task_id = data.task_id;
    var time_inc = data.time_inc;
    var timing_date = data.timing_date;
    var userlink_id = data.userlink_id;

//    req.db.transaction(function (err, t) {
    req.models.task.get(task_id, function (err, fromdb) {

        //todo require transactions here!
        fromdb.posted = fromdb.posted + parseInt(time_inc);
        fromdb.save(function (err) {
            req.models.timing.create([
                {
                    company_id: companyId,
                    amnd_date: new Date(),
                    amnd_user: customerId,
                    task_id: task_id,
                    value: parseInt(time_inc),
                    timing_date: new Date(timing_date).getTime() / (24 * 60 * 60 * 1000), //todo ilya: refactor this to utils
                    userlink_id: userlink_id,
//                    rate_id: 1, //todo ilya: fill in correct rate here
                    project_id: projectId,
                    notes: ""
                }
            ], function (err) {
                if (err == undefined) {
//                        t.commit();
                    res.json({status: "success", error: err});
                } else {
                    res.json({status: "error", error: err});
                }
            });
        })
    });
//    });

}

exports.syncAssignment = function (req, res) {
    var projectId = conf.currentlyAuthorized().project_id;
    var companyId = conf.currentlyAuthorized().company_id;
    var customerId = conf.currentlyAuthorized().customer_id;

    var data = JSON.parse(req.body.data)
    var task_id = data.task_id;
    var userlinks = data.userlinks;
    req.models.assignment.find({task_id: task_id}, function (err, assignments) {
        for (var i = 0; i < assignments.length; i++) {

            //delete those not found any longer
            var found = userlinks.indexOf(assignments[i].userlink_id);
            if (found == -1) {
                assignments[i].remove(function (err) {
                    /* ignore for now, todo: nice error handling in future */
                    console.error(err);
                });
            } else {
                userlinks[found] = undefined;
            }
        }

        //add the new ones
        var toCreate = new Array();
        for (var k = 0; k < userlinks.length; k++) {
            if (userlinks[k] != undefined) {
                toCreate.push({
                    company_id: companyId,
                    amnd_date: new Date(),
                    amnd_user: customerId,
                    project_id: projectId,
                    userlink_id: userlinks[k],
                    task_id: task_id
                });
            }
        }

        req.models.assignment.create(toCreate, function (err, items) {
            toCreate = new Array();
            res.json({created: toCreate.length});
        });
    });
}

exports.allUserlinks = function (req, res) {
    var companyId = conf.currentlyAuthorized().company_id;
    req.models.userlink.find({company_id: companyId}, function (err, userlinks) {
        res.json({userlinks: userlinks});
    });
}

exports.assignedTasks = function (req, res) {
    var customerId = conf.currentlyAuthorized().customer_id;
    req.models.userlink.find({user_id: customerId}, function (err, userlinks) {
        var userlinksIds = userlinks.map(function (v) {
            return v.id;
        })
        req.models.assignment.find({userlink_id: userlinksIds}, function (err, assignments) {
            res.json({assignments: assignments});
        })
    });
}

var tree_from_list = function (list, tasks, cb) {
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

    var taskIds = new Array();
    for (i in tasks) {
        var task = tasks[i];
        taskIds.push(task.id);
        task.completed = task.posted / task.estimate * 100;
        if (task.completed > 100) {
            task.overdue = task.completed - 100;
        }
        if (map[task.project_phase_id] != undefined) {
            var phase = map[task.project_phase_id];
            if (phase.tasks == undefined) {
                phase.tasks = new Array();
            }
//            task.assignments = new Array(); //hack
            phase.tasks.push(task);
        }
    }
    cb(result, taskIds, tasks);
//    return result;
}

var attachAss = function(req, tree, tasks, ids, cb){
    req.models.assignment.find({task_id: ids}, function (err, asses) {
        for (var i = 0; i < tasks.length; i++) {
            var task = tasks[i];
            task.assignments = new Array();
            for (var l = 0; l < asses.length; l++){
                var ass = asses[l];
                if (ass.task_id == task.id){
                    task.assignments.push(ass);
                }
            }
        }

        cb(tree);
    });
}

exports.allTasks = function (req, res) {
    var projectId = conf.currentlyAuthorized().project_id;
    var companyId = conf.currentlyAuthorized().company_id;
    req.models.project_phase.phases(projectId, function (err, phases) {
        req.models.task.tasksByProject(projectId, function (err, tasks) {
            req.models.userlink.find({company_id: companyId}, function (err, userlinks) {
                tree_from_list(phases, tasks, function(tree, ids, task){
                    attachAss(req, tree, tasks, ids, function(tree){
                        res.json({
                            root: tree,
                            userlinks: userlinks});
                    });
                });


            });
        });
    });
}

exports.addPhase = function (req, res) {
    var data = JSON.parse(req.body.data)
//    data.parent_phase_id
    req.models.project_phase.create([
        {
            project_id: 1, //nb!: harcoded
            parent_id: data.parent_phase_id,
            name: "New Phase",
            notes: "Some Notes"
        }
    ], function (err, items) {
        res.json(items[0]);
    });
};

exports.rmPhase = function (req, res) {
    var data = JSON.parse(req.body.data)
    var projectId = conf.currentlyAuthorized().project_id;
    req.models.project_phase.find({id: data.phase_id, project_id: projectId}).remove(function (err) {
        res.json({status: err});
    });
};

exports.addTask = function (req, res) {
    var projectId = conf.currentlyAuthorized().project_id;
    var companyId = conf.currentlyAuthorized().company_id;
    var customerId = conf.currentlyAuthorized().customer_id;
    var data = JSON.parse(req.body.data)

    var dummy = {};
    dummy.isInstance = false;
    req.models.task.create(
        [{
            company_id: companyId,
            project_phase_id: data.phase_id,
            project_id: projectId,
            amnd_date: new Date(),
            amnd_user: customerId,
            name: "New Task",
            notes: "New Notes",
            estimate: 0,
            posted: 0,
            status: "N",
//            assignments: null,
            completed: 'N'
        }]
    , function (err, items) {
            //hack for now
        items[0].assignments = new Array();
            console.info(items[0]);
        res.json(items[0]);
    });
};

exports.updateTask = function (req, res) {
    var task = JSON.parse(req.body.data)
    req.models.task.get(task.id, function (err, fromdb) {
        for (i in task) {
            if (i != "id" && i != "amnd_date") {
                fromdb[i] = task[i]
            }
        }
        fromdb.save(function (err) {
            console.info(err);
            res.json(fromdb);
        })
    });
};

exports.moveTask = function (req, res) {
    var data = JSON.parse(req.body.data)
//    data.task_id
//    data.from_phase
//    data.to_phse
    req.models.task.get(data.task_id, function (err, fromdb) {
        fromdb.project_phase_id = data.to_phase;
        fromdb.save(function (err) {
            res.json(fromdb);
        })
    });
};

exports.deleteTask = function (req, res) {
    var data = JSON.parse(req.body.data)
    //todo: check that no time was posted!

    var projectId = conf.currentlyAuthorized().project_id;
    req.models.task.find({id: data.task_id, project_id: projectId}).remove(function (err) {
        console.info(err);
        res.json({
            satus: "success",
            message: "Task was deleted successfully",
            body: err
        });
    });
};