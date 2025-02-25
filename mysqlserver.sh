#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIME_STAMP=$(date +"%d-%m-%y-%H-%M-%S")
USER_ID=$(id -u)
LOGS_FOLDER="/home/ec2-user/sql-logs"
SCRIPT_NAME=$0
FINAL_SCRIPT_NAME=$(echo $SCRIPT_NAME | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$FINAL_SCRIPT_NAME-$TIME_STAMP"

if [ -d $LOGS_FOLDER ]
then
    echo -e "$Y $LOGS_FOLDER directory already exists.. SKIPPING $N"
else
    mkdir -p /home/ec2-user/sql-logs #-p make idempotent(it will if not exists, otherwise it will skip)
fi

rootCheck(){
    if [ $USER_ID -ne 0 ]
    then
        echo -e "$R Error:You should have root access to install"
        exit 1
    fi

}
validate(){
    if [ $1 -eq 0 ]
    then
        echo -e "$G $2... $G Success $N" 
    else
        echo -e "$R $2...  Failure $N"
        exit 1
    fi
}
rootCheck

echo -e "$Y Script started at: $TIME_STAMP $N" 

dnf list installed mysql-server &>>$LOG_FILE 

if [ $? -ne 0 ]
then
    dnf install mysql-server -y  &>>$LOG_FILE 
    validate $? "installing mysql-server"
else
    echo -e "$G msql-server already installed $N" 
fi

systemctl restart mysqld &>>$LOG_FILE 
validate $? "mysql-server restarted"

systemctl enable mysqld &>>$LOG_FILE 
validate $? "mysql-server enabled"

mysql -h 172.31.82.58 -u root -pExpenseApp@1 -e 'show databases;'&>>$LOG_FILE 
#e to write show query in command line instead of mysqlclient

if [ $? -ne 0 ]
then
    mysql_secure_installation --set -root -pass root &>>$LOG_FILE
    validate $? "root password setting now..." 
else
    echo -e "$G Default root password has been set..Skipping $N"
fi


