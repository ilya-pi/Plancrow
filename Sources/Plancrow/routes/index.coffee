conf = require("../my_modules/crow-conf")
orm = require("orm")

#
# * GET home page.
# 
exports.index = (req, res) ->
    res.render "index",
        title: "Plancrow"
        screen_name: ""

#
# * GET landing page.
#
exports.landing = (req, res) ->
    local_currency = conf.currency(req.locale)
    res.render "landing",
        title: "Plancrow"
        screen_name: ""
        currency: local_currency
        price: conf.price(local_currency)

exports.terms = (req, res) ->
    local_currency = conf.currency(req.locale)
    res.render "terms",
        title: "Plancrow"
        screen_name: ""
        currency: local_currency

exports.stat = (req, res) ->
  req.models.app_visits.count {}, (err, count) ->
      res.render "stat",
        title: "Stats"
        total: count

