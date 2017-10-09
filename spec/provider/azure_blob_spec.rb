require 'spec_helper'
require 'dpl/provider/azure_blob'


describe DPL::Provider::AzureBlob do
  subject :provider do
    described_class.new(DummyContext.new,
                        :accessKey => 'secret',
                        :sourceDir => 'public',
                        :destinationUrl => 'https://dplblob.blob.core.windows.net/dplcontainer')
  end

  subject :provider_without_source do
    described_class.new(DummyContext.new,
                        :accessKey => 'secret',
                        :destinationUrl => 'https://dplblob.blob.core.windows.net/dplcontainer')
  end


  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe "#check_auth" do
    example "Without access key" do
      provider.options.update(:accessKey => nil)
      expect{provider.check_auth}.to raise_error(DPL::Error, 'missing Azure Blob Storage Access Key')
    end

    example "Without destination URL" do
      provider.options.update(:destinationUrl => nil)
      expect{provider.check_auth}.to raise_error(DPL::Error, 'missing Azure Blob Destination URL')
    end

  end

  describe "push_app" do
    example "Verbose" do
      provider.options.update(:verbose => true)
      expect(provider.context).to receive(:shell).with('azcopy --source public --destination https://dplblob.blob.core.windows.net/dplcontainer --dest-key secret --recursive --quiet --set-content-type')
      provider.push_app
    end

    example "Not verbose" do
      provider.options.update(:verbose => false)
      expect(provider.context).to receive(:shell).with('azcopy --source public --destination https://dplblob.blob.core.windows.net/dplcontainer --dest-key secret --recursive --quiet --set-content-type > /dev/null 2>&1')
      provider.push_app
    end 
  end

end