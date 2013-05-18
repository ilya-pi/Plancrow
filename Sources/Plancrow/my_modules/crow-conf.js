
/**
 * Prepare and return correct environment specific (either local of appfog) connection string for the database
 *
 * @returns {string}
 */
exports.mysqlConnectionString = function(){
    var result = 'mysql://sa:assa@localhost/Plancrow?';
    if (process.env.VCAP_SERVICES !== undefined){
        var env = JSON.parse(process.env.VCAP_SERVICES);
        var cre = env['mysql-5.1'][0]['credentials'];
        result = 'mysql://' + cre.username + ':' + cre.password + '@' + cre.hostname + '/' + cre.name + '?';
    }
    return result;
}
