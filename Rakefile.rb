require 'rubygems'
require 'spec/rake/spectask'
require 'fileutils'

desc 'Default: run tests.'
task :default => :spec

desc "Run RSpec tests"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList["#{File.dirname(__FILE__)}/spec/*_spec.rb"]
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
end