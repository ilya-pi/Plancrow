var conf = require('../my_modules/crow-conf.js');

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

exports.allTasks = function (req, res) {
    var projectId = conf.currentlyAuthorized().project_id;
    req.models.project_phase.phases(projectId, function (err, phases) {
        req.models.task.tasksByProject(projectId, function (err, tasks) {
            res.json({root: tree_from_list(phases, tasks)});
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

exports.addTask = function (req, res) {
    var data = JSON.parse(req.body.data)
//    data.phase_id
    req.models.task.create([
        {
            company_id: 1,
            project_phase_id: data.phase_id,
            project_id: 1,
            name: "New Task",
            notes: "New Notes",
            status: "N"
        }
    ], function (err, items) {
        res.json(items[0]);
    });
};

exports.updateTask = function (req, res) {
    var task = JSON.parse(req.body.data)
    req.models.task.get(task.id, function (err, fromdb) {
        for (i in task) {
            if (i != "id") {
                fromdb[i] = task[i]
            }
        }
        fromdb.save(function (err) {
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
//    data.task_id
//    data.from_phase
//    data.to_phse
    req.models.task.get(data.task_id, function (err, fromdb) {

//        res.json({
//            status: "error",
//            message: "Cannot delete task with time posted"
//        });
        res.json({
            satus: "success",
            message: "Task was deleted successfully",
            body: fromdb
        });
        //todo delete the task here with the check that there is no time posted on it
//        fromdb.save(function (err) {
//            res.json(fromdb);
//        })
    });
};