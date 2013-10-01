class Api::V1::PagposController < ApplicationController
  respond_to :json

  def track_page
    url = 'http://track.thailandpost.co.th/trackinternet/'
    txt_barcode = 'EK087348335TH'
    trackurl = url + 'Default.aspx'
    a = Mechanize.new { |agent|
      agent.follow_meta_refresh = true
    }
    t = a.get(trackurl)
    f1 = t.form('Form1')
    # f1.TextBarcode = 'EJ967486181TH'
    f1.TextBarcode = txt_barcode
    post = a.submit(f1, f1.buttons.last)

    html = post.body.gsub!(/signature.aspx/, url + 'signature.aspx').encode("UTF-8", "tis-620")
    @tracking = []
    @arr = []
    @contents_html = Nokogiri::HTML(html)
    @contents_html.search('#DataGrid1 tr').each_with_index do |tr, index|
      if index > 0
        tr.css('td').each_with_index do |td,i|
          if i==0
            @tracking[index] = { 
              date: td.content.squish.strip,
              department: td.next.content.squish.strip,
              description: td.next.next.content.squish.strip,
              status: td.next.next.next.content.squish.strip,
              reciever: td.next.next.next.next.content.squish.strip
            }
          end
        end
      end
    end
    @tracking.compact!  

    recieve_url = url + post.links.last.href.match(/\'(.*)\'\,/)[1]
    post_receive = a.get(recieve_url)
    receive_page = post_receive.body.encode("UTF-8", "tis-620")
    @recieve_page = Nokogiri::HTML(receive_page)

    signature = @recieve_page.search('#Panel1 table:last #Image1').first.attributes['src'].value
    unless signature.nil?
      @signature = signature
      # TODO Load signature
    else
      @signature = nil
    end     

    @recieve_page.search('#Panel1 table:first td.LabelSignature table tr').each_with_index do |tr, i|
      if i == 3
        @tracking.last[:reciever] = { 
          name: tr.text.squish.split(':')[1].strip, 
          signature: @signature
        }
      end  
    end
    
    render :status => 200, :json => {success: true, code: txt_barcode, data: @tracking}
    # render :template => 'welcome/user'
  end
end
