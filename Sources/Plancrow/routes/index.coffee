conf = require("../my_modules/crow-conf")

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
    console.info(req.headers["accept-language"])
    console.info(req.locale)
    local_currency = conf.currency(req.locale)
    res.render "landing",
        title: "Plancrow"
        screen_name: ""
        currency: local_currency
        price: conf.price(local_currency)
