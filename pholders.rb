#!/usr/bin/env ruby

require 'rubygems'
require 'commander/import'

require_relative 'pholdersUtils.rb'


# ---- 
# some global vars here
$user_home = Dir.home
# OLD
$old_simulators_home = $user_home + "/Library/Application Support/iPhone Simulator"
$old_simulators_apps = "/Applications"
# NEW
$new_simulators_home = $user_home + "/Library/Developer/CoreSimulator/Devices"
$new_simulators_apps = "/data/Containers/Data/Application"


program :version, '0.0.1'
program :description, 'Finds iOS simulators folders and performs actions'

global_option('--verbose') { $verbose = true }

command :list do |c|
  c.syntax = 'pholders list [options]'
  c.description = 'List all simulators installations'
  c.option '--xcode [XCODE_TYPE]', [:xcode5, :xcode6, :both], 'Which Xcode simulators to find: xcode5, xcode6 or both?'
  c.action do |args, options|
    options.default :xcode => :both

    say 'Listing Simulator Folders'
    if options.xcode == :xcode5 or options.xcode == :both
      say "OLD : #{$old_simulators_home}"
      puts PholdersUtils.list_sorted $old_simulators_home+"/*"      
      say "OLD ==="
    end
    if options.xcode == :xcode6 or options.xcode == :both
      say "NEW : #{$new_simulators_home}"
      new_sims = PholdersUtils.list_sorted $new_simulators_home+"/*"      
      new_sims.each { |e| 
        PholdersUtils.display_device_info e 
      }
      say "NEW ==="
    end
  end
end


  # # Dir.foreach(".") {|x| puts "Got #{x}" }
  # puts "\n======================"
  # puts "found OLD simulators...."
  # puts "OLD SIMS: #{$old_simulators_home}"
  # old_sims = list_sorted $old_simulators_home+"/*"

  # puts " ---- "
  # old_sims.each { |e| list_sorted e+$old_simulators_apps+"/*" }
  # puts " ---- "

  # puts "\n\n======================"
  # puts "\n======================"
  # puts "\nfound NEW simulators...."
  # puts "NEW SIMS: #{$new_simulators_home}"
  # new_sims = list_sorted $new_simulators_home+"/*"
  # new_sims.each { |e| 
  #     display_device_info e 
  # }
  #     choice = choose("Favorite language?", :ruby, :perl, :js)
  #     puts "good choice == #{choice}"

    
  # command :bar do |c|
  #   c.syntax = 'foobar bar [options]'
  #   c.description = 'Display bar with optional prefix and suffix'
  #   c.option '--prefix STRING', String, 'Adds a prefix to bar'
  #   c.option '--suffix STRING', String, 'Adds a suffix to bar'
  #   c.action do |args, options|
  #     options.default :prefix => '(', :suffix => ')'
  #     say "#{options.prefix}bar#{options.suffix}"
  #   end

