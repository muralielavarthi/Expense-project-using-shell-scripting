TIME_STAMP=$(date +"%d-%m-%y-%H-%M-%S")
USER_ID=$(id -u)
LOGS_FOLDER="frontend-logs"
LOGS_FILE_NAME=$(echo $0 | cut -d "." -f1)
LOGS_FINAL_NAME="/home/ec2-user/$LOGS_FOLDER/$LOGS_FILE_NAME-$TIME_STAMP.log"

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

dnf list installed nginx &>>$LOGS_FINAL_NAME
if [ $? -eq 0 ]
then
    echo "nginx already installed skipping.."
else
    dnf install nginx -y  &>>$LOGS_FINAL_NAME
    VALIDATE $? "Installing Nginx Server"
fi

systemctl enable nginx &>>$LOGS_FINAL_NAME
VALIDATE $? "Enabling Nginx server"

systemctl start nginx &>>$LOGS_FINAL_NAME
VALIDATE $? "Starting Nginx Server"

rm -rf /usr/share/nginx/html/* &>>$LOGS_FINAL_NAME
VALIDATE $? "Removing existing version of code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGS_FINAL_NAME
VALIDATE $? "Downloading Latest code"

cd /usr/share/nginx/html
VALIDATE $? "Moving to HTML directory"

unzip /tmp/frontend.zip &>>$LOGS_FINAL_NAME
VALIDATE $? "unzipping the frontend code"

cp /home/ec2-user/Expense_Project_using_Shell_scripting/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copied expense config"

systemctl restart nginx &>>$LOGS_FINAL_NAME
VALIDATE $? "Restarting nginx"