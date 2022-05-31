# frozen_string_literal: true

# Awskeyring Module,
module Awscli
  # Input methods for Awskeyring
  module S3Helper
    # separate the bucket from the key.
    # s3://teamvibrato/hashicorp/consul/consul_linux.zip
    #
    # @param String s3_path the combined s3 path
    # @return [Hash] with the new credentials
    #    bucket The bucket name
    #    key The path/key in the bucket
    def self.bucket_from_string(s3_path)
      matchdata = %r{s3://(?<bucket>\w*)/(?<key>\S*)}.match(s3_path)
      [matchdata[:bucket], matchdata[:key]]
    end
  end
end
