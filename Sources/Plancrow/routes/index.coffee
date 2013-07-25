
#
# * GET home page.
# 
exports.index = (req, res) ->
    res.render "index",
        title: "Plancrow"
        screen_name: ""
