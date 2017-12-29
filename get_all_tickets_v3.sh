#!/bin/bash

#For the script to work, these fields need to be entered 
#e.g, where USER_NAME enter user email, etc.

_user=USER_NAME
_userPassword=USER_PASSWORD
_domain=ZENDESK_DOMAIN

#Make a data file if one doesn't exist

echo "|_ _|  _ \| ____/ _ \  | | | |"
echo " | || | | |  _|| | | | | | | |"
echo " | || |_| | |__| |_| | | |_| |"
echo "|___|____/|_____\___/   \___/ "

#Create new folder if it doesn't exist to store the data
mkdir ./Data

echo "Enter the date (yyyy-mm-dd): "

read ddate

echo "Enter number of requests you'd like to make to Zendesk"
echo "********"
echo "-- Each request returns 100 tickets --"
echo "********"
echo "If it's January choose 3 (start of the year)" 
echo "If it's December choose 50 (end of the year)"
echo "********"
echo "How many request?"

read numtimes

for i in `eval echo {1..$numtimes}`; do
            

	curl https://$_domain/api/v2/tickets.json?page=${i} \
	  -v -u $_user:$_userPassword >> all_tickets_${ddate}.txt

	#Make JSON pretty for Tableau
	cat all_tickets_${ddate}.txt | python -m json.tool > Data/all_tickets_${ddate}_Request_${i}.json


	#Remove the original (useless text file)
	rm -rf all_tickets_${ddate}.txt

done


#Adding to make valid JSON before loop
echo "{"  >> Data/all_tickets_${ddate}_COMB.json

#Second for loop that concatinates files
for i in `eval echo {1..$numtimes}`; do 

#Adding to make valid JSON
echo "\"Request_${i}\": ["  >> Data/all_tickets_${ddate}_COMB.json

#Combined all previous files into one data file
cat Data/all_tickets_${ddate}_Request_${i}.json >> Data/all_tickets_${ddate}_COMB.json

if [[ ${i} -lt ${numtimes} ]]; then

	echo "],"  >> Data/all_tickets_${ddate}_COMB.json
	echo "True"

else

	echo "]"  >> Data/all_tickets_${ddate}_COMB.json
	echo "False"
fi

#Remove uneeded previous files
rm -rf Data/all_tickets_${ddate}_Request_${i}.json

done

#Adding to make valid JSON after loop
echo "}"  >> Data/all_tickets_${ddate}_COMB.json

#Ed script
echo "|_ _|  _ \| ____/ _ \  | | | |"
echo " | || | | |  _|| | | | | | | |"
echo " | || |_| | |__| |_| | | |_| |"
echo "|___|____/|_____\___/   \___/ "

echo "Script done! :-)"
say "Script done!"
echo "*********"
#Show file location for easy access
echo "File located at: $(pwd all_tickets_2017-11-02_COMB.json)"
echo "*********"
echo "Would you like to open sqlify in your browser to convert JSON to CSV? (Y/N)"
echo "********"

read answer

if [[ $answer = "Y" || $answer = "y" ]]; then

open https://sqlify.io/convert/json/to/csv

else

	say "Okay"

fi
