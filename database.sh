#!/bin/bash

TIME_STAMP=$(date +"%d-%m-%y-%H-%M-%S")
USER_ID=$(id -u)

ROOTUSER(){
if [ $USER_ID -ne 0 ]
then
    echo "You need root access to proceed"
    exit 1
fi
}
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo "$2 installation Success"
    else
        echo "$2 installation Failure"
    fi
}
echo "script started executing at $TIME_STAMP"
ROOTUSER

dnf list installed mysql-server
if [ $? -eq 0 ]
then 
    echo "mysql-server already installed skipping..."
else
    echo "installing mysql-server"
    dnf install mysql-server -y
    VALIDATE $? "mysql-server"
fi



