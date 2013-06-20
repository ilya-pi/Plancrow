/* AjaxRequest
 *
 * One place to isolate all async calls
 *
 * @author Ilya Pimenov
 */
var AjaxRequests = {

    updateTask:function (params, callback) {
        $.ajax({type:'POST', url:'/json/task/update', data: {data: JSON.stringify(params)}, success:function (data) {
            callback(data);
        }, dataType:"json"});
    }
}