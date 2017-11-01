module DPL
  class Provider
    class AzureBlob < Provider
      def config
        {
          "accessKey" => options[:accessKey] || context.env['AZURE_BLOB_ACCESS_KEY'],
          "sourceDir" => options[:source] || context.env['AZURE_BLOB_SOURCE_DIR'] || '/',
          "destinationUrl" => options[:container] || context.env['AZURE_BLOB_DESTINATION_URL']
        }
      end

      def install_deploy_dependencies
        context.shell "curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg"
        context.shell "sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg"
        context.shell "sudo sh -c 'echo \"deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod xenial main\" > /etc/apt/sources.list.d/dotnetdev.list'"
        context.shell "sudo apt-get -update -q"
        context.shell "sudo apt-get -qq install dotnet-dev-1.1.4"
        context.shell "wget -O azcopy.tar.gz https://aka.ms/downloadazcopyprlinux | tar -xf azcopy.tar.gz | ./install.sh"
      end

      def needs_key?
        false
      end

      def check_app
      end

      def check_auth
        error "missing Azure Blob Storage Access Key" unless config['accessKey']
        error "missing Azure Blob Destination URL" unless config['destinationUrl']
      end

      def push_app
        log "Deploying to Azure Blob Storage '#{config['destinationUrl']}'"

        if !!options[:verbose]
          context.shell "azcopy --source #{config['sourceDir']} --destination ${config['destinationUrl']} --dest-key ${config['accessKey']} --recursive --quiet --set-content-type"
        else
          context.shell "azcopy --source #{config['sourceDir']} --destination ${config['destinationUrl']} --dest-key ${config['accessKey']} --recursive --quiet --set-content-type > /dev/null 2>&1"
        end
      end
    end
  end
end
