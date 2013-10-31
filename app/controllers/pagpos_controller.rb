require 'azure/azure_sdk' if Rails.env.production?

class PagposController < ApplicationController

  before_filter :sabud_blob

  def new
    @tracking = Tracking.new
  end

  def create
    qtracking = Tracking.where(code: params[:tracking][:code], status: TrackingStatus.guest).first
    if qtracking.blank?
      @tracking = Tracking.new(code: params[:tracking][:code], status: TrackingStatus.guest)
      if @tracking.save
        flash[:notice] = "Add tracking code successfully"
        redirect_to action: "show", code: params[:tracking][:code]
      else
        render action: "new"
      end
    else
      redirect_to action: 'show', code: params[:tracking][:code]
    end
  end

  def show
    if params_validation.blank?
      flash[:alert] = "Tracking code is invalid"
      redirect_to action: "new"
    else
      @tracking = Tracking.where(code: params[:code], status: TrackingStatus.guest).first
      if @tracking.blank?
        @tracking = Tracking.create(code: params[:code], status: TrackingStatus.guest)
      end
      @tracking_code = params[:code]
      track_position
    end
  end

  def track_position
    url = 'http://track.thailandpost.co.th/trackinternet/'
    trackurl = url + 'Default.aspx'
    a = Mechanize.new { |agent| agent.follow_meta_refresh = true }
    t = a.get(trackurl)
    f1 = t.form('Form1')
    f1.TextBarcode = @tracking_code
    post = a.submit(f1, f1.buttons.last)

    if not post.uri.path.scan('Result.aspx').first.nil?
      html = post.body.gsub!(/signature.aspx/, url + 'signature.aspx').encode("UTF-8", "tis-620")
      tracking = Hash.new({})
      contents_html = Nokogiri::HTML(html)
      contents_html.search('#DataGrid1 tr').each_with_index do |tr, index|
        if index > 0
          tracking[index] = Hash.new({})
          tr.css('td').each_with_index do |td,i|
            if i == 0 
              tracking[index][:process_at] = td.content.squish
            end
            if i == 1
              tracking[index][:department] = td.content.squish
            end
            if i == 2 
              tracking[index][:status] = td.content.squish
            end
            if i == 3 
              tracking[index][:description] = td.content.squish
            end
            if i == 4 
              tracking[index][:reciever] = td.content.squish
            end
          end
        end
      end
      post_receive_link = post.links.last.href.match(/\'(.*)\'\,/)
      if post_receive_link.blank?
        flash[:alert] = 'Tracking code not found'
        redirect_to action: "new"
      else
        recieve_url = url + post.links.last.href.match(/\'(.*)\'\,/)[1]
        post_receive = a.get(recieve_url)
        receive_page = post_receive.body.encode("UTF-8", "tis-620")
        recieve_page = Nokogiri::HTML(receive_page)

        signature = recieve_page.search('#Panel1 table:last #Image1').first.attributes['src'].value
        unless signature.match(/[0-9]+/).blank?
          signature_name = signature.match(/[0-9]+/)[0]
          signature_url = url + 'Signatures/' + signature_name + '.jpg'
        end

        recieve_page.search('#Panel1 table:first td.LabelSignature table tr').each_with_index do |tr, i|
          if i == 3
            tracking[tracking.count][:reciever] = tr.text.squish.split(':')[1]
          end
        end

        # @tracking = Tracking.where(code: tracking_code, status: TrackingStatus.guest).first
        package_obj = Package.where(tracking_id: @tracking.id)
        if package_obj.blank?
          tracking.each_with_index do |process, index|
            pac = Package.new
            pac.tracking_id = @tracking.id
            pac.process_at = process.last[:process_at]
            pac.department = process.last[:department]
            pac.description = process.last[:description]
            pac.status = process.last[:status]
            pac.reciever = process.last[:reciever].strip
            if not process.last[:reciever].blank?
              # pac.image = Image.new(attachment: URI.parse(signature_url))
              if signature_url.present? 
                upload = UrlUpload.new(signature_url)
                file_name = upload.original_filename
                if @blobs.blank?
                  Dir.mkdir(Dir.getwd + "/public/system/") unless File.exists?(Dir.getwd + "/public/system/")
                  directory = Dir.getwd + "/public/system/signature/"
                  Dir.mkdir(directory) unless File.exists?(directory)
                  user_dir = directory + @tracking.id.to_s
                  Dir.mkdir(user_dir) unless File.exists?(user_dir)
                  path = File.join(user_dir, file_name)
                  File.open(path, "wb") { |f| f.write(upload.read) }
                  if File.exists?(path)
                    pac.signature = path.split('/public').last
                  end
                else
                  blob = @blobs.create({container: 'signature', file_name: file_name, file_content: upload.read})
                  if blob.name.eql?(file_name)
                    pac.signature = @blobs.get_url({container: 'signature', file_name: file_name})
                  end
                end
              end
              # @tracking.update_attribute(:status, 'done')
            end
            pac.save
          end
        else
          tracking.each_with_index do |process, index|
            if (index+1) > package_obj.count
              pac = Package.new
              pac.tracking_id = @tracking.id
              pac.process_at = process.last[:process_at]
              pac.department = process.last[:department]
              pac.description = process.last[:description]
              pac.status = process.last[:status]
              pac.reciever = process.last[:reciever].strip
              if not process.last[:reciever].blank?
                # pac.image = Image.new(attachment: URI.parse(signature_url))
                if signature_url.present? 
                  upload = UrlUpload.new(signature_url)
                  file_name = upload.original_filename
                  if @blobs.blank?
                    Dir.mkdir(Dir.getwd + "/public/system/") unless File.exists?(Dir.getwd + "/public/system/")
                    directory = Dir.getwd + "/public/system/signature/"
                    Dir.mkdir(directory) unless File.exists?(directory)
                    user_dir = directory + @tracking.id.to_s
                    Dir.mkdir(user_dir) unless File.exists?(user_dir)
                    path = File.join(user_dir, file_name)
                    File.open(path, "wb") { |f| f.write(upload.read) }
                    if File.exists?(path)
                      pac.signature = path.split('/public').last
                    end
                  else
                    blob = @blobs.create({container: 'signature', file_name: file_name, file_content: upload.read})
                    if blob.name.eql?(file_name)
                      pac.signature = @blobs.get_url({container: 'signature', file_name: file_name})
                    end
                  end
                end
                # @tracking.update_attribute(:status, 'done')
              end
              pac.save
            end
          end
        end
        @tracking.update_attribute(:packages_count, tracking.count)
        # return render text: "#{tracking_code} tracking success"
        # return render json: tracking
      end # data not found
    else
      # return render text: "#{tracking_code} cannot track has something wrong"
      @tracking = nil
    end # end if not
  end

  def params_validation
    valid_code_regex = /\A[E|C|R|L][A-Z][0-9]{9}[0-9A-Z]{2}\Z/
    valid_code_regex.match(params.require(:code).upcase)
  end

  private
    def sabud_blob
      @blobs = nil
      return @blobs unless Rails.env.production?
      @blobs = AzureSdk::Storage::Blobs
    end
end