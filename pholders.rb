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
        DebugUtils.result_line "\niPad/iPhone Simulator - #{v[:name]}"
        DebugUtils.result_line "  Path - #{v[:path]}"
      }
      DebugUtils.output_line "===\n"
    end

    # NEW simulators
    if options.xcode == :xcode6 or options.xcode == :both
      DebugUtils.output_line "NEW XCODE Simulators root path : #{$new_simulators_home}"
      new_sims = PholdersUtils.new_simulators $new_simulators_home+"/*", options.includeEmpty      
      new_sims.each { |k,v| 
        DebugUtils.result_line "\n#{v[:type]} Simulator - #{v[:name]}"
        DebugUtils.result_line "  Path - #{v[:path]}"
        if v[:apps].keys.count > 0
          DebugUtils.result_line "  Apps:" 
          v[:apps].each { |ka,va|
            DebugUtils.result_line "    BundleId: #{ka}"
            DebugUtils.result_line "    SandBox Path: #{va['compatibilityInfo']['sandboxPath']}" if (va['compatibilityInfo'])
          }
        else 
          DebugUtils.result_line "  NO Apps"
        end
      }
      DebugUtils.output_line "===\n"
    end
  end #c.action
end #list command

command :open do |c|
  c.syntax = 'pholders open [options]'
  c.description = 'Opens simulator folder were the last/current App was running'
  c.option '--xcode [XCODE_TYPE]', [:xcode5, :xcode6], 'Which Xcode simulator to open: xcode5, xcode6?'
  c.action do |args, options|
    options.default :xcode => :xcode6

    puts "------------"
    DebugUtils.output_line "Open Simulator Folder"
    DebugUtils.output_line "  - #{options.xcode}"
    puts "------------\n"

    # OLD simulators
    if options.xcode == :xcode5
      DebugUtils.output_line "OLD XCODE Simulators root path : #{$old_simulators_home}"
      old_sims = PholdersUtils.old_simulators $old_simulators_home+"/*"
      if old_sims == nil or old_sims.keys.count == 0
        if File.exist? $old_simulators_home
          DebugUtils.result_line "Sorry, could not find any Xcode 5 Apps. Opening the root folder instead."
          `open "#{$old_simulators_home}"`
        else
          DebugUtils.result_line "Sorry, could not find any Xcode 5 Apps or Folder"
        end
      else
        sim = old_sims[old_sims.keys.last]
        DebugUtils.result_line "\niPad/iPhone Simulator - #{sim[:name]}"
        DebugUtils.result_line "  Path - #{sim[:path]}"
        `open "#{sim[:path]}/#{$old_simulators_apps}"`
      end # else

    # NEW simulators
    else
      DebugUtils.output_line "NEW XCODE Simulators root path : #{$new_simulators_home}"
      new_sims = PholdersUtils.new_simulators $new_simulators_home+"/*", false
      if new_sims == nil or new_sims.keys.count == 0
        DebugUtils.result_line "Sorry, could not find any Xcode 6 Apps. Opening the root folder instead."
        `open "#{$new_simulators_home}"`
      else
        sim = new_sims[new_sims.keys.last]
        apps = sim[:apps]
        last_app = apps[apps.keys.last]
        DebugUtils.result_line "\n#{sim[:type]} Simulator - #{sim[:name]}"
        DebugUtils.result_line "  Last App:"
        DebugUtils.result_line "    BundleId: #{apps.keys.last}"
        if last_app['compatibilityInfo']
          DebugUtils.result_line "    SandBox Path: #{last_app['compatibilityInfo']['sandboxPath']}"
          `open "#{last_app['compatibilityInfo']['sandboxPath']}"`
        else
          DebugUtils.result_line "    Sorry, cannot open this App - no sandbox folder found"
        end

      end #else no apps
    end #else xcode
  end #c.action
end #open command
