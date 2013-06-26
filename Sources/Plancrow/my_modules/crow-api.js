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