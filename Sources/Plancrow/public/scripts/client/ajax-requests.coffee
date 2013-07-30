# AjaxRequest
# *
# * One place to isolate all async calls
# *
# * @author Ilya Pimenov
# 
AjaxRequests =
    syncAssignment: (params, callback) ->
        $.ajax
            type: "POST"
            url: "/json/assignment/sync"
            data:
                data: JSON.stringify(params)
            success: (data) ->
                callback data
            dataType: "json"


    postTime: (params, callback) ->
        $.ajax
            type: "POST"
            url: "/json/task/posttime"
            data:
                data: JSON.stringify(params)
            success: (data) ->
                callback data
            dataType: "json"


    assignedTasks: (params, callback) ->
        $.ajax
            type: "GET"
            url: "/json/task/assigned"
            data:
                data: JSON.stringify(params)

            success: (data) ->
                callback data

            dataType: "json"


    allTasks: (params, callback) ->
        $.ajax
            type: "GET"
            url: "/json/task/all"
            data:
                data: JSON.stringify(params)

            success: (data) ->
                callback data

            dataType: "json"

    movePhase: (params, callback) ->
        $.ajax
            type: "POST"
            url: "/json/phase/move"
            data:
                data: JSON.stringify(params)
            success: (data) ->
                callback data
            dataType: "json"

    rmPhase: (params, callback) ->
        $.ajax
            type: "POST"
            url: "/json/phase/rm"
            data:
                data: JSON.stringify(params)

            success: (data) ->
                callback data

            dataType: "json"

    updatePhase: (params, callback) ->
        $.ajax
            type: "POST"
            url: "/json/phase/update"
            data:
                data: JSON.stringify(params)

            success: (data) ->
                callback data

            dataType: "json"

#    updatePhase: (params, callback) ->
#        $.ajax
#            type: "POST"
#            url: "/json/phase/updatePhase"
#            data:
#                data: JSON.stringify(params)
#            success: (data) ->
#                callback data
#            dataType: "json"

    addPhase: (params, callback) ->
        $.ajax
            type: "POST"
            url: "/json/phase/add"
            data:
                data: JSON.stringify(params)

            success: (data) ->
                callback data

            dataType: "json"


    addTask: (params, callback) ->
        $.ajax
            type: "POST"
            url: "/json/task/add"
            data:
                data: JSON.stringify(params)

            success: (data) ->
                callback data

            dataType: "json"


    updateTask: (params, callback) ->
        $.ajax
            type: "POST"
            url: "/json/task/update"
            data:
                data: JSON.stringify(params)

            success: (data) ->
                callback data

            dataType: "json"


    moveTask: (params, callback) ->
        $.ajax
            type: "POST"
            url: "/json/task/move"
            data:
                data: JSON.stringify(params)

            success: (data) ->
                callback data

            dataType: "json"


    deleteTask: (params, callback) ->
        $.ajax
            type: "POST"
            url: "/json/task/delete"
            data:
                data: JSON.stringify(params)

            success: (data) ->
                callback data

            dataType: "json"
