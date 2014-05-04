class PagInvoicesController < ApplicationController
  layout 'backend'

  def index
    @page_title = I18n.t('page_title.invoices')
    page = params[:page].present? ? params[:page] : 1
    @invoices = current_user.pag_invoices.paginate(:page => page, :per_page => 20)
  end

  def show
    @invoice = PagInvoice.where(payment_code: params[:payment_code])
  end

  def destroy
    invoice = PagInvoice.where(payment_code: params[:payment_code]).first
    if invoice.destroy
      flash[:success] = "#{params[:payment_code]} deleted successfull"
      return redirect_to store_invoices_url
    else
      flat[:error] = "#{params[:payment_code]} has something went wrong"
      return redirect_to store_invoices_url
    end
  end
end
