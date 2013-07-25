###
Prepare and return correct environment specific (either local of appfog) connection string for the database

@returns {string}
###
exports.mysqlConnectionString = ->
    result = "mysql://root:@localhost/Plancrow"
    if process.env.VCAP_SERVICES isnt `undefined`
        env = JSON.parse(process.env.VCAP_SERVICES)
        cre = env["mysql-5.1"][0]["credentials"]
        result = "mysql://" + cre.username + ":" + cre.password + "@" + cre.hostname + "/" + cre.name + ""
    console.error result
    result

exports.currentlyAuthorized = ->
    customer_id: 1
    company_id: 1
    project_id: 1