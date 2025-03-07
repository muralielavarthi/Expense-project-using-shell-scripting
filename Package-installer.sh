#!/bin/bash
PACKAGE_NAME=$1
ARGS_COUNT=$#
USER_ID=$(id -u)
TIMESTAMP=$(date +%d-%m-%y-%H-%M-%S)
FILE_NAME=$(echo $0 | cut -d "." -f1 )
LOGS_FILE_NAME="$FILE_NAME-$TIMESTAMP"
LOGS_FOLDER="Package-installation-logs"
LOGS_FILE="/var/log/$LOGS_FOLDER/$LOGS_FILE_NAME"

rootUser(){
    if [ $USER_ID -ne 0 ]
    then
        echo "You need root acess to install any package"
        exit 1
    fi
}
argCheck(){
    if [ $ARGS_COUNT -eq 0 ]
    then
        echo "Please enter package name in the format: $0 <package-name>"
        exit 1
    elif [ $ARGS_COUNT -gt 1 ]
    then
        echo "Please enter one package name in the format: $0 <package-name>"
        exit 1
    fi

}

validateInstall(){
    if [ $1 -ne 0 ]
    then
        echo "$2 installation failure"
        exit 1
    else
        echo "$2 installation/creation Success"
    fi
}

rootUser
echo "script started running at $TIMESTAMP"

if [ -d /var/log/$LOGS_FOLDER ] #by default log folder will not be there,run some installation/scripts, it will create
then
    echo "logs-folder already exists Skipping.."
else 
    mkdir -p /var/log/$LOGS_FOLDER
    validateInstall $? "logs-folder" 
fi
argCheck

echo "Logging started at $TIMESTAMP" > $LOGS_FILE

dnf list installed $PACKAGE_NAME &>>$LOGS_FILE

if [ $? -ne 0 ]
then
    dnf install $PACKAGE_NAME -y  &>>$LOGS_FILE
    validateInstall $? $PACKAGE_NAME
else
    echo "$PACKAGE_NAME already installed skipping.."
fi