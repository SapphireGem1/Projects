#!/bin/bash

#Name: Sapir Segev,
#Class code: 7736/13
#Lecturer's name: Adonis Azzam


#checking to see if the user is root

if [ $(id -u) -ne 0 ]
	then
    echo "This script must be ran as root"
		exit 
fi

#allow the user to specify a file name and check if the file exists

echo "Enter the full file path" 

		read path


if [ -f $path ]
	then
        echo "The file exists"
	else
        echo "the file does not exist"
        exit
fi

#checking to see if the following applications are installed, and if not, install them: bulk extractor, binwalk, foremost, strings, volatility

function checkinstall () {
	echo "checking if the following application is installed: bulk extractor"
	sleep 2
	bulkcheck=$(dpkg -s bulk-extractor>/dev/null)
	
	if [[ ! -z $bulkcheck ]]
	then
	
		echo "bulk-extractor is not installed, installing"
		apt-get install bulk-extractor -y
	
	else
		echo "bulk-extractor is already installed"
	fi
	
	echo "checking if the following application is installed: binwalk"
	sleep 2
	bincheck=$(dpkg -s binwalk>/dev/null)
	
if [[ ! -z $bincheck ]]

	then
	
		echo "binwalk is not installed, installing"
		apt-get install binwalk -y
		
	else
		echo "binwalk is already installed"
fi
	
	echo "checking if the following application is installed: foremost"
	sleep 2
	forecheck=$(dpkg -s foremost>/dev/null)
	
	if [[ ! -z $forecheck ]]
	then
	
		echo "foremost is not installed, installing"
		apt-get install foremost -y
		
	else 
		echo "foremost is already installed"
fi
	
	echo "checking if the following application is installed: strings"
	sleep 2
	stringscheck=$(dpkg -s binutils>/dev/null)
	
	if [[ ! -z $stringscheck ]]
	then
		
		echo "strings is not installed, installing"
		apt-get install binutils -y
	
	else echo "strings is already installed"
fi
	
	echo "checking if the following application is installed: volatility"
	sleep 2 
			
	
	if [[ ! -d volatility_2.6_lin64_standalone ]]
	then
		
		echo "volatility is not installed, installing"
		wget http://downloads.volatilityfoundation.org/releases/2.6/volatility_2.6_lin64_standalone.zip 2>/dev/null
		unzip volatility_2.6_lin64_standalone.zip
		rm -rf volatility_2.6_lin64_standalone.zip
		chmod 777 volatility_2.6_lin64_standalone
	else
		echo "volatility is already installed"
fi
}



#If the file type is .mem, then use this function to carve its contents.

