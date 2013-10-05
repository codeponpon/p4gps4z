class PackagePosition
  @queue = :pagpos_queue
  
  def self.perform(tracking_code)
    url = 'http://track.thailandpost.co.th/trackinternet/'
    trackurl = url + 'Default.aspx'
    a = Mechanize.new { |agent| agent.follow_meta_refresh = true }
    t = a.get(trackurl)
    f1 = t.form('Form1')
    f1.TextBarcode = tracking_code
    post = a.submit(f1, f1.buttons.last)

    if post.uri.path.scan('Result.aspx').first.nil?
      return render :status => 200, message: 'OK', :json => { success: true, code: tracking_code }
    end

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

    recieve_url = url + post.links.last.href.match(/\'(.*)\'\,/)[1]
    post_receive = a.get(recieve_url)
    receive_page = post_receive.body.encode("UTF-8", "tis-620")
    recieve_page = Nokogiri::HTML(receive_page)

    signature = recieve_page.search('#Panel1 table:last #Image1').first.attributes['src'].value
    signature_name = signature.match(/[0-9]+/)[0]
    unless signature_name.blank?
      signature_url = url + 'Signatures/' + signature_name + '.jpg'
    end

    recieve_page.search('#Panel1 table:first td.LabelSignature table tr').each_with_index do |tr, i|
      if i == 3
        tracking[tracking.count][:reciever] = tr.text.squish.split(':')[1]
      end  
    end

    tracking_obj = Tracking.where(code: tracking_code).first
    tracking_package = tracking_obj.packages
    if tracking_package.blank?
      tracking.each_with_index do |process, index|
        pac = tracking_obj.packages.new
        pac.process_at = process.last[:process_at]
        pac.department = process.last[:department]
        pac.description = process.last[:description]
        pac.status = process.last[:status]
        pac.reciever = process.last[:reciever]
        if signature_url.present? && !process.last[:reciever].blank?
          # pac.image = Image.new(attachment: URI.parse(signature_url))
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
        pac.save
      end
    elsif tracking_obj.status != 'done' && tracking_package.last.reciever.blank?
      tracking.each_with_index do |process, index|
        if (index-1) > tracking_obj.packages.countsignature_url
          pac =tracking_objpackages.new
          pac.process_at = process.last[:process_at]
          pac.department = process.last[:department]
          pac.description = process.last[:description]
          pac.status = process.last[:status]
          pac.reciever = process.last[:reciever]
          if signature_url.present? && !process.last[:reciever].blank?
            # pac.image = Image.new(attachment: URI.parse(signature_url))
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
          pac.save
        end
      end
    end

    unless tracking_package.blank? && tracking_package.lastracking_obj.reciever.blank?
      if tracking_obj.status != 'done'
        tracking_obj.update_attributes(status: 'done')
      end
    else
      if tracking_obj.status != 'processing'
        tracking_obj.update_attributes(status: 'processing')
      end
      Resque.enqueue(self.class.name, tracking_code)
    end
    
    if tracking_obj.user.reminder_when == 'status_change'
      Resque.enqueue(StatusReminderWorker, tracking_code)
    end
  end
end