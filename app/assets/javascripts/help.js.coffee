$ ->
  self.notification = ->
    $.ajax(
      type:'GET'
      url: '/help/notification/check'
      data: {}
      complete: (data) =>
        response = JSON.parse(data.responseText)
        if response['result'] != 'error'
          $.sticky("#{response['result']}<br/><a id='link' href='#help'>Просмотреть</a>")
          $('.sticky-close').click( =>
            $.ajax(
              type:'POST'
              url: '/help/notification/hide'
              complete: =>
                true
            )
          )
          $('a#link').click( =>
            $('.sticky-close').click()
          )
    )
  notification()

  self.scrolling = ->
    $(document).ready(=>
      $("a.ancLinks").click(->
        elementClick = $(this).attr("href")
        destination = $(elementClick).offset().top
        $('body').animate( { scrollTop: destination }, 1100 )
        false
      )
    )