function mem () {

if [ ! -d Memory ]
	then mkdir Memory
fi
	
	echo "carving with Foremost.."
	foremost $path -o Memory/Foremost>/dev/null
	chmod 777 Memory/Foremost
	sleep 4
	
	echo "carving with Bulk extractor.."
	bulk_extractor $path -o Memory/Bulk-extractor>/dev/null
	

#If there are pcap files, show the user their location and their size.

if [ -f Memory/Bulk-extractor/*.pcap ]
	then
	for i in $(find Memory/Bulk-extractor -name *.pcap); do echo "Found pcap files" && echo $i && ls -lh $i | awk '{print "pcap file size: " $5}';done
	else echo "No pcap file found"
	sleep 4
fi


if [ ! -d Memory/Binwalk ]
	then mkdir Memory/Binwalk
fi

	echo "carving with Binwalk.."
	binwalk $path > Memory/Binwalk/results.txt

if [ ! -d Memory/Strings ]
	then mkdir Memory/Strings
fi
	
#Using strings, check for human-readable text, and save it as a file into a directory

	echo "carving with Strings.."
	strings $path | grep '.exe' >> Memory/Strings/results.txt
	strings $path | grep -i 'user' >> Memory/Strings/results.txt
	strings $path | grep -i 'password' >> Memory/Strings/results.txt
	
	echo "all successful carving attempts are stored in directories 'data', 'binwalk' and 'strings'"
}


#If the file type is hdd, then use this function to carve its contents.

function hdd () {
	
if [ ! -d Hard-Disk ]
	then mkdir Hard-Disk

fi
	echo "carving with Foremost.."
	foremost $path -o Hard-Disk/Foremost>/dev/null
	chmod 777 Hard-Disk/Foremost
	sleep 4
	echo "carving with Bulk extractor.."
	bulk_extractor $path -o Hard-Disk/Bulk-extractor>/dev/null
	sleep 4
	
if [ ! -d Hard-Disk/Binwalk ]
	then mkdir Hard-Disk/Binwalk
fi
	echo "carving with Binwalk.."
	binwalk $path > Hard-Disk/Binwalk/results.txt
	
if [ ! -d Hard-Disk/Strings ]
	then mkdir Hard-Disk/Strings
fi
	
	echo "carving with Strings.."
	strings $path | grep '.exe' >> Hard-Disk/Strings/results.txt
	strings $path | grep -i 'user' >> Hard-Disk/Strings/results.txt
	strings $path | grep -i 'password' >> Hard-Disk/Strings/results.txt
	
	echo "all successful carving attempts are stored in directories 'Foremost', 'Bulk-extractor', 'Binwalk', and 'Strings'"
}

#Query about file type and, based on user input, use the corresponding function.

function op () {
	
	echo "please choose an option:
			1. Memory file
			2. Hard disk drive"
	
	read ans
	
if [ $ans -eq 1 ]
	then mem
elif [ $ans -eq 2 ]
	then hdd
else
	echo "please choose 1 or 2"
	op
fi
}





function vol () {
#using volatility to find the memory file's suggested profile, and save it as a variable
var=$(./volatility_2.6_lin64_standalone/volatility_2.6_lin64_standalone -f $path imageinfo | grep -i "suggested profile" | awk '{print $4}' | sed 's/,//g')

#volatility commands to extract running processes, network connections and registry information

./volatility_2.6_lin64_standalone/volatility_2.6_lin64_standalone -f $path --profile=$var pstree >> run.txt
./volatility_2.6_lin64_standalone/volatility_2.6_lin64_standalone -f $path --profile=$var netscan >> net.txt
./volatility_2.6_lin64_standalone/volatility_2.6_lin64_standalone -f $path --profile=$var userassist >> reg.txt
}

#Display general statistics - time of analysis, number of files found

echo -e "$(date)"

function report () {
if [ $ans -eq 1 ]
	then echo -e "Number of files found during carving - $(ls -l Memory/Bulk-extractor Memory/Foremost Memory/Binwalk Memory/Strings | wc -l)"
		echo -e "Results for forensic analysis for the file in path: [$path]" >> report.txt
		echo -e "Number of files found during carving - $(ls -l Memory/Bulk-extractor Memory/Foremost Memory/Binwalk Memory/Strings | wc -l)" >> report.txt
		zip -r forensic-analysis-report Memory report.txt > /dev/null

elif [ $ans -eq 2 ]
	then echo -e "Number of files found during carving - $(ls -l Hard-Disk/Bulk-extractor Hard-Disk/Foremost Hard-Disk/Binwalk Hard-Disk/Strings | wc -l)"
	echo -e "Results for forensic analysis for the file in path: [$path]" >> report.txt
	echo -e "Number of files found during carving - $(ls -l Hard-Disk/Bulk-extractor Hard-Disk/Foremost Hard-Disk/Binwalk Hard-Disk/Strings | wc -l)" >> report.txt
	zip -r forensic-analysis-report Hard-Disk report.txt > /dev/null
	
fi
}

#The order in which the functions are executed

checkinstall
op
vol
report

echo "Forensic analysis complete. All files were saved to [forensic-analysis-report.zip]"

	
	

