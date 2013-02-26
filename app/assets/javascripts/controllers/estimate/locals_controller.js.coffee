$ ->
  class self.LocalsController extends self.ApplicationController
    new: =>
      @render 'estimate/locals/preview'
      $.getJSON("estimate/locals/new.json", normalizeHash(this.params.toHash()), (object) ->
        self.application.object(new EstimateLocalViewModel(object))
      )

    show: =>
      @render 'estimate/locals/preview'
      $.getJSON("estimate/locals/#{this.params.id}.json", {}, (object) ->
        self.application.object(new EstimateLocalViewModel(object, true))
      )

    resources: =>
      id = this.params.id
      @render "estimate/locals/#{id}/resources"
      $.getJSON("estimate/locals/#{id}/resources.json", {}, (object) ->
        self.application.object(new EstimateLocalResourcesViewModel(object))
      )
