class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :mailer_set_url_options

  def mailer_set_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  def abstract_json_for_jqgrid records, columns = nil, options = {}

    return if records.empty?

    columns ||= records.first.attributes.keys

    options[:id_column] ||= columns.first
    options[:page]      ||= records.current_page

    { :page => options[:page],
      :total => records.total_pages,
      :records => records.total_entries,
      :rows => records.map do |r| {
        :id => ( value = r
                 options[:id_column].each_line('.') do |n|
                   value = value.send(n.chomp('.'))
                 end
                 value),
        :cell => columns.map do |c|
                   value = r
                   c.each_line('.') do |n|
                     if(value != nil) then
                       m = n.chomp('.')
                       if !options[:params].nil? and !options[:params][m].nil?
                         value = value.send(m, options[:params][m])
                       else
                         value = value.send(m)
                       end
                     end
                   end
                   value
                 end}
      end
    }.to_json

  end

  def objects_order_by_from_params objects, params
    if params[:sord] == 'asc'
      objects.sort! { |a,b| a = ( v = a
                                  params[:sidx].each_line('.') do |n|
                                    v = v.send(n.chomp('.'))
                                  end
                                  v) <=> b = ( w = b
                                               params[:sidx].each_line('.') do |n|
                                                 w = w.send(n.chomp('.'))
                                               end
                                               w) }
    else
      objects.sort! { |b,a| a = ( v = a
                                  params[:sidx].each_line('.') do |n|
                                    v = v.send(n.chomp('.'))
                                  end
                                  v) <=> b = ( w = b
                                               params[:sidx].each_line('.') do |n|
                                                 w = w.send(n.chomp('.'))
                                               end
                                               w) }
    end
  end
  
  def set_current_user
    User.current = current_user.entity
  end

end
