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
default_command :list

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
        DebugUtils.result_line "\n#{v[:type]} Simulator - #{v[:name]} (#{v[:runtime]})"
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
    DebugUtils.output_line "XCODE - #{options.xcode}"
    if args == nil or args.count == 0
      args = ['ipad'] 
      DebugUtils.output_line "ARGS  - using default #{args}"
    else
      DebugUtils.output_line "ARGS  - #{args}"
    end
    DebugUtils.debug_line "OPTIONS  - #{options}"
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
        possible_matches = {}
        new_sims.each { |k,v| 
          DebugUtils.debug_line "examining #{v[:type]} Simulator - #{v[:name]} (#{v[:runtime]})"
          args.each { |a| 
            v.each { |vk,vv|
              DebugUtils.debug_line "examining ARGS #{a} = #{vk} => #{vv.class}"
              if vk != :apps and vk != :path and vv.kind_of? String and vv.downcase.index(a.downcase) != nil
                possible_matches[k] = PholdersUtils.update_count possible_matches, k, nil, nil

              #special handle Apps
              elsif vk == :apps and vv.kind_of? Hash and vv.keys.count > 0
                vv.each { |appK, appV| 
                  DebugUtils.debug_line "examining APPss #{a} => BundleId #{appK}"
                  if appK.downcase.index(a.downcase) != nil
                    sandbox = nil
                    sandbox = appV['compatibilityInfo']['sandboxPath'] if appV['compatibilityInfo']
                    possible_matches[k] = PholdersUtils.update_count possible_matches, k, appK, sandbox
                  end
                }
              end
            }
          } 
        }

        possible_matches = possible_matches.sort_by {|k,v| v[:count_so_far]}.reverse
        DebugUtils.debug_line "possible matches #{possible_matches}"

        DebugUtils.result_line "\nOpening Simulator with highest match for input arguments: #{args}"
        possible_matches.each { |match|
          # DebugUtils.debug_line "examining match #{match.class} #{match}"
          v = new_sims[match.first]
          DebugUtils.result_line "\n#{v[:type]} Simulator - #{v[:name]} (#{v[:runtime]})"
          # highest match does not have sandbox
          if match.last[:sandboxPath] == nil or not File.exist? match.last[:sandboxPath]
            if v[:apps].keys.count > 0
              open_at_least_one = false
              DebugUtils.error_line "Could not pinpoint an specific App, so opening all Apps for this simulator, if possible..."
              DebugUtils.debug_line "any apps ? #{v[:apps].keys} "
              v[:apps].each { |some_app_bundle, some_app_info|
                if some_app_info['compatibilityInfo'] and File.exist? some_app_info['compatibilityInfo']['sandboxPath']
                  DebugUtils.result_line "\n    BundleId....: #{some_app_bundle}"
                  DebugUtils.result_line "    SandBox Path: #{some_app_info['compatibilityInfo']['sandboxPath']}"
                  `open "#{some_app_info['compatibilityInfo']['sandboxPath']}"`
                  open_at_least_one = true
                end
              }
              break if open_at_least_one
            else
              DebugUtils.error_line "Sorry, could not find any app on this simulator. Trying the next one..."
            end
          else
            DebugUtils.result_line "    BundleId....: #{match.last[:bundleId]}"
            DebugUtils.result_line "    SandBox Path: #{match.last[:sandboxPath]}"
            `open "#{match.last[:sandboxPath]}"`
            break
          end
        }

      end #else no apps
    end #else xcode
  end #c.action
end #open command
