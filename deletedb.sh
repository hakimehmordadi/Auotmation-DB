#!/bin/bash
#=======================================================================================

***Automation Database Deletation: Bash Script***
2020 Feb 05

#=======================================================================================

dbName=$1
               kubectl exec  mongo-mongodb-797f6d8b8-r7c8n  -i -c mongodb -- mongo -u root -p 9TWMfCWxasf5fQasALSIX4LHk6xkvheK  <<EOF
               use $dbName;
               db.dropDatabase();
               show dbs;
EOF

