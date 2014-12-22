#!/usr/bin/env ruby
require 'cfpropertylist'

#
$Kruntime_prefix = "com.apple.CoreSimulator.SimRuntime"
$Kruntime_prefix_length = $Kruntime_prefix.length

$Kcom_apple_Apps_prefix = "com.apple."
$Kcom_apple_Apps_prefix_length = $Kcom_apple_Apps_prefix.length


$user_home = Dir.home
# OLD
$old_simulators_home = $user_home + "/Library/Application Support/iPhone Simulator"
$old_simulators_apps = "/Applications"
# NEW
$new_simulators_home = $user_home + "/Library/Developer/CoreSimulator/Devices"
$new_simulators_applicationState_plist = "/data/Library/BackBoard/applicationState.plist"
$new_simulators_apps = "/data/Containers/Data/Application"

def list_sorted (folder)
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

def display_device_info (device_folder)
    puts "... DEVICE Folder: #{device_folder}"
    plist = CFPropertyList::List.new(:file => device_folder+"/device.plist")
    device = CFPropertyList.native_types(plist.value)

    # which simulator
    runtime = device['runtime']
    runtime = runtime[$Kruntime_prefix_length+1, runtime.length - $Kruntime_prefix_length-1]
    puts "... Examining DEVICE: #{device["name"]} (#{runtime})"

    appState_plist = device_folder+$new_simulators_applicationState_plist
    if File.exist?(appState_plist) then
        # any apps?
        plist = CFPropertyList::List.new(:file => appState_plist)
        appState = CFPropertyList.native_types(plist.value)
        myApps = appState.select { |k,v| not k.start_with? $Kcom_apple_Apps_prefix  }

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

# Dir.foreach(".") {|x| puts "Got #{x}" }
puts "\n======================"
puts "found OLD simulators...."
puts "OLD SIMS: #{$old_simulators_home}"
old_sims = list_sorted $old_simulators_home+"/*"

puts " ---- "
old_sims.each { |e| list_sorted e+$old_simulators_apps+"/*" }
puts " ---- "

puts "\n\n======================"
puts "\n======================"
puts "\nfound NEW simulators...."
puts "NEW SIMS: #{$new_simulators_home}"
new_sims = list_sorted $new_simulators_home+"/*"
new_sims.each { |e| 
    display_device_info e 
}

puts "\n======================"
puts "end"
