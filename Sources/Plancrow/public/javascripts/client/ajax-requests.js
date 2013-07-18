/* AjaxRequest
 *
 * One place to isolate all async calls
 *
 * @author Ilya Pimenov
 */
var AjaxRequests = {

    syncAssignment: function (params, callback) {
        console.info(params);
        $.ajax({type: 'POST', url: '/json/assignment/sync', data: {data: JSON.stringify(params)}, success: function (data) {
            callback(data);
        }, dataType: "json"});
    },

    postTime: function (params, callback) {
        $.ajax({type: 'POST', url: '/json/task/posttime', data: {data: JSON.stringify(params)}, success: function (data) {
            callback(data);
        }, dataType: "json"});
    },

    assignedTasks: function (params, callback) {
        $.ajax({type: 'GET', url: '/json/task/assigned', data: {data: JSON.stringify(params)}, success: function (data) {
            callback(data);
        }, dataType: "json"});
    },

    allTasks: function (params, callback) {
        $.ajax({type: 'GET', url: '/json/task/all', data: {data: JSON.stringify(params)}, success: function (data) {
            callback(data);
        }, dataType: "json"});
    },

    rmPhase: function (params, callback) {
        $.ajax({type: 'POST', url: '/json/phase/rm', data: {data: JSON.stringify(params)}, success: function (data) {
            callback(data);
        }, dataType: "json"});
    },

    addPhase: function (params, callback) {
        $.ajax({type: 'POST', url: '/json/phase/add', data: {data: JSON.stringify(params)}, success: function (data) {
            callback(data);
        }, dataType: "json"});
    },

    addTask: function (params, callback) {
        $.ajax({type: 'POST', url: '/json/task/add', data: {data: JSON.stringify(params)}, success: function (data) {
            callback(data);
        }, dataType: "json"});
    },

    updateTask: function (params, callback) {
        $.ajax({type: 'POST', url: '/json/task/update', data: {data: JSON.stringify(params)}, success: function (data) {
            callback(data);
        }, dataType: "json"});
    },

    moveTask: function (params, callback) {
        $.ajax({type: 'POST', url: '/json/task/move', data: {data: JSON.stringify(params)}, success: function (data) {
            callback(data);
        }, dataType: "json"});
    },

    deleteTask: function (params, callback) {
        $.ajax({type: 'POST', url: '/json/task/delete', data: {data: JSON.stringify(params)}, success: function (data) {
            callback(data);
        }, dataType: "json"});
    }

}