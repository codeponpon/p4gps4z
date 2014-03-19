#coding: utf-8

module ApplicationHelper
  def single_controller(name=nil)
    unless name.blank?
      case name
      when 'stores'
        single_name = 'store'
      else
        single_name = 'root'
      end
      return single_name
    end
  end

  def backend_menu(name=nil)
    name = name.to_s
    menu_name = "backend.menu.#{name}"
    link_url  = '#';
    rename_controller = request.path.split('/')[1]
    case name
    when 'dashboard'
      link_name = "<i class='fa fa-dashboard fa-fw'></i> "
      link_url  = try("#{rename_controller}_dashboard_url")
    when 'stores'
      link_name = "<i class='fa fa-home fa-fw'></i> "
      link_url  = try("#{rename_controller}_lists_url")
    when 'sms'
      link_name = "<i class='fa fa-comment fa-fw'></i> "
      link_url  = try("#{rename_controller}_sms_url")
    when 'newsletters'
      link_name = "<i class='fa fa-envelope fa-fw'></i> "
      # link_url  = try("#{rename_controller}_#{name}_url")
    when 'customers'
      link_name = "<i class='fa fa-users fa-fw'></i> "
      # link_url  = try("#{rename_controller}_#{name}_url")
    when 'users'
      link_name = "<i class='glyphicon glyphicon-user'></i> "
      # link_url  = try("#{rename_controller}_#{name}_url")
    when 'packages'
      link_name = "<i class='fa fa-gift fa-fw'></i> "
      # link_url  = try("#{rename_controller}_#{name}_url")
    when 'statistics'
      link_name = "<i class='glyphicon glyphicon-stats'></i> "
      # link_url  = try("#{rename_controller}_#{name}_url")
    when 'invoices'
      link_name = "<i class='fa fa-money fa-fw'></i> "
      # link_url  = try("#{rename_controller}_#{name}_url")
    when 'profile'
      link_name = "<i class='fa fa-user fa-fw'></i> "
      link_url  = store_profile_url
    when 'setting'
      link_name = "<i class='fa fa-gear fa-fw'></i> "
    when 'logout'
      link_name = "<i class='fa fa-sign-out fa-fw'></i> "
      link_url  = destroy_user_session_url
    else
      link_name = "<i class='fa fa-dashboard fa-fw'></i> "
      link_url  = try("#{rename_controller}_dashboard_url")
    end
    link_url  = try("#{rename_controller}_#{name}_url") if link_url.eql?('#')
    return link_to raw(link_name + I18n.t(menu_name).capitalize), link_url
  end

  def menu_builder(*lists, attrs)
    menu_class = 'nav'
    if attrs[:class].present?
      menu_class = attrs[:class]
    end

    menu_id = 'side-menu'
    if attrs[:id].present?
      menu_id = attrs[:id]
    end

    menus = "<ul id='#{menu_id}' class='#{menu_class}'>"
    lists.each do |menu|
      if menu.eql?(:divider)
        menus += '<li class="divider"></li>'
      else
        menus += '<li>' + backend_menu(menu) + '</li>'
      end
    end
    menus += "</ul>"
    return raw(menus)
  end

  def menu_disabled?()
    disable_is = [
      {
        controller: 'stores',
        action: ['index', 'register', 'forgot_password', 'create']
      },
      {
        controller: 'sessions',
        action: ['new']
      },
      {
        controller: 'passwords',
        action: ['edit']
      }
    ]
    controller = request.params[:controller]
    action = request.params[:action]

    disable_is.each do |item|
      return true if item[:controller].eql?(controller) && item[:action].include?(action)
    end
    return false
  end
end
