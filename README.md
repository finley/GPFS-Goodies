New and Improved! 

    Now supports FlashStorage as well as SMClient compatible storage!
    (v20.8.4 and newer)

 
Download

    http://snurl.com/gpfs_goodies_download


The "GPFS Goodies" package includes:

    brians_own_hot-add_script

        Hot delete any devices that don't have disk devices associated
        with them (stale LUNs), and hot-add any new devices.

    multipath.conf-creator

        Create and optionally deploy a multipath configuration
        appropriate for your LUNs and storage servers.

    gpfs_stanzafile-creator

        This script will auto-create a GPFS StanzaFile (written to
        STDOUT) that should be considered an example of how you can
        appropriately balance your disk devices across your NSD servers
        for best performance.  It may be used as-is in many cases.

    test_block_device_settings

        This program will summarize key block device settings that
        impact the performance when accessing your disk subsystems.  It
        makes no changes to your system, and is safe to run on live
        production systems.

    tune_block_device_settings
        
        This program will examine your environment including GPFS,
        storage servers, disk subsystems, and LUNs, to calculate best
        practice block device tuning settings.  It will create a single
        udev rules file with the tuning settings, using one entry for
        each LUN, and optionally deploy it to each participating storage
        server.


    Be sure to take a look at the HOWTO as well as other docs, examples,
    and half-baked goodies in:

        /usr/share/gpfs_goodies

 
Project Page

    https://github.com/finley/GPFS-Goodies

 
Contributions

    If you'd like to contribute, please send email to 
    Brian Finley <bfinley@lenovo.com>.

 
