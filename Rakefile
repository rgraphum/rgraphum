# -*- coding: utf-8 -*-

require "bundler/gem_tasks"
require 'rake/testtask'

# require 'pry'
# require 'pry-nav'
# require 'pry-exception_explorer'
# require 'pry-stack_explorer'
# require 'pry-coolline'

Rake::TestTask.new(:test) do |t|
  t.pattern = "test/**/*_test.rb"
  t.libs << "lib"
  t.libs << "test"
end
