class Api::V1::PagposController < ApplicationController
    respond_to :json
  
    def post_to_endpoint
      require 'net/http'  
      endpoint = 'http://track.thailandpost.co.th/trackinternet/Default.aspx'
      url = URI.parse(endpoint)
      post_args = {'TextBarcode' => 'EJ967486181TH'}
      resp = Net::HTTP.post_form(url, post_args)
      res = Net::HTTP.get_response(URI('http://track.thailandpost.co.th/trackinternet/Result.aspx'))

      # uri = URI('http://track.thailandpost.co.th/trackinternet/Result.aspx')
      # params = {'TextBarcode' => 'EJ967486181TH'}
      # uri.query = URI.encode_www_form(params)
      # res = Net::HTTP.get_response(uri)
      # puts res.body if res.is_a?(Net::HTTPSuccess)

      return render json: resp
    end
end
