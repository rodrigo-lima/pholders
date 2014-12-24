#!/usr/bin/env ruby
require 'cfpropertylist'

module PholdersUtils
    KRUNTIME_PREFIX = "com.apple.CoreSimulator.SimRuntime"
    KRUNTIME_PREFIX_LENGTH = KRUNTIME_PREFIX.length

    KCOM_APPLE_APPS_PREFIX = "com.apple."
    KOLD_SIMULATORS_FOLDERS = ["User","Library"]
    KNEW_SIMULATORS_APPLICATIONSTATE_PLIST = "/data/Library/BackBoard/applicationState.plist"

    def PholdersUtils.list_sorted (folder)
        files = Dir.glob(folder)
        #sort based on last modified
        files = files.map { |file| [File.new(file).mtime, file] }
        files = files.sort.map { |file| file[1] }
        files
    end

    def PholdersUtils.old_simulators (folder)
        all_sims = PholdersUtils.list_sorted folder
        old_sims = {}
        all_sims.each { |alls| 
            last_path_component = alls.split('/').last
            DebugUtils.debug_line "alls = #{alls} -- #{last_path_component}" if $verbose
            if KOLD_SIMULATORS_FOLDERS.index(last_path_component) == nil 
                old_sims[alls] = {
                    :name => last_path_component,
                    :path => alls
                    }
                DebugUtils.debug_line "old_sims[#{alls}] = #{old_sims[alls]}"  if $verbose
            end
        }
        old_sims
    end

    def PholdersUtils.display_device_info (device_folder)
        plist = CFPropertyList::List.new(:file => device_folder+"/device.plist")
        device = CFPropertyList.native_types(plist.value)

        # which simulator
        runtime = device['runtime']
        runtime = runtime[KRUNTIME_PREFIX_LENGTH+1, runtime.length - KRUNTIME_PREFIX_LENGTH-1]
        DebugUtils.debug_line "... Examining DEVICE: #{device["name"]} (#{runtime})"
        DebugUtils.debug_line "... DEVICE Folder: #{device_folder}"

        appState_plist = device_folder + KNEW_SIMULATORS_APPLICATIONSTATE_PLIST
        if File.exist?(appState_plist) then
            # DebugUtils.debug_line appState_plist
            # any apps?
            plist = CFPropertyList::List.new(:file => appState_plist)
            appState = CFPropertyList.native_types(plist.value)
            myApps = appState.select { |k,v| not k.start_with? KCOM_APPLE_APPS_PREFIX  }

            DebugUtils.debug_line "MY APPS:"
            myApps.each { |k,v| 
              DebugUtils.debug_line "      BundleId: #{k}"
              DebugUtils.debug_line "      SandBox Path: #{v['compatibilityInfo']['sandboxPath']}" if (v['compatibilityInfo'])
              DebugUtils.debug_line "  ----"
            }
        else 
            DebugUtils.debug_line "NO APPS!"
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

# puts "\n======================"
# puts "end"
