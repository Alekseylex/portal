$( document ).on 'turbolinks:load', ->
  # Если объект существует
  $institutionOrders = $( '#institution_orders' )
  if $institutionOrders.length

    $parentElem = $institutionOrders

    $sessionKey = $parentElem.attr 'id'
    $dateStartSession = window.getSession( $sessionKey )?.date_start
    $dateEndSession = window.getSession( $sessionKey )?.date_end

    $( "#main_menu li[data-page=#{ $sessionKey }]" ).addClass( 'active' ).siblings(  ).removeClass 'active'

    getTable = ->
      $sessionObj = window.getSession( $sessionKey )
      $clmn = $( '#col_io' )
      $clmnObj = $sessionObj[ $clmn.attr 'id' ]
      window.ajax(
        'Фільтрація заявки'
        $clmn.data 'path-filter'
        'post'
          date_start: $sessionObj.date_start
          date_end: $sessionObj.date_end
          sort_field: $clmnObj?.sort_field
          sort_order: $clmnObj?.sort_order
        'script' ) if $sessionObj?.date_start

    getTableCorrection = ->
      $sessionObj = window.getSession( $sessionKey )
      $clmn = $( '#col_ioc' )
      $clmnObj = $sessionObj[ $clmn.attr 'id' ]

      $clmnIoObj = $sessionObj[ 'col_io' ]
      $institutionOrderId = $clmnIoObj?.row_id

      if $institutionOrderId
        window.ajax(
          'Фільтрація коригування заявки'
          $clmn.data 'path-filter'
          'post'
            institution_order_id: $institutionOrderId
            sort_field: $clmnObj?.sort_field
            sort_order: $clmnObj?.sort_order
          'script' )
      else
        $clmn
          .find( '.parent_table' ).empty( )
          .end( )
          .find( 'h1' ).text( $clmn.data 'captions' )
          .end( )
          .find( '.btn_create' ).prop 'disabled', true

    filterTable = -> # Фильтрация таблицы документов
      setClearTableSession $sessionKey, 'col_io'
      getTable( )
      filterTableCorrection( )

    filterTableCorrection = -> # Фильтрация таблицы документов
      setClearTableSession $sessionKey, 'col_ioc'
      getTableCorrection( )

    getTable( ) # Запрос таблицы документов
    getTableCorrection( )

    ########
    $( '#col_io' )
      .find( '.btn_create' )
        .click -> # Нажатие на кнопочку создать
          window.createDoc(
            $( @ )
            date_start: $( '#date_start' ).val( ), date_end: $( '#date_end' ).val( ) )
      .end( )
      .find( '#date_start' ) # Начальная дата фильтрации
        .val $dateStartSession
        .data 'old-value', $dateStartSession
        .attr readonly: true, placeholder: 'Дата...'
        .datepicker( onSelect: -> window.selectDateStart $( @ ), '#date_end', filterTable )
      .end( )
      .find( '#date_end' ) # Конечная дата фильтрации
        .val $dateEndSession
        .data 'old-value', $dateEndSession
        .attr readonly: true, placeholder: 'Дата...'
        .datepicker( onSelect: -> window.selectDateEnd $( @ ), '#date_start', filterTable )
      .end( )
      .on 'click', 'td, th[data-sort]', ->
        $this = $( @ )
        if $this.is 'th'
          window.tableHeaderClick $( @ ), filterTable # Нажатие для сортировки
        else
          $button = $this.children 'button'
          $tr = $this.closest 'tr'

          window.rowSelect( $tr, filterTableCorrection ) unless $tr.hasClass 'selected'

          window.tableButtonClick(
            $button
            ( ) ->
              $( '#col_io .btn_create' ).prop 'disabled', if $( '#col_io table' ).length then true else false
              filterTableCorrection( )
          ) if $button.length
    ########
    $( '#col_ioc' )
      .find( '.btn_create' )
        .click -> # Нажатие на кнопочку создать
          $this = $( @ )
          window.createDoc(
            $this
            institution_order_id: $this.closest( '.clmn' ).data 'institution_order_id' )
      .end( )
      .on 'click', 'td, th[data-sort]', ->
        $this = $( @ )
        if $this.is 'th'
          window.tableHeaderClick $( @ ), filterTableCorrection # Нажатие для сортировки
        else
          $button = $this.children 'button'
          $tr = $this.closest 'tr'

          window.rowSelect $tr unless $tr.hasClass 'selected'

          window.tableButtonClick(
            $button,
            ( ) -> $( '#col_ioc .btn_create' ).prop 'disabled', false
          ) if $button.length