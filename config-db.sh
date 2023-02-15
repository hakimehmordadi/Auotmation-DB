#!/bin/bash
echo =======================================================================================
echo
echo ***Automation Database Creation: Bash Script***
echo 2020 Feb 05
echo
echo =======================================================================================


#Get UserName Value From Flag -u To Authentication
if getopts "u:" arg; then
   username=$OPTARG
   echo $username
fi

#Get Password Value From Flag -p to Authentication
if getopts "p:" arg; then
   password=$OPTARG
fi

#Get File Value From Flag -f
if getopts "f:" arg; then
	file=$OPTARG
fi

echo FileName is $file

#Get Mongo Pod Name
echo 1 - Getting Mongo Pod Name

mongoPodName=$(kubectl get pods -o json | \
	jq -r '.items[0].metadata.name')
echo $mongoPodName

#Check pod healthy
echo 2 - Checking Healthy

if [ -z "$mongoPodName" ]
then
	echo "Pod doesn't exist"
else
        podStatus=$(kubectl get pod ${mongoPodName} | awk '{print $3}' | grep -v ^STATUS)
        echo $podStatus
fi

if [ ${podStatus} == "Running" ]
then
        echo Pod Is Running Healthy
echo ======================================================================================
# Database Creation
echo 3 - Extract Database Name and Username and Password From File
echo ======================================================================================

if [ -z "$file" ]
then
	echo "File Dosn't Exist"
else
        dbNameKey=$(grep -R "name" $file)
        userNameKey=$(grep -R "user" $file)
	passwordKey=$(grep -R "password" $file)

	#----------------------------------------

        if  [ -z "$dbNameKey" ]  ||  [ -z "$userNameKey" ] || [ -z "$passwordKey" ] 
        then
	       echo "Database Name or Username or Password Not Found, Please Check File Content"
	       
        else
	       echo ----------------------------------------------------------------------
	       echo
               dbNameValue=$(echo $dbNameKey | awk -F"=" {'print $2'})
	       echo Database Name Is: $dbNameValue
	       userNameValue=$(echo $userNameKey | awk -F"=" {'print $2'})
               echo Username Is : $userNameValue
               passwordValue=$(echo $passwordKey | awk -F"=" {'print $2'})
               echo Password Is : $passwordValue
	       echo       
	       echo -----------------------------------------------------------------------
   
	       kubectl exec  $mongoPodName -i -c mongodb -- mongo -u $username -p $password  <<EOF
               use $dbNameValue;
               db.agent.insert({"username": "$userNameValue", "createddate": "$new Date()"});
               db.getCollection("agent");
               show dbs;
               db.createUser({user: "$userNameValue", pwd: "$passwordValue", roles:["readWrite" ]});
               db.getUser("$userNameValue");
	       db.auth( "$userNameValue", "$passwordValue" );
               db;
EOF

       fi
fi

else
	echo "Pod isn't running healthy, Please check pos status with "kubectl get pods" command"
fi

