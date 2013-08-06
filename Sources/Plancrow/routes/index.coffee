
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
    res.render "landing",
        title: "Plancrow"
        screen_name: ""
