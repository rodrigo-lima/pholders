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

    def PholdersUtils.display_device_info (device_folder, include_all_sims)
        plist = CFPropertyList::List.new(:file => device_folder+"/device.plist")
        device = CFPropertyList.native_types(plist.value)

        # which simulator
        runtime = device['runtime']
        runtime = runtime[KRUNTIME_PREFIX_LENGTH+1, runtime.length - KRUNTIME_PREFIX_LENGTH-1]
        DebugUtils.debug_line "... Examining DEVICE: #{device["name"]} (#{runtime})"
        DebugUtils.debug_line "... DEVICE Folder: #{device_folder}"

        sym_type = device['name'].index('iPhone') != nil ? "iPhone" : "iPad"

        sym_apps = {}
        appState_plist = device_folder + KNEW_SIMULATORS_APPLICATIONSTATE_PLIST
        if File.exist?(appState_plist) then
            # DebugUtils.debug_line appState_plist
            # any apps?
            plist = CFPropertyList::List.new(:file => appState_plist)
            appState = CFPropertyList.native_types(plist.value)
            myApps = appState.select { |k,v| not k.start_with? KCOM_APPLE_APPS_PREFIX }

            DebugUtils.debug_line "MY APPS:"
            myApps.each { |k,v| 
              DebugUtils.debug_line "      BundleId: #{k}"
              DebugUtils.debug_line "      SandBox Path: #{v['compatibilityInfo']['sandboxPath']}" if (v['compatibilityInfo'])
              DebugUtils.debug_line "  ----"
              sym_apps[k] = v
            }
        else 
            DebugUtils.debug_line "NO APPS!"
            return nil,nil if not include_all_sims
        end

        return device_folder, { :name => device['name'],
                         :type => sym_type,
                         :path => device_folder,
                         :apps => sym_apps }
    end

    # ----------------------------------------------------------
    def PholdersUtils.old_simulators (folder)
        all_sims = PholdersUtils.list_sorted folder
        old_sims = {}
        all_sims.each { |alls| 
            last_path_component = alls.split('/').last
            DebugUtils.debug_line "alls = #{alls} -- #{last_path_component}"
            if KOLD_SIMULATORS_FOLDERS.index(last_path_component) == nil 
                old_sims[alls] = {
                    :name => last_path_component,
                    :path => alls
                    }
                DebugUtils.debug_line "old_sims[#{alls}] = #{old_sims[alls]}"
            end
        }
        old_sims
    end

    def PholdersUtils.new_simulators (folder, include_all_sims)
        all_sims = PholdersUtils.list_sorted folder
        new_sims = {}
        all_sims.each { |e| 
            k,v = PholdersUtils.display_device_info e, include_all_sims
            DebugUtils.debug_line "sym info #{k} = #{v}"
            new_sims[k] = v if k and v
        }
        new_sims
    end

end