Example output from GPFS Goodies commands:

    gpfs_goodies

        [root@box ~]# gpfs_goodies
        
        gpfs_goodies v20.9.5
        
        Please try one of the following commands.  They're listed in the order
        of their typical use, from start to finish.  It's OK -- they're all
        safe, and won't do anything but show help information if run with either
        no arguments, or with --help or -h as an argument.
        
            brians_own_hot-add_script
        
                Hot delete any devices that don't have disk devices associated
                with them (stale LUNs), and hot-add any new devices.
        
            multipath.conf-creator
        
                Create and optionally deploy a multipath configuration
                appropriate for your LUNs and storage servers.
        
            gpfs_stanzafile-creator
        
                This script will auto-create a GPFS StanzaFile (written to
                STDOUT) that should be considered an example of how you can
                appropriately balance your disk devices across your NSD servers
                for best performance.  It may be used as-is in many cases.
        
            test_block_device_settings
        
                This program will summarize key block device settings that
                impact the performance when accessing your disk subsystems.  It
                makes no changes to your system, and is safe to run on live
                production systems.
        
            tune_block_device_settings
                
                This program will examine your environment including GPFS,
                storage servers, disk subsystems, and LUNs, to calculate best
                practice block device tuning settings.  It will create a single
                udev rules file with the tuning settings, using one entry for
                each LUN, and optionally deploy it to each participating storage
                server.
        
        
            Be sure to take a look at the HOWTO as well as other docs, examples,
            and half-baked goodies in:
        
                /usr/share/gpfs_goodies
        


    brians_own_hot-add_script

        brians_own_hot-add_script [--help|--version|--status|--yes]
        
            All options can be abbreviated to minimum uniqueness.
        
            This program will hot delete any devices that don't have disk
            devices associated with them (stale LUNs), and hot-add any new
            devices.
        
            --help
        
                Show this help output.
        
            --version
        
                Show this program's version number.
        
            --status
        
                Show the current LUN count, but don't actually do anything or
                make any changes.  This count will include all LUNs connected to
                the system, including local devices.
        
            --yes
        
                Hot delete any devices that don't have disk devices associated
                with them (stale LUNs), and hot-add any new devices.
        
                It's important to perform the hot-delete prior to the hot-add,
                as a disk that's no longer present may be still be considered as
                connected, and thus prevent detection of a new disk in that same
                position.
        
                The hot-delete function should be considered "safe", in that it
                won't remove the representation of any disk that is actually
                present and in use, but will only operate on disks that have
                already been removed.  If a disk has been re-located, it's stale 
                SCSI representation will be removed from it's old location and 
                then hot-added in it's new location.
        
                If it all in doubt, look at the code in this script, and make
                your own determination as to the impact of it's operation and/or
                try it in your test environment first.  
                
                You do have a test environment, right?
        
        
            Support: 
            
                This software is provided as-is, with no express or implied
                support.  However, the author would love to receive your
                patches.  Please contact Brian E. Finley <bfinley@us.ibm.com>
                with patches and/or suggestions.
        
        
        SUGGESTION:  Please specify either --status or --yes.
        

         
    multipath.conf-creator

        [root@box ~]# multipath.conf-creator
        
        multipath.conf-creator v20.9.5
        
            Part of the "gpfs_goodies" package
        
        Usage:  multipath.conf-creator [OPTION...] [--auto-detect | subsystem1 subsystem2...]
        
            Options can be abbreviated to minimum uniqueness.  For example, you 
            could use "-h" or "--h" instead of "--help".
        
            --help
        
            --version
        
            --auto-detect
        
                Highly recomended!
        
                This command will use the output from "SMcli -d" to determine the list
                of subsystems to use.  
                
                If you _don't_ specify this option, you'll need to specify a list of
                subsystems on the command line instead:
        
                  multipath.conf-creator subsystem1 subsystem2 etc...
        
        
            --deploy SERVER[,SERVER,...]
        
                Install the following files on each specified server:
                
                  - /etc/multipath.conf
                     The file generated by this tool.
                
                  - /etc/modprobe.d/scsi_dh_alua.conf
                     Reduce boot time when connected to multipath devices, and eliminate
                     some harmless, but noisy SCSI errors that may be displayed. 
                
                  - /var/mmfs/etc/nsddevices
                     Tells GPFS to use your new multipath devices as NSD disks (and to
                     not use any other devices).  Once installed, just run it as a
                     script to see which devices it's choosing.
                
        	I'll also re-build the initrd or initramfs to include your new
        	multipath.conf and scsi_dh_alua.conf files.
        
        
            --out-file FILE
        
                Where FILE is the name you want to use for your shiny new
                multipath.conf file.
        
                Default:  I'll choose one for you and tell you what I've named it.
        
                Example:  --out-file /tmp/multipath.conf.test_run
        
        
            --no-blacklist
        
                Don't blacklist any disks.  By default, this tool will create a
                multipath.conf file that blacklists the local disks.  
                
                Please verify before rebooting your nodes by running 
                'multipath -v3' and examining the output for blacklisted devices.
        
        
            Currently Supported Storage Controllers should include all IBM DS
            Storage Manager (SMClient) compatible subsystems and IBM FlashSystem
            storage.  Testing has been performed on the following models:
        
                FlashSystem 820     DS3860      DCS3700 
                DS3512              DS3524
        
        
            Support: 
            
                This software is provided as-is, with no express or implied
                support.  However, the author would love to receive your
                patches.  Please contact Brian E. Finley <bfinley@us.ibm.com>
                with patches and/or suggestions.
        
                To request support for an additional storage subsystem, please
                email the output from 'lsscsi' to <bfinley@us.ibm.com>.  Emails
                that have an actual storage subsystem attached (or at least
                remote access to one) are likely to get the most attention. ;-)
        
        
        
        -->  Please run as root
        
 
 
    gpfs_stanzafile-creator

        gpfs_stanzafile-creator v20.9.5
        
            Part of the "gpfs_goodies" package
        
        Description:
        
            gpfs_stanzafile-creator will auto-create a GPFS StanzaFile that will appropriately
            balance NSD device access across your NSD servers for best
            performance.  
            
            The resultant StanzaFile can be used as-is with the mmcrnsd command,
            and should provide balanced NSD device access from clients (good
            performance) if the following assumptions are true:
        
                That each group of NSD servers specified with each
                --server-group argument:
                   
                a) have access to all of the same shared disk devices
        
                b) have been prepared for multipath use with the GPFS Goodies
                   multipath.conf-creator tool
        
            If the assumptions above are not true for your environment, you may
            need to hand edit the StanzaFile before use.  If you find you need
            to do this, please email the author(s) with before and after copies
            of your StanzaFile, and any other relevant details, and we will try
            to improve the tool to handle your situation in a future release.
            
            If you are satisfied with the StanzaFile you've created, you can use
            mmcrnsd to initialize the disks (see "man mmcrnsd" for more details):
        
                mmcrnsd -F GPFS_Goodies.StanzaFile
        
            Have fun!  -Brian Finley
        
        
        Usage:  gpfs_stanzafile-creator [OPTION...] --servers SERVER[,SERVER,...]
        
            Options can be abbreviated to minimum uniqueness.  For example, you 
            could use "-h" or "--h" instead of "--help".
        
            --help
        
            --version
        
            -sg, --server-group SERVER[,SERVER,...]
        
                A comma delimited list of servers that are all connected to the
                same multi-pathed disk subsystem(s) (a building block).  Make
                sure that you use the names of the servers as they appear in the
                'Admin node name' column of the output from the 'mmlscluster'
                command.
        
                May be specified multiple times if you have multiple building
                blocks.
        
                Example:  --sg nsd1,nsd2 --sg nsd3,nsd4 --sg nsd5,nsd6
                     or:  --server-group s1,s2,s3 --server-group s4,s5,s6
        
        
            --paths N
                
                Number of paths each server has to each disk.  
                
                For example, if each server has 2x cables connected to each disk
                subsystem, then you would specify 2.  
        
                Default:  2
        
        
            --out-file FILE
        
                Where FILE is the name you want to use for your shiny new
                multipath.conf file.
        
                Default:  I'll choose one for you and tell you what I've named it.
        
                Example:  --out-file /tmp/gpfs_stanzafile-creator.StanzaFile
        
        
            Support: 
            
                This software is provided as-is, with no express or implied
                support.  However, the author would love to receive your
                patches.  Please contact Brian E. Finley <bfinley@us.ibm.com>
                with patches and/or suggestions.
        
                To request support for an additional storage subsystem, please
                email the output from 'lsscsi' to <bfinley@us.ibm.com>.  Emails
                that have an actual storage subsystem attached (or at least
                remote access to one) are likely to get the most attention. ;-)
        
        
        --> Please try --server-group
        
        

    test_block_device_settings

        test_block_device_settings v20.5
        
            Part of the "gpfs_goodies" package
        
        
        This program will summarize key block device settings that impact the
        performance when accessing your disk subsystems.  It makes no changes to
        your system, and is safe to run on live production systems.
        
        Usage:  test_block_device_settings [OPTION...]
        
            All options can be abbreviated to minimum uniqueness.
        
            --help
        
                Show this help output.
        
            --version
        
                Yup.  These are the only two options. ;-)
        
            --test
        
                Perform the test.  This should be considered a safe action.
        
        
            Support: 
            
                This software is provided as-is, with no express or implied
                support.  However, the author would love to receive your
                patches.  Please contact Brian E. Finley <bfinley@us.ibm.com>
                with patches and/or suggestions.
        
        
        
        -->  Please run as root
        


    tune_block_device_settings

        tune_block_device_settings v20.9.5
        
            Part of the "gpfs_goodies" package
        
        Usage:  tune_block_device_settings --filesystem FSNAME [OPTION...]
        
            tune_block_device_settings should be considered BETA code at this point.  
                   
            All options can be abbreviated to minimum uniqueness.
        
            This program will examine your environment including GPFS, storage
            servers, disk subsystems, and LUNs, to calculate best practice block
            device tuning settings.  It will create one udev rules file per file
            system with the new tuning settings, using one entry for each LUN,
            and optionally deploy it to each participating storage server.
        
            This tool is intended to be run with GPFS 'active' on all the NSD
            servers serving your specified file system.
        
            Note that it will skip over and ignore any GSS file systems.  GSS block
            device settings are tuned directly by the GSS software stack.
            
            --help
        
            --version
        
            --filesystem FSNAME
        
                Where FSNAME is the name of the file system whose block devices
                should be tuned.
        
        
            --disks-per-array (NN|NN:POOLNAME,[...])
        
                Where NN is the number of disks in each array.  
                
                Often, each LUN presented to the OS represents one RAID array in
                the storage subsystem.  Here are some examples by array type:
        
                  Value for NN    Array Type
                  ------------    --------------------------------------------
                       8          8+2p RAID6        (8 data + 2 parity disks)
                       8          8+3p Reed Solomon (8 data + 3 parity disks)
                       4          4+1p RAID5        (4 data + 1 parity disk)
                       1          1+1m RAID1        (1 data + 1 mirrored disk)
        
                Hint #1:  If all of your disks are in the same kind of array
                (e.g.: RAID6 with 8 data disks + 2 parity disks), then you can
                simply use the "NN" format, even if you have multiple file
                systems and multiple pools.
        
                Hint #2:  If you don't know what all this "pool" stuff is about,
                then you probably only have one pool (the "system" pool).  Try
                "mmlspool FSNAME" to have a look if you're curious.
        
                NN - If only "NN" is specified, then it is assumed that NN
                represents the number of disks per array across all file systems
                and living on all pools served by "--servers" (or you only have
                one pool per file system).
        
                NN:POOLNAME - The number of disks (NN) per array across all
                arrays in pool POOLNAME that are part of file system FSNAME.
        
                Examples:
        
                    --disks-per-array 8
                    --disks-per-array 4:system,8:tier2
        
                Default: 8
        
        
            --test
        
                Create the rules, but don't deploy them.  This is the default
                action if --deploy is not specified.
        
        
            --deploy
        
                Deploy and activate the resultant udev rules file to each
                participating storage server.  Participating storage servers are
                identified by their role as an NSD server for any of the LUNs in
                active file systems.  Execute the command "mmlsnsd" for a list
                of these servers.
                
                The name of the udev rules file on the target NSD servers will
                be: /etc/udev/rules.d/99-gpfs_goodies-FSNAME.rules
        
        
            --out-file FILE
        
                The name of your resultant udev rules file.  This file can be
                given any name you like.  
        
                If you also use the --deploy option, this file will still be 
                deployed to your storage servers with the name of:
                
                    /etc/udev/rules.d/99-gpfs_goodies-FSNAME.rules
        
                Example:  --out-file /tmp/my_shiny_new_udev_rules_file.conf
        
                Default:  I'll choose one for you and tell you what I've named
                it.
        
        
            Support: 
            
                This software is provided as-is, with no express or implied
                support.  However, the author would love to receive your
                patches.  Please contact Brian E. Finley <bfinley@us.ibm.com>
                with patches and/or suggestions.
        
        
        -->  Try "--filesystem FSNAME"
        

