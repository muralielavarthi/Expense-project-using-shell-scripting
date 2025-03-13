#!/bin/bash

TIME_STAMP=$(date +"%d-%m-%y-%H-%M-%S")
USER_ID=$(id -u)
LOGS_FOLDER="backend-logs"
LOGS_FILE_NAME=$(echo $0 | cut -d "." -f1)
LOGS_FINAL_NAME="/home/ec2-user/$LOGS_FOLDER/$LOGS_FILE_NAME-$TIME_STAMP"

ROOTUSER(){
if [ $USER_ID -ne 0 ]
then
    echo "You need root access to proceed"
    exit 1
fi
}
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo "$2 Success"
    else
        echo "$2 Failure"
        exit 1
    fi
}
echo "script started executing at $TIME_STAMP"
ROOTUSER

if [ -d /home/ec2-user/$LOGS_FOLDER ]
then
    echo "Logs folder already created skipping.."
else
    mkdir -p /home/ec2-user/$LOGS_FOLDER
    echo "logs folder created"
fi

dnf list installed nodejs

if [ $? -eq 0 ]
then
    echo "nodejs already installed skipping.."
else
    dnf module disable nodejs -y
    VALIDATE $? "disable nodejs"
    dnf module enable nodejs:20 -y
    VALIDATE $? "enable nodejs version 20"
    dnf install nodejs -y
    VALIDATE $? "nodejs installation"
fi

if [ -d /app ]
then
    echo "app folder already created skipping.."
else
    mkdir -p /app
    echo "app folder created"
fi

