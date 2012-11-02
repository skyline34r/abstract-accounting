$ ->
  class self.DocumentsViewModel extends FolderViewModel
    constructor: (data, page) ->
      @url = "/#{page}.json"

      @filter =
        waybill:
          created: ko.observable('')
          document_id: ko.observable('')
          distributor:
            legal_entity:
              name: ko.observable('')
              identifier_name: ko.observable('')
              identifier_value: ko.observable('')
          distributor_place:
            place:
              tag: ko.observable('')
          storekeeper:
            entity:
              tag: ko.observable('')
          storekeeper_place:
            place:
              tag: ko.observable('')
        allocation:
          created: ko.observable('')
          state: ko.observable('')
          storekeeper:
            entity:
              tag: ko.observable('')
          storekeeper_place:
            place:
              tag: ko.observable('')
          foreman:
            entity:
              tag: ko.observable('')
          foreman_place:
            place:
              tag: ko.observable('')

      super(data)

    showDocument: (object) ->
      location.hash = "documents/#{object.type}/#{object.id}"
      $.ajax(
        type: 'get'
        url: '/viewed/view'
        data: {user_id: object.user_id, item_id: object.id, item_type: object.name }
        complete: ->
          true
      )
      ko.contextFor($('#body').get(0)).$root.inbox()
