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

curl https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip -o /tmp/backend.zip
VALIDATE $? "downloading code from remote"

rm -rf /app/*
VALIDATE $? "removoing old code"

cd /app
VALIDATE $? "going inside /app directory"

unzip /tmp/backend.zip
VALIDATE $? "unzipping backend code"

npm install
VALIDATE $? "installing dependencies"

id expense
if [ $? -eq 0 ]
then
    echo "expense already exist"
else
    useradd expense
    VALIDATE $? "expense user creation"
fi

cp /home/ec2-user/Expense_Project_using_Shell_scripting/backend.service /etc/systemd/system/
VALIDATE $? "copying backend.service file to system folder"

systemctl start backend
VALIDATE $? "backend start"

systemctl enable backend
VALIDATE $? "enable backend"

mysql -h 172.31.30.40 -u root -pExpenseApp@1 </app/schema/backend.sql
VALIDATE $? "loading sql schema to database"


