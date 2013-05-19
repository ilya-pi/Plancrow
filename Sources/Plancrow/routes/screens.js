/*
 * GET screen 09 projets list.
 */

exports.screen09_project_list = function (req, res) {
    req.models.project.find({ }, function (err, projects) {
        if (projects == undefined) {
            projects = new Array()
        }
        res.render('screens/09_project_list', { title: 'Plancrow', screen_name: '09 Project List', projects: projects});
    });
};

var tree_from_list = function(list) {
    var map = new Array()
    var result = new Array()
    for (i in list){
        list[i].children = undefined
    }
    for (i in list){
        var node = list[i]
        if (node.parent_id == null){
            result.push(node);
            map[node.id] = node;
        }else {
            if (map[node.parent_id].children == undefined){
                map[node.parent_id].children = new Array()
            }
            map[node.parent_id].children.push(node)
        }
    }
    return result;
}

exports.screen12_project_details = function (req, res) {
    req.models.project.get(1, function (err, project) {
        req.models.project_phase.phases(project.id, function (err, phases) {
            res.render('screens/12_project_details', { title: 'Plancrow', screen_name: '12 Project Details', project: project, phases: tree_from_list(phases)});
        });
    });
};