#!/usr/bin/env ruby

require 'rubygems'
require 'commander/import'
require_relative 'debugUtils.rb'
require_relative 'pholdersUtils.rb'

# -------------------------------------------------------------
# global stuff here
$user_home = Dir.home
# OLD
$old_simulators_home = $user_home + "/Library/Application Support/iPhone Simulator"
$old_simulators_apps = "/Applications"
# NEW
$new_simulators_home = $user_home + "/Library/Developer/CoreSimulator/Devices"
$new_simulators_apps = "/data/Containers/Data/Application"

# -------------------------------------------------------------
program :version, '0.0.1'
program :description, 'Finds iOS simulators folders and performs actions'

global_option('--verbose') { $verbose = true }

command :list do |c|
  c.syntax = 'pholders list [options]'
  c.description = 'List all simulators installations'
  c.option '--xcode [XCODE_TYPE]', [:xcode5, :xcode6, :both], 'Which Xcode simulators to find: xcode5, xcode6 or both?'
  c.option '--includeEmpty', 'Includes simulators with no apps'
  c.action do |args, options|
    options.default :xcode => :both

    puts "------------"
    DebugUtils.output_line "Listing Simulator Folders"
    DebugUtils.output_line "  - #{options.xcode}"
    DebugUtils.output_line "  - Including empty simulators" if options.includeEmpty
    DebugUtils.output_line "  - Only simulator with apps" if not options.includeEmpty
    puts "------------\n"

    # OLD simulators
    if options.xcode == :xcode5 or options.xcode == :both
      DebugUtils.output_line "OLD XCODE Simulators root path : #{$old_simulators_home}"
      old_sims = PholdersUtils.old_simulators $old_simulators_home+"/*"
      old_sims.each { |k,v|
        DebugUtils.result_line "iPad/iPhone Simulator - #{v[:name]}"
        DebugUtils.result_line "  Path - #{v[:path]}"
      }
      DebugUtils.output_line "===\n"
    end

    # NEW simulators
    if options.xcode == :xcode6 or options.xcode == :both
      DebugUtils.output_line "NEW XCODE Simulators root path : #{$new_simulators_home}"
      new_sims = PholdersUtils.list_sorted $new_simulators_home+"/*"      
      new_sims.each { |e| 
        PholdersUtils.display_device_info e 
      }
      DebugUtils.output_line "===\n"
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

