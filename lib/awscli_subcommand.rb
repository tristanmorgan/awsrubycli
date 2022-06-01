# frozen_string_literal: true

# Subclassing Thor to allow sub commands.
class SubCommandBase < Thor
  # create the usage label
  def self.banner(command, _namespace = nil, _subcommand = false) # rubocop:disable Style/OptionalBooleanParameter
    "#{basename} #{subcommand_prefix} #{command.usage}"
  end

  # generates the subcommand name
  def self.subcommand_prefix
    name.gsub(/.*::/, '').gsub(/^[A-Z]/) { |match| match[0].downcase }.gsub(/[A-Z]/) { |match| "-#{match[0].downcase}" }
  end
end
