orm = require("orm")
conf = require("./crow-conf")
exports.wireIn = (app) ->
    app.post "/json/assignment/sync", exports.syncAssignment
    app.get "/json/userlinks/all", exports.allUserlinks
    app.post "/json/task/posttime", exports.postTime
    app.get "/json/task/assigned", exports.assignedTasks
    app.get "/json/task/all", exports.allTasks
    app.post "/json/phase/update", exports.updatePhase
    app.post "/json/phase/add", exports.addPhase
    app.post "/json/phase/rm", exports.rmPhase
    app.post "/json/task/add", exports.addTask
    app.post "/json/task/update", exports.updateTask
    app.post "/json/task/move", exports.moveTask
    app.post "/json/task/delete", exports.deleteTask

exports.postTime = (req, res) ->
    projectId = conf.currentlyAuthorized().project_id
    companyId = conf.currentlyAuthorized().company_id
    customerId = conf.currentlyAuthorized().customer_id
    data = JSON.parse(req.body.data)
    task_id = data.task_id
    time_inc = data.time_inc
    timing_date = data.timing_date
    userlink_id = data.userlink_id

    #    req.db.transaction(function (err, t) {
    req.models.task.get task_id, (err, fromdb) ->

        #todo require transactions here!
        fromdb.posted = fromdb.posted + parseInt(time_inc)
        fromdb.save (err) ->
            req.models.timing.create [
                company_id: companyId
                amnd_date: new Date()
                amnd_user: customerId
                task_id: task_id
                value: parseInt(time_inc)
                timing_date: new Date(timing_date).getTime() / (24 * 60 * 60 * 1000) #todo ilya: refactor this to utils
                userlink_id: userlink_id

                #                    rate_id: 1, //todo ilya: fill in correct rate here
                project_id: projectId
                notes: ""
            ], (err) ->
                console.info err
                if err?
                    res.json
                    status: "error"
                    error: err
                else
                    res.json
                        status: "success"
                        error: err

#    });
exports.syncAssignment = (req, res) ->
    projectId = conf.currentlyAuthorized().project_id
    companyId = conf.currentlyAuthorized().company_id
    customerId = conf.currentlyAuthorized().customer_id
    data = JSON.parse(req.body.data)
    task_id = data.task_id
    userlinks = data.userlinks
    req.models.assignment.find
        task_id: task_id
    , (err, assignments) ->
        i = 0

        while i < assignments.length

            #delete those not found any longer
            found = userlinks.indexOf(assignments[i].userlink_id)
            if found is -1
                assignments[i].remove (err) ->

                    # ignore for now, todo: nice error handling in future
                    console.error err

            else
                userlinks[found] = `undefined`
            i++

        #add the new ones
        toCreate = new Array()
        k = 0

        while k < userlinks.length
            unless userlinks[k] is `undefined`
                toCreate.push
                    company_id: companyId
                    amnd_date: new Date()
                    amnd_user: customerId
                    project_id: projectId
                    userlink_id: userlinks[k]
                    task_id: task_id

            k++
        req.models.assignment.create toCreate, (err, items) ->
            result = new Array()
            result.push({userlink_id: ulink_id}) for ulink_id in userlinks
            res.json assignments: result


exports.allUserlinks = (req, res) ->
    companyId = conf.currentlyAuthorized().company_id
    req.models.userlink.find
        company_id: companyId
    , (err, userlinks) ->
        res.json userlinks: userlinks


exports.assignedTasks = (req, res) ->
    customerId = conf.currentlyAuthorized().customer_id
    req.models.userlink.find
        user_id: customerId
    , (err, userlinks) ->
        userlinksIds = userlinks.map((v) ->
            v.id
        )
        req.models.assignment.find
            userlink_id: userlinksIds
        , (err, assignments) ->
            res.json assignments: assignments


tree_from_list = (list, tasks, cb) ->
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
    taskIds = new Array()
    for i of tasks
        task = tasks[i]
        taskIds.push task.id
        task.completed = task.posted / task.estimate * 100
        task.overdue = task.completed - 100  if task.completed > 100
        unless map[task.project_phase_id] is `undefined`
            phase = map[task.project_phase_id]
            phase.tasks = new Array()  if phase.tasks is `undefined`

            #            task.assignments = new Array(); //hack
            phase.tasks.push task
    cb result, taskIds, tasks

formatFloat = (val) ->
    Math.round(val * 100) / 100

