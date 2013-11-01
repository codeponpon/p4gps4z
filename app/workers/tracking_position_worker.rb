require 'azure/azure_sdk' if Rails.env.production?

class TrackingPositionWorker
  @queue = :tracking_position_queue

  def self.perform(params)
    blobs = Rails.env.production? ? AzureSdk::Storage::Blobs : nil
    user_id, tracking_code = params
    puts "#{DateTime.now} #{tracking_code} is tracking"
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
        Tracking.where(code: tracking_code, user_id: user_id).first.update_attributes(status: 'notfound')
        puts "#{tracking_code} not found"
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

        tracking_obj = Tracking.where(code: tracking_code, user_id: user_id).first
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
            if !process.last[:reciever].blank? && signature_url.present?
              # pac.image = Image.new(attachment: URI.parse(signature_url))
              upload = UrlUpload.new(signature_url)
              file_name = upload.original_filename
              if blobs.blank?
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
                blob = blobs.create({container: 'signature', file_name: file_name, file_content: upload.read})
                if blob.name.eql?(file_name)
                  pac.signature = blobs.get_url({container: 'signature', file_name: file_name})
                end
              end
              # tracking_obj.update_attribute(:status, 'done')
            end
            pac.save
          end
        else
          tracking.each_with_index do |process, index|
            if (index+1) > package_obj.count
              pac = Package.new
              pac.tracking_id = tracking_obj.id
              pac.process_at = process.last[:process_at]
              pac.department = process.last[:department]
              pac.description = process.last[:description]
              pac.status = process.last[:status]
              pac.reciever = process.last[:reciever].strip
              if !process.last[:reciever].blank? && signature_url.present? 
                # pac.image = Image.new(attachment: URI.parse(signature_url))
                upload = UrlUpload.new(signature_url)
                file_name = upload.original_filename
                if blobs.blank?
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
                  blob = blobs.create({container: 'signature', file_name: file_name, file_content: upload.read})
                  if blob.name.eql?(file_name)
                    pac.signature = blobs.get_url({container: 'signature', file_name: file_name})
                  end
                end
                # tracking_obj.update_attribute(:status, 'done')
              end
              pac.save
            end
          end
        end
        tracking_obj.update_attribute(:packages_count, tracking.count)
        puts "#{tracking_code} tracking success"
      end # data not found
    else
      puts "#{tracking_code} cannot track has something wrong"
    end # end if not
  end
end