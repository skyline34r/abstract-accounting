$ ->
  self.notification = ->
    $.ajax(
      type:'GET'
      url: '/help/notification'
      data: {}
      complete: (data) =>
        console.log(JSON.parse(data.responseText))
        response = JSON.parse(data.responseText)
        if response['result'] != 'error'
          $.sticky("#{response['result']}<br/><a id='link' href='#help'>Просмотреть</a>")
          $('a#link').click( =>
            $('.sticky-close').click()
            $.ajax(
              type:'POST'
              url: '/help/dont_show_me_help'
              complete: =>
                true
              )
          )
    )
  notification()



