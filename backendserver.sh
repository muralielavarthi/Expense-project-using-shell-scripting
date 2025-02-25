#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIME_STAMP=$(date +"%d-%m-%y-%H-%M-%S")
USER_ID=$(id -u)
LOGS_FOLDER="/home/ec2-user/backend-logs"
SCRIPT_NAME=$0
FINAL_SCRIPT_NAME=$(echo $SCRIPT_NAME | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$FINAL_SCRIPT_NAME-$TIME_STAMP"
APP_FOLDER="/app"

if [ -d $LOGS_FOLDER ]
then
    echo -e "$Y $LOGS_FOLDER directory already exists.. SKIPPING $N"
else
    mkdir -p /home/ec2-user/backend-logs #-p make idempotent(it will if not exists, otherwise it will skip)
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

dnf list installed nodejs &>>$LOG_FILE 

if [ $? -ne 0 ]
then
    dnf module list disable nodejs  &>>$LOG_FILE 
    validate $? "disabled nodejs"
    dnf module list enable nodejs:20  &>>$LOG_FILE 
    validate $? "enabled nodejs 20"
    dnf install nodejs -y &>>$LOG_FILE 
    validate $? "installing nodejs"
else
    echo -e "$G nodejs already installed $N" 
fi


if [ -d $APP_FOLDER ]
then
    echo -e "$Y $LOGS_FOLDER directory already exists.. SKIPPING $N"
else
    mkdir -p /app
    validate $? "$G Creating app folder $N"
fi

curl https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip -o /tmp/backend.zip &>>$LOG_FILE
validate $? "downloading latest code"

cd /app

rm -rf /app/* # deployment means removing old code updating new code

unzip /app/backend.zip &>>$LOG_FILE
validate $? "unzip latest code"

npm install &>>$LOG_FILE
validate $? "installing dependencies"

id expense &>>$LOG_FILE

if [ $? -ne 0]
then
    useradd expense2 &>>$LOG_FILE
    validate $? "creating expense user"
else
    echo -e "$G expene user already exists.. $N"
fi

cp /home/ec2-user/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE
validate $? "creating systemctl service"

systemctl start backend &>>$LOG_FILE
validate $? "starting backend"

systemctl enable backend &>>$LOG_FILE
validate $? "enable backend"

dnf install mysql -y &>>$LOG_FILE
validate $? "installing mysql client"

mysql -h 172.31.82.58 -u root -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
validate $? "loading schema to mysql server"

systemctl restart backend
validate $? "restarting backend"

