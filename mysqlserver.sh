#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIME_STAMP=$(date +"%d-%m-%y-%H-%M-%S")
USER_ID=$(id -u)
LOGS_FOLDER="/home/ec2-user/logs"
SCRIPT_NAME=$0
FINAL_SCRIPT_NAME=$(echo $SCRIPT_NAME | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$FINAL_SCRIPT_NAME-$TIME_STAMP"
mkdir /home/ec2-user/logs

rootCheck(){
    if [ $USER_ID -ne 0 ]
    then
        echo -e "$R Error:You should have root access to install" &>>$LOG_FILE 
        exit 1
    fi

}
validate(){
    if [ $1 -eq 0 ]
    then
        echo -e "$G $2... $G Success $N" &>>$LOG_FILE 
    else
        echo -e "$R $2...  Failure $N" &>>$LOG_FILE 
        exit 1
    fi
}
rootCheck

echo -e "$Y Script started at: $TIME_STAMP $N" &>>$LOG_FILE 

dnf list installed mysql-server &>>$LOG_FILE 

if [ $? -ne 0 ]
then
    dnf install mysql-server -y  &>>$LOG_FILE 
    validate $? "installing mysql-server"
else
    echo -e "$G msql-server already installed $N" &>>$LOG_FILE 
fi

systemctl start mysqld &>>$LOG_FILE 
validate $? "mysql-server started"

systemctl enable mysqld &>>$LOG_FILE 
validate $? "mysql-server enabled"
