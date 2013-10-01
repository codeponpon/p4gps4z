class Api::V1::PagposController < ApplicationController
    # respond_to :json
  
    def track_page
      # require 'net/http'  
      # endpoint = 'http://track.thailandpost.co.th/trackinternet/Default.aspx'
      # url = URI.parse(endpoint)
      # post_args = {'TextBarcode' => 'EJ967486181TH'}
      # resp = Net::HTTP.post_form(url, post_args)
      # res = Net::HTTP.get_response(URI('http://track.thailandpost.co.th/trackinternet/Result.aspx'))

      # uri = URI('http://track.thailandpost.co.th/trackinternet/Result.aspx')
      # params = {'TextBarcode' => 'EJ967486181TH'}
      # uri.query = URI.encode_www_form(params)
      # res = Net::HTTP.get_response(uri)
      # puts res.body if res.is_a?(Net::HTTPSuccess)
      track_url = 'http://track.thailandpost.co.th/trackinternet/'
      # cookie_path = File.expand_path('../../../../tmp/cookies/cookies.txt', __FILE__)
      # t = Typhoeus.get(track_url + "Default.aspx")
      # viewstate =  t.response_body.match(/\"\_\_VIEWSTATE\" value\=\"(.*)\"/)[1]
      # eventvalidation = t.response_body.match(/\"\_\_EVENTVALIDATION\" value\=\"(.*)\"/)[1] 
      
      # # request = Typhoeus.post(track_url + 'Default.aspx?__EVENTTARGET=Login&__VIEWSTATE='+viewstate+'&__EVENTVALIDATION'+eventvalidation+'&TextBarcode=EJ967486181TH', followlocation: true, cookiefile: cookie_path, cookiejar: cookie_path)
      # request = Typhoeus::Request.new(
      #   track_url + 'Default.aspx',
      #   method: :post,
      #   params: {
      #     '__EVENTTARGET' => 'Login',
      #     '__VIEWSTATE' => viewstate, 
      #     '__EVENTVALIDATION' => eventvalidation, 
      #     'TextBarcode' => 'EJ967486181TH' 
      #   },
      #   headers: { 
      #     'Accept' => 'image/gif, image/x-bitmap, image/jpeg, image/pjpeg, text/html',
      #     'Connection' => 'Keep-Alive',
      #     'Content-type' => 'application/x-www-form-urlencoded;charset=UTF-8' 
      #   },
      #   followlocation: true,
      #   cookiefile: cookie_path, 
      #   cookiejar: cookie_path,
      #   useragent: 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 1.0.3705; .NET CLR 1.1.4322; Media Center PC 4.0)',
      #   encoding: 'gzip',
      #   timeout: 30,
      #   post: 1,
      # )
      # request.run
      # response = request.response
      # hydra = Typhoeus::Hydra.new(max_concurrency: 3000)
      # hydra = Typhoeus::Hydra.hydra
      # hydra.queue(request)
      # hydra.run
      url = 'http://track.thailandpost.co.th/trackinternet/'
      trackurl = url + 'Default.aspx'
      a = Mechanize.new { |agent|
        agent.follow_meta_refresh = true
      }
      t = a.get(trackurl)
      f1 = t.form('Form1')
      # f1.TextBarcode = 'EJ967486181TH'
      f1.TextBarcode = 'EK087348335TH'
      post = a.submit(f1, f1.buttons.last)

      html = post.body.gsub!(/signature.aspx/, url + 'signature.aspx').encode("UTF-8", "tis-620")
      # tracking = {track_time: '', agentcy: '', description: '', result: ''}
      @contents_html = Nokogiri::HTML(html)
      @contents_html.search('#DataGrid1 tr').each do |tr|
        tr.css('td').each do |td|
          td.content
        end
      end

      recieve_url = url + post.links.last.href.match(/\'(.*)\'\,/)[1]
      post_receive = a.get(recieve_url)
      receive_page = post_receive.body.encode("UTF-8", "tis-620")
      @recieve_page = Nokogiri::HTML(receive_page)

      # @contents_xml = Nokogiri::XML(@html).search('#DataGrid1')
      render :template => 'welcome/user'
      # return render :status => 200, :json => {success: true, data: @xml}
    end
end
