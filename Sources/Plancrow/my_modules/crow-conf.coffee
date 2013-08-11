fx = require("money")

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

exports.currentlyAuthorized = (req) ->
    console.info(req.user)
    customer_id: 1
    company_id: 1
    project_id: 1

#todo ilya: NB cache company data!!!
exports.withCompany = (req, cb)->
    req.models.company.get exports.currentlyAuthorized(req).company_id, (err, fromdb) ->
        cb(fromdb)

exports.currency = (loc) ->
  switch loc
    when "en", "en_US", "fr_CA"
      return "USD"
    when "nl", "fr", "de", "it", "nb", "nn", "sv"
      return "EUR"
    when "en_GB"
      return "GBP"
  return "n/a"

exports.price = (curr) ->
  # nb: todo ilya: use money.js project to acquire proper prices in future
  #fx.convert(20.00, {from: "EUR", to: local_currency})
  switch curr
    when "USD" then return "25"
    when "EUR" then return "20"
    when "GBP" then return "15"
  return "n/a"
