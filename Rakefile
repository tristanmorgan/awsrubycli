# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'yard'

RuboCop::RakeTask.new do |rubocop|
  rubocop.options = ['-D']
  rubocop.requires << 'rubocop-performance'
  rubocop.requires << 'rubocop-rake'
  rubocop.requires << 'rubocop-rubycw'
end

desc 'Run RSpec code examples'
task :spec do
  puts 'Running RSpec...'
  require 'rspec/core'
  runner = RSpec::Core::Runner
  xcode = runner.run(%w[--pattern spec/**{,/*/**}/*_spec.rb --order rand --format documentation --color])
  abort 'RSpec failed' if xcode.positive?
end

desc 'Check filemode bits'
task :filemode do
  files = Set.new(`git ls-files -z`.split("\x0"))
  dirs = Set.new(files.map { |file| File.dirname(file) })
  failure = false
  files.merge(dirs).each do |file|
    mode = File.stat(file).mode
    print '.'
    if (mode & 0x7) != ((mode >> 3) & 0x7)
      puts file
      failure = true
    end
  end
  abort 'Error: Incorrect file mode found' if failure
  print "\n"
end

YARD::Rake::YardocTask.new do |t|
  t.options = ['--fail-on-warning', '--no-progress', '--files', '*.md']
  t.stats_options = ['--list-undoc']
end

task default: %i[filemode rubocop spec yard]
