/* AjaxRequest
 *
 * One place to isolate all async calls
 *
 * @author Ilya Pimenov
 */
var AjaxRequests = {

    //facebook requests

    fb_events:function (params, callback) {
        $.ajax({type:'GET', url:'json/events/'+params, success:function (data) {
            console.log(data);
            callback(data);
        }, dataType:"json"});
    }
}