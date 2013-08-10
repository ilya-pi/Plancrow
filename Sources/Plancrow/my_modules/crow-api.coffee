orm = require("orm")
conf = require("./crow-conf")
data_util = require("./data_util")
_ = require("underscore")

exports.wireIn = (app) ->
    app.post "/json/assignment/sync", exports.syncAssignment
    app.get "/json/userlinks/all", exports.allUserlinks
    app.post "/json/task/posttime", exports.postTime
    app.get "/json/task/assigned", exports.assignedTasks
    app.get "/json/task/all", exports.allTasks
    app.post "/json/phase/update", exports.updatePhase
    app.post "/json/phase/move", exports.movePhase
    app.post "/json/phase/add", exports.addPhase
    app.post "/json/phase/rm", exports.rmPhase
    app.post "/json/task/add", exports.addTask
    app.post "/json/task/update", exports.updateTask
    app.post "/json/task/move", exports.moveTask
    app.post "/json/task/delete", exports.deleteTask

    app.get "/rest-crow/timeposting", exports.timePostingList
    app.post "/rest-crow/signup", exports.newSignup

## /signup/
exports.newSignup = (req, res) ->
    if not req.body?
        res.json
            status: 'error'
            message: 'no incoming data'
        return
    data = req.body
    req.models.app_visits.create [
        user_name: data.name
        email: data.email
        password: data.password
        visit_date: new Date()
    ], (err, items) ->
        if err?
            console.info err
            res.json
                status: 'error'
                message: err
        else
            res.json items[0]

## /signup/ — end


## /timeposting/

# For a given date, get the ISO week number
# *
# * Based on information at:
# *
# *    http://www.merlyn.demon.co.uk/weekcalc.htm#WNR
# *
# * Algorithm is to find nearest thursday, it's year
# * is the year of the week number. Then get weeks
# * between that date and the first day of that year.
# *
# * Note that dates in one year can be weeks of previous
# * or next year, overlap is up to 3 days.
# *
# * e.g. 2014/12/29 is Monday in week  1 of 2015
# *      2012/1/1   is Sunday in week 52 of 2011
#
getWeekNumber = (d) ->
    # Copy date so don't modify original
    d = new Date(d)
    d.setHours 0, 0, 0
    # Set to nearest Thursday: current date + 4 - current day number
    # Make Sunday's day number 7
    d.setDate d.getDate() + 4 - (d.getDay() or 7)
    # Get first day of year
    yearStart = new Date(d.getFullYear(), 0, 1)
    # Calculate full weeks to nearest Thursday
    weekNo = Math.ceil((((d - yearStart) / 86400000) + 1) / 7)
    # Return array of year and week number
    [d.getFullYear(), weekNo]


construct_up_path = (node) ->
    sqn_parts = new Array()
    fqn_parts = new Array()
    cur = if node.__parent? then node.__parent else node
    while cur.__parent?
        if cur.short_name? and cur.short_name.trim() isnt ''
            sqn_parts.unshift cur.short_name
        fqn_parts.unshift cur.name
        cur = cur.__parent
    if cur.short_name? and cur.short_name.trim() isnt ''
        sqn_parts.unshift cur.short_name
    fqn_parts.unshift cur.name
    sqn: sqn_parts
    fqn: fqn_parts

ArrNoDup = (a) ->
    temp = {}
    i = 0
    while i < a.length
        temp[a[i]] = true
        i++
    r = []
    for k of temp
        r.push k
    r

enrich_timePostingTasks = (req, timePostingTasks, cb) ->
    phases_ids = new Array()
    phases_ids.push tpt.project_id for tpt in timePostingTasks
    phases_ids = ArrNoDup(phases_ids)
    req.models.project_phase.find
        project_id: phases_ids
    , (err, all_phases) ->
        grouped_phases = _.groupBy(all_phases, 'project_id')
        grouped_tasks = _.groupBy(timePostingTasks, 'project_id')
        for project_id of grouped_tasks
            prj_tree = data_util.tree_from_list(grouped_phases[project_id], grouped_tasks[project_id])
            for task in grouped_tasks[project_id]
                task.names = construct_up_path(task)
                task.__parent = undefined
        cb(timePostingTasks)

#
# task_id:
# task_name:
#
#
#
exports.timePostingList = (req, res) ->
    data = JSON.parse(req.body.data) if req.body.data?
    current_week = getWeekNumber()
    current_year = new Date().getFullYear()

    year = if data? and data.year? then data.year else current_year
    week_number = if data? and data.week_number? then data.week_number else current_week

    customer_id = conf.currentlyAuthorized(req).customer_id

    result = new Array()

    req.models.userlink.find
        user_id: customer_id
        is_active: 'Y'
        , (err, userlinks) ->
            if err?
                res.json
                    status: 'error'
                    message: err
                return
            userlink_ids = userlinks.map((v) ->
                v.id)

            # assigned active tasks
            if week_number == current_week and year == current_year
                req.models.assignment.find
                    userlink_id: userlink_ids
                , (err, assignments) ->
                    if err?
                        res.json
                            status: 'error'
                            message: err
                    for assignment in assignments
                        if assignment.task.status == 'A'
                            result.push assignment.task
                    enrich_timePostingTasks(req, result, (enriched) -> res.json enriched)

