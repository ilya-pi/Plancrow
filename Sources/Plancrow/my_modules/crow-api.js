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