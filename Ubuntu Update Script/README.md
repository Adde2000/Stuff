# Ubuntu update script [^1]

 1. Open a terminal on your Ubuntu 18.04 LTS system. We will be creating a Bash script, so enter the following command into the terminal to create the script file:

*nano update.sh*

 2. The nano text editor will open. The first step to creating the update script is to add the ‘shebang’ at the top of the file. The ‘shebang’ is simply the path to the program that will execute the script. In this case, Bash will be used. Add the following text to the top of the script file:

`#!/bin/bash`

 3. Before getting in to the nuts and bolts of the update script, a function will be added that will check the exit status of each command. This function will alert the user if an error occurs at any step in the process. If an error occurs, the user will have the option to exit the script and resolve the issue, or continue on with the script. Add the following function to the update script beneath the ‘shebang’:
```
check_exit_status() {

    if [ $? -eq 0 ]
    then
        echo
        echo "Success"
        echo
    else
        echo
        echo "[ERROR] Process Failed!"
        echo
		
        read -p "The last command exited with an error. Exit script? (yes/no) " answer

        if [ "$answer" == "yes" ]
        then
            exit 1
        fi
    fi
}
```
 4. Now a simple greeting will be added. When the script is executed, a greeting will be displayed along with the logged-in user’s name. Add the following function to the update script:
```
greeting() {

    echo
    echo "Hello, $USER. Let's update this system."
    echo
}
```
 5. Next, the updating portion of the script is added. Add the following function to the update script:
```
update() {

    sudo apt-get update;
    check_exit_status

    sudo apt-get upgrade -y;
    check_exit_status

    sudo apt-get dist-upgrade -y;
    check_exit_status
}
```
 6. Finally, the housekeeping function is added to the script. This function will perform the maintenance and clean-up duties needed to keep the Ubuntu 18.04 system running optimally. Add the following to the update script:
```
housekeeping() {

    sudo apt-get autoremove -y;
    check_exit_status

    sudo apt-get autoclean -y;
    check_exit_status

    sudo updatedb;
    check_exit_status
}
```
 7. With the heavy lifting complete, the exit function is added to the script. The exit function will exit the script gracefully while notifying the user that the script has completed. Add the following function to the update script:
```
leave() {

    echo
    echo "--------------------"
    echo "- Update Complete! -"
    echo "--------------------"
    echo
    exit
}
```
 8. All that is left is to call our functions in the order that they are to be executed. Add the following to the end of the update script to call the functions in the correct order:
```
greeting
update
housekeeping
leave
```
 9. Now the script can be saved and closed. To save the file enter CTRL + o, press Enter to keep the filename, and then enter CTRL + x to close the file. The script is not yet executable by the system because execute permissions have not yet been added to the script. To make the script executable, enter the following into the terminal:

*chmod a+x update.sh*

 10. To verify that the update script has executable permissions, enter the following command into the terminal. The script name should appear green as in the image below.

*ls -lah update.sh*

 11. Now the script can be tested. To test the update script, enter the following into the terminal:

*sudo ./update.sh*

12. After entering the sudo password for the system, the script should execute without error. 

 13. With verification that the script executes flawlessly, a bin directory will now be added to the home directory of the system. Enter the following command to create the directory:

*mkdir ~/bin*

 14. Now the update script can be moved into the new bin directory and renamed as a normal command. Enter the following command into the terminal to move the update script to the bin directory and rename the script to ‘up’:

*mv update.sh ~/bin/up*

 15. To verify the move and rename was successful, enter the following command into the terminal. You should she the ‘up’ script displayed as in the image below.

*ls ~/bin*

 16. To make the script executable from the command line like any other command, the new bin directory must be added to the search path. To add the new bin directory to the search path, enter the following command into the terminal:

*export PATH=~/bin:$PATH*

 17. Finally, the .bashrc file needs to be source to enable the path changes. Enter the following command to source the .bashrc file:

*source ~/.bashrc*

18. After sourcing the .bashrc file, we can now call our script by name from anywhere on our system. Simply enter ‘up’ into the command line to execute the update script! 


[^1]: Source https://github.com/VirtualZero/up