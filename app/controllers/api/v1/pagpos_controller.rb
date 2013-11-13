class Api::V1::PagposController < Devise::SessionsController
  before_filter :authenticate_user!, except: [:force_get_data]
  # respond_to :json

  def index
  end

  def show
    tracking_code = params[:tracking_code]
    @track = current_user.trackings.new(code: tracking_code)
    if @track.save
      # Resque.enqueue(PackagePosition, tracking_code)
      PackagePosition.create(tracking_code)
      render :status => 200, message: 'OK', :json => { success: true, message: "Add tracking code successfully"}
    else
      return render :status => 400, message: 'Bad request', :json => { success: false, errors: @track.errors.full_messages[0]}
    end
  end

  def force_get_data
    tracking_code = params[:tracking_code] #'EK087348335TH'
    url = 'http://track.thailandpost.co.th/trackinternet/'
    trackurl = url + 'Default.aspx'
    a = Mechanize.new { |agent| agent.follow_meta_refresh = true }
    t = a.get(trackurl)
    f1 = t.form('Form1')
    f1.TextBarcode = tracking_code
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
        Tracking.where(code: tracking_code).first.update_attributes(status: 'notfound')
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

        tracking_obj = Tracking.where(code: tracking_code).first
        package_obj = Package.where(tracking_id: tracking_obj.id)
        if package_obj.blank?
          tracking.each_with_index do |process, index|
            pac = Package.new
            pac.tracking_id = tracking_obj.id
            pac.process_at = process.last[:process_at]
            pac.department = process.last[:department]
            pac.description = process.last[:description]
            pac.status = process.last[:status]
            pac.reciever = process.last[:reciever].strip
            if not process.last[:reciever].blank?
              # pac.image = Image.new(attachment: URI.parse(signature_url))
              if signature_url.present? 
                upload = UrlUpload.new(signature_url)
                directory = "public/system/signature/"
                user_dir = directory + tracking_obj.user._id.to_s
                Dir.mkdir(user_dir) unless File.exists?(user_dir)
                path = File.join(user_dir, upload.original_filename)
                File.open(path, "wb") { |f| f.write(upload.read) }

                if File.exists?(path)
                  pac.signature = path
                end
              end
              # tracking_obj.update_attribute(:status, 'done')
            end
            pac.save
          end
        else
          tracking.each_with_index do |process, index|
            if (index-1) > package_obj.count
              pac = Package.new
              pac.tracking_id = tracking_obj.id
              pac.process_at = process.last[:process_at]
              pac.department = process.last[:department]
              pac.description = process.last[:description]
              pac.status = process.last[:status]
              pac.reciever = process.last[:reciever].strip
              if not process.last[:reciever].blank?
                # pac.image = Image.new(attachment: URI.parse(signature_url))
                if signature_url.present? 
                  upload = UrlUpload.new(signature_url)
                  directory = "public/system/signature/"
                  user_dir = directory + tracking_obj.user._id.to_s
                  Dir.mkdir(user_dir) unless File.exists?(user_dir)
                  path = File.join(user_dir, upload.original_filename)
                  File.open(path, "wb") { |f| f.write(upload.read) }

                  if File.exists?(path)
                    pac.signature = path
                  end
                end
                # tracking_obj.update_attribute(:status, 'done')
              end
              pac.save
            end
          end
        end
        tracking_obj.update_attribute(:packages_count, tracking.count)
        return render json: {data: tracking}
      end # error data not found
    end # end if not
  end

  # Push notification by Facebook Chat
  def fbchat
    require 'xmpp4r_facebook'
    reciever_uid = '625109503'
    sender_uid = '100007021091903'
    fbtoken = 'CAAHjh3c3ZAMQBAH9hKVAtmZBKSQ1iDijLTEg7ZBQ7TEFTREMKJGK1g7gqsKaHhL2JfEyw0YeeLUqNweuiPm5wTQ9dk7tgNUuV4uDVwxM7cPdCZBdatCGRVF2wetIx3UwICINOxvY4kwfih9MSv40BIwJdCMfyuMcXMdjsGEAKkU748GQqlT9'
    fb_app_id = Devise.omniauth_configs[:facebook].strategy[:client_id]
    fb_app_secret = Devise.omniauth_configs[:facebook].strategy[:client_secret]


    id = "#{sender_uid}@chat.facebook.com"
    to = "#{reciever_uid}@chat.facebook.com"
    body = "Send from PAGPOS"
    # subject = 'message from ruby'
    message = Jabber::Message.new to, body
    # message.subject = subject
    begin
      client = Jabber::Client.new Jabber::JID.new(id)
      client.connect
      authorized = Jabber::SASL::XFacebookPlatform.new(client, fb_app_id, fbtoken, fb_app_secret)
      client.auth_sasl(authorized, nil)
      client.send message      
      client.close
      return render json: { success: true  }
    rescue
      return render json: { success: false, message: 'Cannot authorized maybe your access token expired'}
    end
  end
end
