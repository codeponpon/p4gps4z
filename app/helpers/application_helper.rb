#coding: utf-8

module ApplicationHelper
  def backend_menu(name=nil)
    name = name.to_s
    menu_name = "backend.menu.#{name}"
    link_name = 'backend.menu.dashboard';
    link_url  = '#';
    case name
    when 'dashboard'
      link_name = "<i class='fa fa-dashboard fa-fw'></i> "
    when 'stores'
      link_name = "<i class='fa fa-home fa-fw'></i> "
    when 'sms'
      link_name = "<i class='fa fa-comment fa-fw'></i> "
    when 'newsletters'
      link_name = "<i class='fa fa-envelope fa-fw'></i> "
    when 'customers'
      link_name = "<i class='fa fa-users fa-fw'></i> "
    when 'packages'
      link_name = "<i class='fa fa-gift fa-fw'></i> "
    when 'statistics'
      link_name = "<i class='fa fa-bar-chart-o fa-fw'></i> "
    when 'invoices'
      link_name = "<i class='fa fa-money fa-fw'></i> "
    when 'profile'
      link_name = "<i class='fa fa-user fa-fw'></i> "
    when 'setting'
      link_name = "<i class='fa fa-gear fa-fw'></i> "
    when 'logout'
      link_name = "<i class='fa fa-sign-out fa-fw'></i> "
    else
      link_name = "<i class='fa fa-dashboard fa-fw'></i> "
    end
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

end
