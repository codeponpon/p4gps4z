class PagInvoicesController < ApplicationController
  layout 'backend'

  def index
    @page_title = I18n.t('page_title.invoices')
  end

  def show
  end
end
