_ = require("underscore")

exports.phase_tree = (phases) ->
    buildTree = (branch, list, __parent) ->
        return null if not branch?
        tree = new Array()
        for leaf in branch
            if __parent?
                leaf.__parent = __parent
            leaf.subphases = buildTree(list[leaf.id], list, leaf)
            tree.push leaf
        tree
    grouped_phases =_.groupBy(phases, 'parent_id');
    buildTree(grouped_phases[null], grouped_phases)

exports.tree_from_list = (phases, tasks, cb) ->
    phases_map = new Array()
    phases_map[phase.id] = phase for phase in phases
    result = exports.phase_tree(phases)
    task_ids = new Array()
    for task in tasks
        phase = phases_map[task.project_phase_id]
        task.__parent = phase
        phase.tasks = new Array() if not phase.tasks?
        phase.tasks.push task
        task_ids.push task.id
    if cb?
        cb result, task_ids, tasks
    else
        result
