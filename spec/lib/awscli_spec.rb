# frozen_string_literal: true

require 'spec_helper'
require 'thor'
require_relative '../../lib/awscli'

describe Awscli::Cli do
  context 'when things are left to the defaults' do
    let(:current_version) { '0.0.1' }
    let(:home_page) { 'https://github.com/tristanmorgan/awsrubycli' }

    it 'outputs help text' do
      expect { described_class.start(%w[help]) }
        .to output(/Aws commands:/).to_stdout
    end

    it 'returns the version number' do
      expect { described_class.start(%w[__version]) }
        .to output(/aws\(ruby\)cli v\d+.\d+.\d+\naws-sdk-core v\d+.\d+.\d+\nHomepage/).to_stdout
    end

    it 'prints autocomplete help text' do
      expect { described_class.start(%w[autocomplete]) }.to raise_error
        .and output(%r{enable autocomplete with 'complete -C /.+/\w+ \w+'}).to_stderr
    end

    test_cases = [
      ['aws clo', %w[clo aws], "cloudformation\n", 'commands'],
      ['aws help s', %w[s help], "s3\nsts\n", 'commands for help']
    ]

    test_cases.shuffle.each do |testcase|
      it "lists #{testcase[3]} with autocomplete" do
        ENV['COMP_LINE'] = testcase[0]
        ENV['COMP_POINT'] = ENV['COMP_LINE'].size.to_s
        expect { described_class.start(testcase[1].unshift('autocomplete')) }
          .to output(testcase[2]).to_stdout
        ENV['COMP_POINT'] = nil
      end
    end

    it 'lists all commands with autocomplete' do
      ENV['COMP_LINE'] = 'aws '
      ENV['COMP_POINT'] = ENV['COMP_LINE'].size.to_s
      expect { described_class.start(['autocomplete', '', 'aws']) }
        .to output(/--version\ncloudformation\n/).to_stdout
      ENV['COMP_LINE'] = nil
    end
  end
end
