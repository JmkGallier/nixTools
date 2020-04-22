# Linux Tools
### Purpose 
To increase productivity on Linux systems and limit system and productivity downtime, I have created light bash 
scripts which automate much of the repetitive tasks experienced system-to-system.

### Tools
#### Fresh Start
The purpose of this tool is to automate package installation and system configuration.

#### How to use
Currently, these scripts are made to be downloaded and made executable with:
```bash
chmod +x nixTool.sh
```

The script can be called with various options which will affect operations performed on the system.
If you are running nixTool on a VM, make sure to set the "guest" flag with:
```bash
./nixtool -v host
```

#### To Do:
###### Milestones/"Features"
* [ ] Implement 'Dialog' CLI Interface & user selection of packages
* [x] Apply switch/case handle for 'Script State' 
* [x] Options

###### Security
* [ ] Link handling on JBToolBox and prep_VBox
* [ ] Isolate user escalation events

###### Due Diligence
* [ ] Check for fix necessity (pre-applied or not required)
* [ ] Explicit file/dir permission
* [ ] Implement script-called exits

###### Weekly Fix Update
* [ ] Intel Screen tearing fix on 19.10 systems
* [ ] Echo on ubuntu (18.04, 19.10)