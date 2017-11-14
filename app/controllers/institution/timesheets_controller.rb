class Institution::TimesheetsController < Institution::BaseController

  def index ; end
  def new ; end

  def ajax_filter_timesheets # Фильтрация документов
    @timesheets = Timesheet
      .where( institution_id: current_user[ :userable_id ],
              date: params[ :date_start ]..params[ :date_end ] )
      .order( "#{ params[ :sort_field ] } #{ params[ :sort_order ] }" )
  end

  def delete # Удаление документа
    Timesheet.find( params[ :id ] ).destroy
    render json: { status: true }

  end

  def create
    date_start = params[ :date_start ].to_date
    date_end = params[ :date_end ].to_date

    timesheet_exists = JSON.parse( Timesheet
      .select( :id, :number, :date, :date_eb, :date_ee )
      .where( institution_id: current_user[ :userable_id ],
              date_eb: date_start..date_end,
              is_del_1c: false )
      .or( Timesheet
        .select( :id, :number, :date, :date_eb, :date_ee )
        .where( institution_id: current_user[ :userable_id ],
                date_ee: date_start..date_end,
                is_del_1c: false ) )
      .order( :number )
      .to_json, symbolize_names: true )

    if timesheet_exists.present?
      result = { status: false, caption: 'За вибраний період уже створений табель',
                 message: timesheet_exists.map{ | v | {
                     id: v[ :id ],
                     'Номер': v[ :number ],
                     'Дата:': date_str( v[ :date ].to_date ),
                     'З': date_str( v[ :date_eb ].to_date ),
                     'ПО': date_str( v[ :date_ee ].to_date ) } } }
    else
      message = { 'CreateRequest' => { 'StartDate' => date_start,
                                        'EndDate' => date_end,
                                        'Institutions_id' => current_institution[ :code ] } }

      savon_return = get_savon( :get_data_time_sheet, message )
      response = savon_return[ :response ]
      web_service = savon_return[ :web_service ]

      result = { }
      ts_data = response[ :ts ]

      ts_data.map { | o | }

      if response[ :interface_state ] == 'OK' && ts_data && ts_data.present?
        error = { }

        children_codes = ts_data.group_by { | o | o[ :child_code ] }.map { | k, v | k }
        children = exists_codes( :children, children_codes )
        error.merge!( children[ :error ] ) unless children[ :status ]

        children_groups_codes = ts_data.group_by { | o | o[ :children_group_code ] }.map { | k, v | k }
        children_groups = exists_codes( :children_groups, children_groups_codes )
        error.merge!( children_groups[ :error ] ) unless children_groups[ :status ]

        reasons_absences_code = ts_data.group_by { | o | o[ :reasons_absence_code ] }.map { | k, v | k }
        reasons_absences = exists_codes( :reasons_absences, reasons_absences_code )
        error.merge!( reasons_absences[ :error ] ) unless reasons_absences[ :status ]

        # values = ts_data.map.with_index { | o, row |
        #   "( #{ id + 1 }, #{ o.values_at( :child_code, :children_group_code, :reasons_absence_code, :date )
        #           if i==0 || i==1 then "::VARCHAR(9)" elsif i==2 then "::VARCHAR(2)" elsif i==3 then "::DATE" else "" end
        #             : "" }"  }
        #   .join( ',' ) } )" }.join( ',' )

        # sql_create_table = <<-SQL.squish
        #     ROLLBACK;
        #     BEGIN;

        #     CREATE TEMP TABLE timesheets_get (
        #         id,
        #         child_code,
        #         children_group_code,
        #         reasons_absence_code,
        #         date
        #       )
        #     ON COMMIT DROP
        #     AS ( VALUES #{ values } );

        #     CREATE INDEX ON timesheets_get( child_code );
        #     CREATE INDEX ON timesheets_get( children_group_code );
        #     CREATE INDEX ON timesheets_get( reasons_absence_code );
        #   SQL

        # sql_select = <<-SQL.squish
        #   SELECT
        #     COALESCE( bb.id, 0 ) AS child_id,
        #     COALESCE( bb.name, 'Не знайдений код дитини' ) AS child_name,
        #     COALESCE( cc.id, 0 ) AS children_group_id,
        #     COALESCE( cc.name, 'Не знайдений код групи' ) AS children_group_name,
        #     COALESCE( dd.id, 0 ) AS reasons_absence_id,
        #     COALESCE( dd.name, 'Не знайденишй код причини відсутності' ) AS reasons_absence_name,
        #     aa.child_code,
        #     aa.children_group_code,
        #     aa.reasons_absence_code,
        #     aa.date
        #     FROM timesheets_get aa
        #     LEFT JOIN children bb ON aa.child_code = bb.code
        #     LEFT JOIN children_groups cc ON aa.children_group_code = cc.code
        #     LEFT JOIN reasons_absences dd ON aa.reasons_absence_code = dd.code
        #     ORDER BY aa.child_code,
        #              aa.children_group_code,
        #              aa.reasons_absence_code,
        #              aa.date;
        # SQL

        # timesheets_get = nil

        # ActiveRecord::Base.connection_pool
        #   .with_connection { | connection |
        #     connection.execute( sql_create_table )
        #     timesheets_get = JSON.parse( connection.execute( sql_select ).to_json, symbolize_names: true )
        #     connection.exec_query( 'COMMIT;' )
        #   }

        # error = timesheets_get
        #   .select { | o | o[ :child_id ] || o[ :children_group_id ] || o[ :reasons_absence_id ] }
        #   .group_by { | o | { o[]}

        if error.empty?
          ActiveRecord::Base.transaction do

            data = { institution_id: current_user[ :userable_id ],
                     branch_id: current_institution[ :branch_id ],
                     date_vb: response[ :date_vb ],
                     date_ve: response[ :date_ve ],
                     date_eb: response[ :date_eb ],
                     date_ee: response[ :date_ee ] }

            id = insert_base_single( 'timesheets', data )

            fields = %w( timesheet_id children_group_id child_id
                         reasons_absence_id date ).join( ',' )

            sql_values = ''

            ts_data.each { | ts |
              children_group_id = children_groups[ :obj ][ ( ts[ :children_group_code ] || '' ).strip ]
              child_id = children[ :obj ][ ( ts[ :child_code ] || '' ).strip ]
              reasons_absence_id = reasons_absences[ :obj ][ ( ts[ :reasons_absence_code ] || '' ).strip ]
              sql_values += ",(#{ id }," +
                            "#{ children_group_id }," +
                            "#{ child_id }," +
                            "#{ reasons_absence_id }," +
                            "'#{ ts[ :date ] }')"
            }

            sql = "INSERT INTO timesheet_dates ( #{ fields } ) VALUES #{ sql_values[1..-1] }"

            ActiveRecord::Base.connection.execute( sql )

            href = institution_timesheets_dates_path( { id: id } )
            result = { status: true, href: href }
          end
        else
          result = { status: false, caption: 'Неможливо створити документ',
                    message: { error: error }.merge!( web_service ) }
        end
      else
        result = { status: false, caption: 'За вибраний період даних немає в ІС',
                  message: web_service.merge!( response: response ) }
      end
    end

    render json: result
  end

  def send_sa
    timesheet_id = params[ :id ]

    timesheet = JSON.parse( Timesheet
      .select( :id,
                :number,
                :date_vb,
                :date_ve,
                :date_eb,
                :date_ee )
      .find( timesheet_id )
      .to_json, symbolize_names: true )

    date_start = timesheet[ :date_eb ]
    date_end = timesheet[ :date_ee ]

    date_blocks = check_date_block( date_start, date_end )
    if date_blocks
      caption = 'Блокування документів'
      message = "Дата [ #{ date_blocks } ] в табелі закрита для відправлення!"
      result = { status: false, message: message, caption: caption }
    else
      timesheet_dates = JSON.parse( TimesheetDate
        .joins( { children_group: :children_category }, :child, :reasons_absence )
        .select( :id, :date,
                'children_categories.code AS category_code',
                'children_groups.code AS group_code',
                'children.code AS child_code',
                'reasons_absences.code AS reason_code' )
        .where( timesheet_id: timesheet_id )
        .order( 'category_code', 'group_code', 'child_code', :date )
        .to_json, symbolize_names: true )

      result = { }
      if timesheet_dates.present?
        ts = timesheet_dates.map{ | o | {
          'Child_code' => o[ :child_code ],
          'Children_group_code' => o[ :group_code ],
          'Reasons_absence_code' => o[ :reason_code ],
          'Date' => o[ :date ]
          }
        }

        message = {
          'CreateRequest' => {
            'Institutions_id' => current_institution[ :code ],
            'NumberFromWebPortal' => timesheet[ :number ],
            'StartDate' => timesheet[ :date_vb ],
            'EndDate' => timesheet[ :date_ve ],
            'StartDateOfTheFill' => date_start,
            'EndDateOfTheFill' => date_end,
            'TS' => ts,
            'User' => current_user[ :username ]
         }
        }

        savon_return = get_savon( :creation_time_sheet, message )
        response = savon_return[ :response ]
        web_service = savon_return[ :web_service ]

        if response[ :interface_state ] == 'OK'
          data = { date_sa: Date.today, number_sa: response[ :respond ].to_s }
          update_base_with_id( :timesheets, timesheet_id, data )
          result = { status: true }
        else
          result = { status: false, caption: 'Неуспішна сихронізація з ІС',
                    message: web_service.merge!( response: response ) }
        end
      else
        result = { status: false, caption: 'Немає данних' }
      end
    end

    render json: result
  end

  def refresh # Обновление данных о детях
    id = params[ :id ]
    timesheet = JSON.parse( Timesheet
      .select( :id, :date_eb, :date_ee )
      .find( id )
      .to_json, symbolize_names: true )

    message = {
      'CreateRequest' => {
        'StartDate' => timesheet[ :date_eb ].to_date,
        'EndDate' => timesheet[ :date_ee ].to_date,
        'Institutions_id' => current_institution[ :code ]
      }
    }

    savon_return = get_savon( :get_data_time_sheet, message )
    response = savon_return[ :response ]
    web_service = savon_return[ :web_service ]

    result = { }
    ts_data = response[ :ts ]

    if response[ :interface_state ] == 'OK' && ts_data && ts_data.present?
      error = { }

      children_codes = ts_data.group_by { | o | o[ :child_code ] }.map { | k, v | k }
      children = exists_codes( :children, children_codes )
      error.merge!( children[ :error ] ) unless children[ :status ]

      children_groups_codes = ts_data.group_by { | o | o[ :children_group_code ] }.map { | k, v | k }
      children_groups = exists_codes( :children_groups, children_groups_codes )
      error.merge!( children_groups[ :error ] ) unless children_groups[ :status ]

      reasons_absences_code = ts_data.group_by { | o | o[ :reasons_absence_code ] }.map { | k, v | k }
      reasons_absences = exists_codes( :reasons_absences, reasons_absences_code )
      error.merge!( reasons_absences[ :error ] ) unless reasons_absences[ :status ]

      if error.empty?
        reasons_absence_id_empty = ReasonsAbsence.select( :id ).find_by( code: '' ).id

        timesheet_dates = JSON.parse( TimesheetDate
          .joins( :reasons_absence )
          .select( :id,
                   :children_group_id,
                   :child_id,
                   :reasons_absence_id,
                   :date,
                   'reasons_absences.priority AS ra_priority' )
          .where( timesheet_id: id )
          .to_json, symbolize_names: true )

        ActiveRecord::Base.transaction do
          sql_ins_val = ''
          sql_update = ''

          ts_data.each { | ts |
            children_group_id = children_groups[ :obj ][ ( ts[ :children_group_code ] || '' ).strip ]
            child_id = children[ :obj ][ ( ts[ :child_code ] || '' ).strip ]
            reasons_absence_id = reasons_absences[ :obj ][ ( ts[ :reasons_absence_code ] || '' ).strip ]
            date = ts[ :date ].to_s( :db )

            child_day = timesheet_dates.select{ | o |
              o[ :children_group_id ] == children_group_id &&
              o[ :child_id ] == child_id &&
              o[ :date ] == date }

            unless child_day.present?
              sql_ins_val += ",(#{ id },#{ children_group_id },#{ child_id },#{ reasons_absence_id },'#{ date }')"
            else
              child_day[ 0 ][ :update ] = true
              ( sql_update << <<-SQL.squish
                  UPDATE timesheet_dates
                    SET reasons_absence_id = #{ reasons_absence_id }
                    WHERE id = #{ child_day[ 0 ][ :id ] };
                SQL
              ) if ( child_day[ 0 ][ :ra_priority ] == -1 || reasons_absence_id != reasons_absence_id_empty ) && child_day[ 0 ][ :reasons_absence_id ] != reasons_absence_id
            end
          }

          sql_insert = ''
          if sql_ins_val.present?
            fields = %w( timesheet_id children_group_id child_id reasons_absence_id date ).join( ',' )
            sql_insert = <<-SQL.squish
                INSERT INTO timesheet_dates ( #{ fields } ) VALUES #{ sql_ins_val[1..-1] };
              SQL
          end

          sql_del_val = timesheet_dates.select { | o | o[ :update].nil? }.map{ | o | o[ :id ] }.join( ',' )

          sql_delete = sql_del_val.present? ?
            <<-SQL.squish
                DELETE FROM timesheet_dates WHERE id IN ( #{ sql_del_val } );
              SQL
            : ''

          sql = "#{ sql_insert } #{ sql_update } #{ sql_delete }"
          ActiveRecord::Base.connection.execute( sql ) if sql.present?

          result = { status: true }
        end
      else
        result = { status: false, caption: 'Неможливо створити документ',
                  message: { error: error }.merge!( web_service ) }
      end
    else
      result = { status: false, caption: 'За вибраний період даних немає в ІС',
                message: web_service.merge!( response: response ) }
    end

    render json: result
  end

  def dates # Отображение дней табеля
    @timesheet = JSON.parse( Timesheet
      .select( :id, :number, :date, :number_sa, :date_sa, :date_eb, :date_ee )
      .find( params[ :id ] )
      .to_json, symbolize_names: true )

    reasons_absences = JSON.parse( ReasonsAbsence.select( :id, :code, :mark ).where( code: '' )
      .or( ReasonsAbsence.select( :id, :code, :mark ).where.not( mark: '' ) )
      .order( :priority )
      .to_json, symbolize_names: true )

    @reasons_absences = [ ]
    reasons_absences.zip( reasons_absences.rotate ) { | item, item_next |
      @reasons_absences << item.merge( { next_id: item_next[:id], next_mark: item_next[ :mark ] } ) }

    @group_timesheet = []
    children_category_id = 0

    TimesheetDate
      .joins( children_group: :children_category )
      .select( 'DISTINCT ON ( children_groups.children_category_id, timesheet_dates.children_group_id )
        children_groups.children_category_id', :children_group_id,
        'children_categories.name AS category_name', 'children_groups.name AS group_name' )
      .where( timesheet_id: @timesheet[ :id ] )
      .each do | o |
        if children_category_id != o.children_category_id
          children_category_id = o.children_category_id
          @group_timesheet << [ o.category_name, o.children_category_id,
            { class: :row_group, data: { field: :children_category_id } } ]
        end

        @group_timesheet << [ o.group_name, o.children_group_id, { data: { field: :children_group_id } } ]
      end
  end

  def update # Обновление реквизитов документа
    data = params.permit( :date ).to_h
    status = update_base_with_id( :timesheets, params[ :id ], data )
    render json: { status: status }
  end

  def dates_update # Обновление маркера
    data = params.permit( :reasons_absence_id ).to_h
    status = update_base_with_id( :timesheet_dates, params[ :id ], data )
    render json: { status: status }
  end

  def dates_updates # Обновление группы маркеров
    data = params.permit( { ids: [] }, :reasons_absence_id ).to_h
    reasons_absence_id = data[ :reasons_absence_id ]

    if data.present?
      sql = "UPDATE timesheet_dates SET " +
              "reasons_absence_id = #{ reasons_absence_id } " +
            "FROM UNNEST(ARRAY" +
              "#{ data[ :ids ].map { | o | o.to_i }.to_s }" +
            ") as ids " +
            "WHERE id = ids "

      ActiveRecord::Base.connection.execute( sql )
    end

    render json: { status: true }
  end

  def ajax_filter_timesheet_dates # Фильтрация таблицы
    id = params[ :id ]
    @timesheet = Timesheet.find( id )
    field = params[ :field ]

    where = ''
    where = "#{ field == 'children_group_id' ? field : 'children_groups.children_category_id' }
      = #{ params[ :field_id ] }" if ['children_group_id', 'children_category_id'].include?(field)

    @timesheet_dates = JSON.parse( TimesheetDate
      .select( :id, :timesheet_id, 'children_groups.children_category_id', :children_group_id, :child_id,
               :reasons_absence_id, :date,
               'children_categories.name AS category_name', 'children_groups.name AS group_name',
               'children.name AS child_name', 'reasons_absences.mark AS mark',
               'children_categories.code AS category_code', 'children_groups.code AS group_code',
               'children.code AS child_code', 'reasons_absences.code AS reason_code' )
      .joins( { children_group: :children_category }, :child, :reasons_absence )
      .order( 'category_name', 'group_name', 'child_name', :date )
      .where( timesheet_id: id )
      .where( where )
      .to_json, symbolize_names: true )
  end
end

