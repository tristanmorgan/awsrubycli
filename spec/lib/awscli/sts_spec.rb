# frozen_string_literal: true

require 'spec_helper'
require 'thor'
require_relative '../../../lib/awscli_sts'

describe Awscli::Sts do
  context 'when credentials available' do
    let(:sts_client) { instance_double(Aws::STS::Client) }

    before do
      allow(Aws::STS::Client).to receive(:new).and_return(sts_client)
      allow(sts_client).to receive(:get_caller_identity).and_return(
        user_id: 'AIDABDDISBADJX56SMCAF',
        account: '123456789012',
        arn: 'arn:aws:iam::123456789012:user/tristan'
      )
      allow(sts_client).to receive(:get_access_key_info).and_return(
        account: '123456789012'
      )
      allow(sts_client).to receive(:decode_authorization_message).and_return(
        decoded_message: '{"allowed": "false","explicitDeny": "false",' \
                         '"matchedStatements": "","failures": "","context": {"principal": ' \
                         '{"id": "AIDACKCEVSQ6C2EXAMPLE","name": "Bob","arn": ' \
                         '"arn:aws:iam::123456789012:user/Bob"},"action": "ec2:StopInstances",' \
                         '"resource": "arn:aws:ec2:us-east-1:123456789012:instance/i-dd01c9bd",' \
                         '"conditions": [{"item": {"key": "ec2:Tenancy","values": ["default"]},' \
                         '{"item": {"key": "ec2:ResourceTag/elasticbeanstalk:environment-name",' \
                         '"values": ["Default-Environment"]}}}]}}'
      )
    end

    it 'calls decode_authorization_message' do
      expect { described_class.start(%w[decode_authorization_message biglongencodedmessage]) }
        .to output(/decoded_message/).to_stdout
    end

    it 'calls get_caller_identity' do
      expect { described_class.start(%w[get_caller_identity]) }
        .to output(/user_id/).to_stdout
    end

    it 'calls get_access_key_info' do
      expect { described_class.start(%w[get_access_key_info AKIA1234567890ABCDEF]) }
        .to output(/account/).to_stdout
      expect(sts_client).to have_received(:get_access_key_info).with({ access_key_id: 'AKIA1234567890ABCDEF' })
    end
  end
end
