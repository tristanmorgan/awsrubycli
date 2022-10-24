# frozen_string_literal: true

require 'spec_helper'
require 'thor'
require_relative '../../../lib/awscli_ec2'

describe Awscli::Ec2 do
  context 'when credentials available' do
    let(:ec2_client) { instance_double(Aws::EC2::Client) }

    before do
      allow(Aws::EC2::Client).to receive(:new).and_return(ec2_client)
      allow(ec2_client).to receive(:describe_key_pairs).and_return(
        key_pairs: [
          {
            key_pair_id: 'key-001ba0039f47ba2eb',
            key_fingerprint: '54:19:9a:82:e2:a5:76:1e:38:e4:c1:d1:68:20:15:41:17:65:6f:40',
            key_name: 'workshop',
            key_type: 'rsa',
            tags: [],
            create_time: '2021-08-23 02:07:31 UTC'
          }
        ]
      )
      allow(ec2_client).to receive(:delete_key_pair).and_return({})
    end

    it 'calls describe-key-pairs' do
      expect { described_class.start(%w[describe_key_pairs]) }
        .to output(/workshop/).to_stdout
    end

    it 'calls delete-key-pair' do
      expect { described_class.start(%w[delete_key_pair workshop]) }
        .to output(/{\n}/).to_stdout
      expect(ec2_client).to have_received(:delete_key_pair).with({ key_name: 'workshop' })
    end
  end
end
