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

dnf list installed mysql-server
if [ $? -eq 0 ]
then 
    echo "mysql-server already installed skipping..."
else
    echo "installing mysql-server"
    dnf install mysql-server -y
    VALIDATE $? "mysql-server installation"
fi

systemctl start mysqld
VALIDATE $? "start mysqld"

systemctl enable mysqld
VALIDATE $? "enable mysqld"

mysql -h 172.31.24.29 -u root -pExpenseApp@1 -e 'show databases;'

if [ $? -ne 0 ]
then
    echo "MySQL Root password not setup"
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting Root Password"
else
    echo "MySQL Root password already setup ...SKIPPING"
fi

