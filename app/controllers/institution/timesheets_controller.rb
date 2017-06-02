class Institution::TimesheetsController < Institution::BaseController
  helper_method :group_timesheet

  def index
  end

  def ajax_filter_timesheets # Фильтрация документов
    @timesheets = Timesheet
      .where( institution: current_institution, date: params[ :date_start ]..params[ :date_end ] )
      .order( "#{ params[ :sort_field ] } #{ params[ :sort_order ] }" )
  end

  def delete # Удаление документа
    Timesheet.find( params[ :id ] ).destroy
    render json: { status: true }
  end

  def new
  end

  def create
    date_start = params[ :date_start ].to_date
    date_end = params[ :date_end ].to_date

    timesheet_exists = current_institution.timesheets.select( :id, :number, :date, :date_eb, :date_ee )
                           .where( date_eb: date_start..date_end )
      .or( current_institution.timesheets.select( :id, :number, :date, :date_eb, :date_ee ).where( date_ee: date_start..date_end ) )
      .order( :number )
    if timesheet_exists.present?
      result = { status: false, caption: 'За выбраний період уже створений табель',
                 message: timesheet_exists.map{ |v| {
                     id: v[:id], 'Номер': v[ :number ], 'Дата:': date_str( v[ :date ]),
                     'З': date_str( v[ :date_eb ] ), 'ПО': date_str( v[ :date_ee ] ) } }  }
    else
      message = { 'CreateRequest' => { 'StartDate' => date_start,
                                       'EndDate' => date_end,
                                       'Institutions_id' => current_institution.code } }
      method_name = :get_data_time_sheet
      response = Savon.client( SAVON )
                   .call( method_name, message: message )
                   .body[ "#{ method_name }_response".to_sym ][ :return ]

      web_service = { call: { savon: SAVON, method: method_name.to_s.camelize, message: message } }

      result = { }
      ts_data = response[ :ts ]

      if response[ :interface_state ] == 'OK' && ts_data
        ActiveRecord::Base.transaction do
          timesheet = Timesheet.create( institution: current_institution, branch: current_branch,
            date_vb: response[ :date_vb ], date_ve: response[ :date_ve ],
            date_eb: response[ :date_eb ], date_ee: response[ :date_ee ], date: Date.today )

          ts_data.each do | ts |
            error = {}
            child = child_code( ts[ :child_code ] )
            error.merge!( child[ :error ] ) if child[ :error ]

            children_group = children_group_code( ts[ :children_group_code ] )
            error.merge!( children_group[ :error ] ) if children_group[ :error ]

            reasons_absence = reasons_absence_code( ( ts[ :reasons_absence_code ] || '' ) )
            error.merge!( reasons_absence[ :error ] ) if reasons_absence[ :error ]

            if error.empty?
              TimesheetDate.new do | o |
                o.date = ts[ :date ]
                o.timesheet_id = timesheet.id
                o.child_id = child.id
                o.children_group_id = children_group.id
                o.reasons_absence_id = reasons_absence.id
                o.save( validate: false )
              end
            else
              result = { status: false, caption: 'Неможливо створити документ',
                         message: { error: error }.merge!( web_service ) }
              raise ActiveRecord::Rollback
            end
          end

          result = { status: true, urlParams: { id: timesheet.id } }
        end
      else
        result = { status: false, caption: 'За вибраний період даних немає в 1С',
                   message: web_service.merge!( response: response ) }
      end
    end

    render json: result
  end


  #############################
  #############################
  #############################

  def send_sa
    timesheet = Timesheet.find_by( id: params[ :id ] )
    timesheet_dates = timesheet.timesheet_dates_join

    if timesheet_dates
      message = { 'CreateRequest' => { 'Institutions_id' => timesheet.institution.code,
                                       'NumberFromWebPortal' => timesheet.number,
                                       'StartDate' => timesheet.date_vb,
                                       'EndDate' => timesheet.date_ve,
                                       'StartDateOfTheFill' => timesheet.date_eb,
                                       'EndDateOfTheFill' => timesheet.date_ee,
                                       'TS' => timesheet_dates.map{ | o | {
                                         'Child_code' => o.child_code,
                                         'Children_group_code' => o.group_code,
                                         'Reasons_absence_code' => o.reason_code,
                                         'Date' => o.date  } },
                                       'User' => current_user.username } }

      response = Savon.client( SAVON )
        .call( :creation_time_sheet, message: message )
      interface_state = response.body[ :creation_time_sheet_response ][ :return ][ :interface_state ]
      number = response.body[ :creation_time_sheet_response ][ :return ][ :respond ]

      if interface_state == 'OK'
        timesheet.update( date_sa: Date.today, number_sa: number )
        redirect_to institution_timesheets_index_path
      else
        render json: { interface_state: interface_state, message: message }
      end
    else
      render text: 'Пустая таблица не проставлено'
    end
  end

  def group_timesheet
    group_timesheet = []
    children_category_id = 0

    @timesheet.timesheet_dates
      .select( 'DISTINCT ON ( children_groups.children_category_id, timesheet_dates.children_group_id )
        children_groups.children_category_id', :children_group_id,
               'children_categories.name AS category_name', 'children_groups.name AS group_name' )
      .joins( :children_category, :children_group )
      .each do | o |
        if children_category_id != o.children_category_id
          children_category_id = o.children_category_id
          group_timesheet << [ o.category_name, o.children_category_id,
                               { class: :row_group, data: { field: :children_category_id } } ]
        end

        group_timesheet << [ o.group_name, o.children_group_id, { data: { field: :children_group_id } } ]
      end

    return group_timesheet
  end

  def dates # Отображение дней табеля
    @timesheet = Timesheet.find_by( id: params[ :id ] )

    @reasons_absences = ReasonsAbsence.select( :id, :code, :mark ).where( code: '' )
      .or(ReasonsAbsence.select( :id, :code, :mark ).where.not( mark: '' ) )
      .order( :priority ).pluck( :id, :code, :mark )
  end

  def update # Обновление реквизитов документа
    update = params.permit( :id, :date ).to_h
    Timesheet.where( id: params[ :id ] ).update_all( update ) if params[ :id ] && update.any?
    render body: nil
  end

  def dates_update # Обновление маркера
    update = params.permit( :id, :reasons_absence_id ).to_h
    TimesheetDate.where( id: params[ :id ] ).update_all( update ) if params[ :id ] && update.any?
    render body: nil
  end

  def ajax_filter_timesheet_dates # Фильтрация таблицы
    if params[ :id ]
      @timesheet = Timesheet.find_by( id: params[ :id ] )

      if params[ :field ] == 'children_group_id'
        where = { children_group_id: params[ :field_id ] }
      elsif params[ :field ] == 'children_category_id'
        where = "children_groups.children_category_id = #{ params[ :field_id ] }"
      else
        where = ''
      end

      @timesheet_dates = @timesheet.timesheet_dates_join.where( where )
    end
  end
end
