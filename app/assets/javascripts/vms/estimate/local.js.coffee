$ ->
  class self.EstimateLocalViewModel extends CommentableViewModel
    @include TableCommenstHelper

    constructor: (object, readonly = false) ->
      super(object, 'estimate/locals', readonly)
      @object.items = ko.observable(new EstimateLocalElementsViewModel({objects: []},
        {
          id: @object.id?()
          boms_catalog_id: @object.boms_catalog.id()
          prices_catalog_id: @object.prices_catalog.id()
        })
      )
      @object.items().getPaginateData()

    resources: =>
      location.hash = "#estimate/locals/#{@object.id()}/resources"

    namespace: =>
      ""
    save: =>
      #@object.items = @object.items().documents()
      super

    edit: =>
      @object.items().readonly(false)
      super

    visibleButtons: =>
      @readonly() && !@object.local.approved()? && !@object.local.canceled()?

    disableEdit: =>
      @disable() || !@readonly() || @object.local.approved()? || @object.local.canceled()?

    disableButton: =>
      @disable()

    apply: =>
      @disable(true)
      @ajaxRequest('GET', "/#{@route}/#{@object.id()}/apply", {}, true)

    cancel: =>
      @disable(true)
      @ajaxRequest('GET', "/#{@route}/#{@object.id()}/cancel", {}, true)

    select: (object) =>
      if typeof @object.items == 'object'
        @object.items = ko.observable(new EstimateLocalElementsViewModel(
          {objects: []},
          {
            id: @object.id?()
            boms_catalog_id: @object.boms_catalog.id()
            prices_catalog_id: @object.prices_catalog.id()
          }
        ))
        @object.items().dialog_id = 'boms_selector'
      @object.items().select(object)

  class self.EstimateLocalResourcesViewModel extends ObjectViewModel
    constructor: (object) ->
      super(object)
      @params =
        page: @page
        per_page: @per_page
