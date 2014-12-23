#!/usr/bin/env ruby
require 'cfpropertylist'

#
module PholdersUtils
    KRUNTIME_PREFIX = "com.apple.CoreSimulator.SimRuntime"
    KRUNTIME_PREFIX_LENGTH = KRUNTIME_PREFIX.length

    KCOM_APPLE_APPS_PREFIX = "com.apple."
    KCOM_APPLE_APPS_PREFIX_LENGTH = KCOM_APPLE_APPS_PREFIX.length

    KNEW_SIMULATORS_APPLICATIONSTATE_PLIST = "/data/Library/BackBoard/applicationState.plist"

    def PholdersUtils.list_sorted (folder)
        # puts "... LISTING #{folder}"
        files = Dir.glob(folder)
        # puts "1... #{files}"
        files = files.map { |file| [File.new(file).mtime, file] }
        # puts "2... #{files}"
        files = files.sort.map { |file| file[1] }
        # puts "3... #{files}"
        # puts "-------------"
        # files.each { |file| puts file }
        files
    end

    def PholdersUtils.display_device_info (device_folder)
        puts "... DEVICE Folder: #{device_folder}"
        plist = CFPropertyList::List.new(:file => device_folder+"/device.plist")
        device = CFPropertyList.native_types(plist.value)

        # which simulator
        runtime = device['runtime']
        runtime = runtime[KRUNTIME_PREFIX_LENGTH+1, runtime.length - KRUNTIME_PREFIX_LENGTH-1]
        puts "... Examining DEVICE: #{device["name"]} (#{runtime})"

        appState_plist = device_folder + KNEW_SIMULATORS_APPLICATIONSTATE_PLIST
        if File.exist?(appState_plist) then
            # any apps?
            plist = CFPropertyList::List.new(:file => appState_plist)
            appState = CFPropertyList.native_types(plist.value)
            myApps = appState.select { |k,v| not k.start_with? KCOM_APPLE_APPS_PREFIX  }

            puts "MY APPS:"
            myApps.each { |k,v| 
              puts "    BundleId: #{k}"
              puts "    SandBox Path: #{v['compatibilityInfo']['sandboxPath']}"
              puts "  ----"
            }
        else 
            puts "NO APPS!"
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