#!/bin/bash
PACKAGE_NAME=$1
ARGS_COUNT=$#
USER_ID=$(id -u)
TIMESTAMP=$(date +%d-%m-%y-%H-%M-%S)

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
    else if [ $ARGS_COUNT -gt 1 ]
         then
            echo "Please enter one package name in the format: $0 <package-name>"
            exit 1
        fi
    fi
}

validateInstall(){
    if [ $1 -ne 0 ]
    then
        echo "$2 installation failure"
    else
        echo "$2 installation Success"
    fi
}

echo "script started running at $TIMESTAMP"

rootUser
argCheck

dnf list installed $PACKAGE_NAME

if [ $? -ne 0 ]
then
    dnf install $PACKAGE_NAME -y 
    validateInstall $? $PACKAGE_NAME
else
    echo "$PACKAGE_NAME already installed skipping.."
fi