enrichTask = (task, company) ->
    if not task.assignments?
        task.assignments = new Array()
    switch company.time_unit
        when 'D', 'd'
            task.estimate_str = '' + formatFloat(task.estimate / (8 * 60 * 60 * 1000)) + 'd'
            task.posted_str = '' + formatFloat(task.posted / (8 * 60 * 60 * 1000)) + 'd'
        when 'H', 'h'
            task.estimate_str = '' + formatFloat(task.estimate / (60 * 60 * 1000)) + 'h'
            task.posted_str = '' + formatFloat(task.posted / (60 * 60 * 1000)) + 'h'
    return task

attachAss = (req, tree, tasks, ids, company, cb) ->
    req.models.assignment.find
        task_id: ids
    , (err, asses) ->
        i = 0

        while i < tasks.length
            task = enrichTask(tasks[i], company)
            task.assignments = new Array()
            l = 0

            while l < asses.length
                ass = asses[l]
                task.assignments.push ass  if ass.task_id is task.id
                l++
            i++
        cb tree


exports.allTasks = (req, res) ->
    projectId = conf.currentlyAuthorized().project_id
    companyId = conf.currentlyAuthorized().company_id
    conf.withCompany req, (company)->
        req.models.project_phase.phases projectId, (err, phases) ->
            req.models.task.tasksByProject projectId, (err, tasks) ->
                req.models.userlink.find
                    company_id: companyId
                , (err, userlinks) ->
                    tree_from_list phases, tasks, (tree, ids, task) ->
                        attachAss req, tree, tasks, ids, company, (tree) ->
                            res.json
                                root: tree
                                userlinks: userlinks

exports.updatePhase = (req, res) ->
    console.info(req.body.data)
    console.info(req.body)
    #    console.info(req)
    phase = JSON.parse(req.body.data)
    req.models.project_phase.get phase.id, (err, fromdb) ->
        for i of phase
            fromdb[i] = phase[i]  if i isnt "id" and i isnt "amnd_date"
        fromdb.save (err) ->
            console.info err
            res.json fromdb

exports.addPhase = (req, res) ->
    data = JSON.parse(req.body.data)

    #    data.parent_phase_id
    req.models.project_phase.create [
        project_id: 1 #nb!: harcoded
        parent_id: data.parent_phase_id
        name: "New Phase"
        notes: "Some Notes"
    ], (err, items) ->
        res.json items[0]


exports.rmPhase = (req, res) ->
    data = JSON.parse(req.body.data)
    projectId = conf.currentlyAuthorized().project_id
    req.models.project_phase.find(
        id: data.phase_id
        project_id: projectId
    ).remove (err) ->
        if err?
            console.info(err)
        res.json
            status: (if err? then 'error' else 'success')
            message: (if err? then err else 'OK')

exports.addTask = (req, res) ->
    projectId = conf.currentlyAuthorized().project_id
    companyId = conf.currentlyAuthorized().company_id
    customerId = conf.currentlyAuthorized().customer_id
    data = JSON.parse(req.body.data)
    dummy = {}
    dummy.isInstance = false
    req.models.task.create [
        company_id: companyId
        project_phase_id: data.phase_id
        project_id: projectId
        amnd_date: new Date()
        amnd_user: customerId
        name: "New Task"
        notes: "New Notes"
        estimate: 0
        posted: 0
        status: "N"
        completed: "N"
    ], (err, items) ->
        conf.withCompany req, (company) ->
            res.json enrichTask(items[0], company)


exports.updateTask = (req, res) ->
    task = JSON.parse(req.body.data)
    req.models.task.get task.id, (err, fromdb) ->
        for i of task
            fromdb[i] = task[i]  if i isnt "id" and i isnt "amnd_date"
        fromdb.save (err) ->
            console.info err
            res.json fromdb


exports.moveTask = (req, res) ->
    data = JSON.parse(req.body.data)

    #    data.task_id
    #    data.from_phase
    #    data.to_phse
    req.models.task.get data.task_id, (err, fromdb) ->
        fromdb.project_phase_id = data.to_phase
        fromdb.save (err) ->
            res.json fromdb


exports.deleteTask = (req, res) ->
    data = JSON.parse(req.body.data)
    projectId = conf.currentlyAuthorized().project_id
    req.models.timing.find(
        task_id: data.task_id
        project_id: projectId
    ).remove((err)->
        if not err?
            req.models.task.find(
                id: data.task_id
                project_id: projectId
            ).remove (err) ->
                res.json
                    status: (if err? then 'error' else 'success')
                    message: (if err? then err else 'OK')
        else
            res.json
                status: 'error'
                message: err
    )