## -end- /timeposting/


exports.postTime = (req, res) ->
    projectId = conf.currentlyAuthorized(req).project_id
    companyId = conf.currentlyAuthorized(req).company_id
    customerId = conf.currentlyAuthorized(req).customer_id
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
    projectId = conf.currentlyAuthorized(req).project_id
    companyId = conf.currentlyAuthorized(req).company_id
    customerId = conf.currentlyAuthorized(req).customer_id
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
    companyId = conf.currentlyAuthorized(req).company_id
    req.models.userlink.find
        company_id: companyId
    , (err, userlinks) ->
        res.json userlinks: userlinks


exports.assignedTasks = (req, res) ->
    customerId = conf.currentlyAuthorized(req).customer_id
    req.models.userlink.find
        user_id: customerId
    , (err, userlinks) ->
        userlinksIds = userlinks.map((v) ->
            v.id
        )
        req.models.assignment.find
            userlink_id: userlinksIds
        , (err, assignments) ->
            res.json assignments

phase_tree = (phases) ->
    buildTree = (branch, list) ->
        return null if not branch?
        tree = new Array()
        for leaf in branch
            leaf.subphases = buildTree(list[leaf.id], list)
            tree.push leaf
        tree
    grouped_phases =_.groupBy(phases, 'parent_id');
    buildTree(grouped_phases[null], grouped_phases)

tree_from_list = (phases, tasks, cb) ->
    phases_map = new Array()
    phases_map[phase.id] = phase for phase in phases
    result = phase_tree(phases)
    task_ids = new Array()
    for task in tasks
        phase = phases_map[task.project_phase_id]
        phase.tasks = new Array() if not phase.tasks?
        phase.tasks.push task
        task_ids.push task.id
    cb result, task_ids, tasks

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
    projectId = conf.currentlyAuthorized(req).project_id
    companyId = conf.currentlyAuthorized(req).company_id
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

exports.movePhase = (req, res) ->
    data = JSON.parse(req.body.data)
    project_id = conf.currentlyAuthorized(req).project_id
    to_phase = data.to_phase
    phase_id = data.phase_id
    if to_phase is phase_id
        res.json
            status: 'error'
            message: 'Cannot subphase itself'
        return
    #check for cycle dependency
    req.models.project_phase.phases project_id, (err, phases) ->
        if not err?
            phases_map = new Array()
            phases_map[phase.id] = phase for phase in phases
            cur_phase = phases_map[to_phase]
            while cur_phase.parent_id?
                if cur_phase.parent_id is phase_id
                    res.json
                        status: 'error'
                        message: 'This would create cycle dependency between phases'
                    return
                cur_phase = phases_map[cur_phase.parent_id]
            req.models.project_phase.get data.phase_id, (err, fromdb) ->
                fromdb.parent_id = to_phase
                fromdb.save (err) ->
                    res.json
                        status: (if err? then 'error' else 'success')
                        message: (if err? then err else 'OK')
        else
            res.json
                status: 'error'
                message: err

exports.updatePhase = (req, res) ->
    phase = JSON.parse(req.body.data)
    req.models.project_phase.get phase.id, (err, fromdb) ->
        for i of phase
            fromdb[i] = phase[i]  if i isnt "id" and i isnt "amnd_date"
        fromdb.amnd_date = new Date()
        fromdb.save (err) ->
            if err?
                console.info err
            res.json fromdb

exports.addPhase = (req, res) ->
    data = JSON.parse(req.body.data)
    projectId = conf.currentlyAuthorized(req).project_id
    now = new Date();
    curr_date = now.getDate();
    curr_month = now.getMonth() + 1; # months are zero based
    curr_year = now.getFullYear();
    req.models.project_phase.create [
        project_id: projectId
        parent_id: data.parent_phase_id
        amnd_date: now
        name: "New Phase"
        notes: 'Created on ' + curr_date + "-" + curr_month + "-" + curr_year
    ], (err, items) ->
        res.json items[0]

exports.rmPhase = (req, res) ->
    data = JSON.parse(req.body.data)
    projectId = conf.currentlyAuthorized(req).project_id
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
    projectId = conf.currentlyAuthorized(req).project_id
    companyId = conf.currentlyAuthorized(req).company_id
    customerId = conf.currentlyAuthorized(req).customer_id
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
    req.models.task.get data.task_id, (err, fromdb) ->
        fromdb.project_phase_id = data.to_phase
        fromdb.save (err) ->
            res.json
                status: (if err? then 'error' else 'success')
                message: (if err? then err else 'OK')

exports.deleteTask = (req, res) ->
    data = JSON.parse(req.body.data)
    projectId = conf.currentlyAuthorized(req).project_id
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

