#!/bin/bash

TIME_STAMP=$(date +"%d-%m-%y-%H-%M-%S")
USER_ID=$(id -u)
LOGS_FOLDER="database-logs"
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

dnf list installed mysql-server &>$LOGS_FINAL_NAME
if [ $? -eq 0 ]
then 
    echo "mysql-server already installed skipping..."
else
    echo "installing mysql-server"
    dnf install mysql-server -y &>>$LOGS_FINAL_NAME
    VALIDATE $? "mysql-server installation"
fi

systemctl start mysqld &>>$LOGS_FINAL_NAME
VALIDATE $? "start mysqld"

systemctl enable mysqld &>>$LOGS_FINAL_NAME
VALIDATE $? "enable mysqld"

mysql -h 172.31.30.40 -u root -pExpenseApp@1 -e 'show databases;' &>>$LOGS_FINAL_NAME

if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGS_FINAL_NAME
    VALIDATE $? "Root Password setup"
else
    echo "MySQL Root password already setup ...SKIPPING"
fi

