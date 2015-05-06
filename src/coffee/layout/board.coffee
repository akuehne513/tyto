Tyto.module 'Layout', (Layout, App, Backbone) ->
  Layout.Board = Backbone.Marionette.CompositeView.extend
    tagName: 'div'
    className: 'board'
    template: tytoTmpl.board
    childView: Layout.Column
    childViewContainer: '.columns'
    childViewOptions: ->
      board: this.model
      siblings: this.collection
    ui:
      addColumn: '#add-column'
      saveBoard: '#save-board'
      deleteBoard: '#delete-board'
      wipeBoard: '#wipe-board'
      boardName: '#board-name'
    events:
      'click @ui.addColumn': 'addColumn'
      'click @ui.saveBoard': 'saveBoard'
      'click @ui.deleteBoard': 'deleteBoard'
      'click @ui.wipeBoard': 'wipeBoard'
      'blur @ui.boardName': 'updateName'

    initialize: ->
      yap 'running this again???'
      board = this
      cols = _.sortBy board.model.get('columns'), 'ordinal'
      board.collection = new Tyto.Columns.ColumnList cols

      this.listenTo Tyto.vent, 'setup:localStorage', ->
        this.ui.saveBoard.removeAttr 'disabled'

      board.on 'childview:destroy:column', (id, y) ->
        board.collection.remove y
        newWidth = (100 / board.collection.length) + '%'
        $('.column').css
          width: newWidth
        yap board.collection
        return

    onRender: ->
      yap 'rendering board'
      if window.localStorage and !window.localStorage.tyto
        this.ui.saveBoard.attr 'disabled', true
      this.bindColumns()
    bindColumns: ->
      self = this
      this.$el.find('.columns').sortable
        connectWith: '.column',
        handle: '.column--mover'
        placeholder: 'column-placeholder'
        axis: "x"
        containment: this.$el.find('.columns')
        opacity: 0.8
        stop: (event, ui) ->
          mover = ui.item[0]
          columnModel = self.collection.get ui.item.attr('data-col-id')
          columnList = Array.prototype.slice.call self.$el.find '.column'
          Tyto.reorder self, mover, columnModel, columnList

    addColumn: ->
      newCol = new Tyto.Columns.Column
        id: _.uniqueId()
        ordinal: this.collection.length + 1
      this.collection.add newCol
      newWidth = (100 / this.collection.length) + '%'
      yap newWidth
      $('.column').css
        width: newWidth

    saveBoard: ->
      this.model.set 'columns', this.collection
      this.model.save()

    updateName: ->
      this.model.set 'title', @ui.boardName.text().trim()

    deleteBoard: ->
      this.model.destroy()
      this.destroy()
      Tyto.navigate '/',
        trigger: true

    wipeBoard: ->
      this.collection.reset()
      return
