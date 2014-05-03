class PagInvoicesController < ApplicationController
  layout 'backend'

  def index
    @page_title = I18n.t('page_title.invoices')
    page = params[:page].present? ? params[:page] : 1
    @invoices = current_user.pag_invoices.paginate(:page => page, :per_page => 20)
  end

  def show
  end
end
