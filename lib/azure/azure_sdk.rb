# Require the azure rubygem
require "azure"

module AzureSdk
  module Storage
    module Blobs
      
      @azure_blob_service = Azure::BlobService.new

      private
        def self.create_container(name=nil)
          begin
            unless(self.containers.map(&:name).include?(name))
              @azure_blob_service.create_container(name)
              @azure_blob_service.set_container_acl(name, "container")
            end
          rescue Azure::Core::Http::HTTPError => error
            error
          end
        end

        def self.containers
          begin
            @azure_blob_service.list_containers()
          rescue Azure::Core::Http::HTTPError => error
            error
          end
        end

        def self.container(name=nil)
          begin
            @azure_blob_service.list_blobs(name) 
          rescue Azure::Core::Http::HTTPError => error
            error
          end
        end

        def self.lists
          begin         
            response  = Hash.new({})
            containers = self.containers
            containers.each do |container|
              blobs_arr = []
              blobs = @azure_blob_service.list_blobs(container.name)
              blobs.each do |blob|
                blobs_arr << { name: blob.name, url: self.get_url({container: container.name, file_name: blob.name}) }
              end
              response[container.name.to_sym] = blobs_arr
            end
            return response
          rescue Azure::Core::Http::HTTPError => error
            error
          end
        end

        def self.create(args=nil)
          begin
            container_name  = args[:container]
            blob_name       = args[:file_name]
            result          = self.get_blob({container: args[:container], file_name: args[:file_name]})
            return result.first unless result.try(:count).blank?
            content         = args[:file_content]
            @azure_blob_service.create_block_blob(container_name, blob_name, content)
          rescue Azure::Core::Http::HTTPError => error
            error
          end
        end

        def self.download(args=nil)
          begin
            result = self.get_blob({container: args[:container], file_name: args[:file_name]})
            return result unless result.try(:status_code).blank?
            File.open("#{blob_name}.jpg","wb") {|f| f.write(result.last)}
          rescue Azure::Core::Http::HTTPError => error
            error
          end
        end 

        def self.get_url(args=nil)
          begin
            acc = Azure.config.storage_account_name
            container_name = args[:container]
            blob_name      = args[:file_name]
            "http://#{acc}.blob.core.windows.net/#{container_name}/#{blob_name}"
          rescue Azure::Core::Http::HTTPError => error
            error
          end
        end

        def self.destroy(args=nil)
          begin
            container_name  = args[:container]
            if args[:file_name].present?
              blob_name       = args[:file_name]
              @azure_blob_service.delete_blob(container_name, blob_name)
            else
              @azure_blob_service.list_blobs(container_name).each do |blob|
                @azure_blob_service.delete_blob(container_name, blob.name)
              end
            end
          rescue Azure::Core::Http::HTTPError => error
            error
          end
        end

        def self.get_blob(args=nil)
          begin
            container_name  = args[:container]
            blob_name       = args[:file_name]
            blob, content   = @azure_blob_service.get_blob(container_name, blob_name)
          rescue Azure::Core::Http::HTTPError => error
            error
          end
        end

    end
  end  
end