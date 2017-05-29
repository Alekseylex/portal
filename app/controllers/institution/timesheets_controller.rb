class Institution::TimesheetsController < Institution::BaseController
  helper_method :group_timesheet

  def index
  end

  def new
    @timesheet = Timesheet.new( date: Date.today, date_eb: Date.today.beginning_of_month, date_ee: Date.today.end_of_month )
  end

  # Веб-сервис загрузки графика
  def create
    date_ee = params[ :date_ee ].to_date
    date_eb = params[ :date_eb ].to_date

    message = { 'CreateRequest' => { 'StartDate' => date_eb,
                                     'EndDate' => date_ee,
                                     'Institutions_id' => current_institution.code } }
    response = Savon.client( SAVON )
                 .call( :get_data_time_sheet, message: message )

    interface_state = response.body[ :get_data_time_sheet_response ][ :return ][ :interface_state ]
    return_value = response.body[ :get_data_time_sheet_response ][ :return ]

    if interface_state == 'OK'
      Timesheet.transaction do
        @timesheet = Timesheet.create( institution: current_institution, branch: current_branch,
          date_vb: return_value[ :date_vb ], date_ve: return_value[ :date_ve ],
          date_eb: return_value[ :date_eb ], date_ee: return_value[ :date_ee ], date: params[ :date ].to_date )

        return_value[ :ts ].each do | ts |
          child = child_code( ts[ :child_code ].strip )
          children_group = children_group_code( ts[ :children_group_code ].strip )
          reasons_absence = reasons_absence_code( ( ts[ :reasons_absence_code ] || '' ).strip )

          unless child[ :error ] || children_group[ :error ] || reasons_absence[ :error ]
            TimesheetDate.new( date: ts[ :date ] ) do | o |
              o.timesheet_id = @timesheet.id
              o.child_id = child.id
              o.children_group_id = children_group.id
              o.reasons_absence_id = reasons_absence.id
              o.save( validate: false )
            end
          end
        end

        redirect_to institution_timesheets_dates_path( id: @timesheet.id )
      end
    end
  end

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

  def ajax_filter_timesheets # Фильтрация документов
    @timesheets = Timesheet
                    .where( institution: current_institution, date: params[ :date_start ]..params[ :date_end ] )
                    .order( "#{ params[ :sort_field ] } #{ params[ :sort_order ] }" )
  end

  def delete # Удаление документа
    Timesheet.find_by( id: params[ :id ] ).destroy if params[ :id ]
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
