pholders
========

Quick access to iOS Simulator folders to perform actions - open, clean / reset -- cache only, docs only, both, etc.

With Xcode6, the sandbox folder containing Documents, Preferences & Cache changes every time you deploy the App. This tool helps to quickly find and open a Finder window to that folder, so you can examine files and reset caches, etc.

[SimPholders 2](http://simpholders.com) is a great tool that runs on your Mac's status bar.

For users that prefer CLI/Terminal, **pholders** is the alternative to quickly open a Finder window on the folder for the last running App with a simple command.

Requirements
----

This tool is built with [Commander](https://github.com/tj/commander) and [CFPropertyList](https://github.com/ckruse/CFPropertyList)

```
sudo gem install commander cfpropertylist
```

Usage
----

```
$ ./pholders.rb --help
  NAME:
    pholders.rb

  DESCRIPTION:
    Finds iOS simulators folders and performs actions

  COMMANDS:
    help    Display global or [command] help documentation         
    list    List all simulators installations              
    open    Opens simulator folder were the last/current App was running   

  GLOBAL OPTIONS:
    --verbose        Prints debug informantion while running 
    -h, --help       Display help documentation
    -v, --version    Display version information
    -t, --trace      Display backtrace when an error occurs
```

To quickly open a Finder window to your App, just run:

```
$ ./pholders.rb open
------------
Open Simulator Folder
XCODE - xcode6
ARGS  - using default ["ipad"]
------------
NEW XCODE Simulators root path : /Users/rolima/Library/Developer/CoreSimulator/Devices

Opening Simulator with highest match for input arguments: ["ipad"]

iPad Simulator - iPad Retina (iOS-8-1)
! Could not pinpoint an specific App, so opening all Apps for this simulator, if possible... !

    BundleId....: com.mycompany.CoolApp
    SandBox Path: /Users/myUser/Library/Developer/CoreSimulator/Devices/123ABC-1111-2222-XXXX-ABCD/data/Containers/Data/Application/123ABC-1111-3333-XXXX-FFFF
$ 

$ --> Finder opens a new Window pointing to the directory above <--
```

**Open** also accepts arguments that will be used to find a better match when looping through all simulators.

This way, you could specify the following: 

- Open iPad 7 apps 
```
$ ./pholders.rb open ipad 7
```

- Open iPhone 8 apps 
```
$ ./pholders.rb open phone 8
```

- Open apps with specific **BundleId** 
```
$ ./pholders.rb open my.company
```


TODO
----

- ~~more options for launching the App~~
    + ~~iPhone only~~
    + ~~iPad only~~
- menu with all the Apps, so user can choose which one to open
- more actions
    + reset -- cache-only, documents-only, preferences-only, combination of all 3
    + uninstall App -- remove both Application and Sandbox folders






