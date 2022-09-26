# frozen_string_literal: true

require 'spec_helper'
require 'thor'
require_relative '../../../lib/awscli_iam'

describe Awscli::Iam do
  context 'when credentials available' do
    let(:iam_client) { instance_double(Aws::IAM::Client) }

    before do
      allow(Aws::IAM::Client).to receive(:new).and_return(iam_client)
      allow(iam_client).to receive(:list_users).and_return(
        users: [
          {
            path: '/',
            user_name: 'tristan',
            user_id: 'AIDABDDISBADJX56SMCAF',
            arn: 'arn:aws:iam::123456789012:user/tristan',
            create_date: '2021-01-23 00:15:00 UTC',
            password_last_used: '2022-12-30 10:03:03 UTC'
          }
        ],
        is_truncated: false
      )
      allow(iam_client).to receive(:list_access_keys).and_return(
        access_key_metadata: [
          user_name: 'tristan',
          access_key_id: 'AKIA1234567890ABCDEF',
          status: 'Active',
          create_date: '2021-03-21 00:51:00 UTC'
        ],
        is_truncated: false
      )
    end

    it 'calls list_users' do
      expect { described_class.start(%w[list_users]) }
        .to output(/user_name/).to_stdout
    end

    it 'calls list_access_keys' do
      expect { described_class.start(%w[list_access_keys tristan]) }
        .to output(/access_key_metadata/).to_stdout
      expect(iam_client).to have_received(:list_access_keys).with({ user_name: 'tristan' })
    end
  end
end
