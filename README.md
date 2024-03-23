:rocket: Speedtest CLI on CentOS 7
===================================================

The project goal is to measure internet connection through a selected link.

The data collected is:
- Download speed
- Upload speed
- Jitter
- Latency
- Packet loss percent


## :gear: Requeriemts
- [CentOS 7] - CentOS 7 as Operating System.


## :robot: Tech

- [jq] - command-line JSON processor.
- [Speedtest CLI] - Internet connection measurement for developers
- [AWS CLI] - CLI tool to manage AWS Services.


## :bulb: Installation

Install the dependencies.

```sh
#install jq
$ yum install epel-release -y
$ yum install jq -y

#install Speedtest CLI
$ curl -s https://install.speedtest.net/app/cli/install.rpm.sh | sudo bash
$ sudo yum install speedtest
# NOTE: run speedtest for the first time to accept the license using command 'speedtest'

#install AWS CLI
$ sudo yum install unzip
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
$ unzip awscliv2.zip
$ sudo ./aws/install

$ mkdir -p ~/results
```


### :old_key: AWS Credentials configuration
```sh
#setting config,
$ mkdir /home/[user]/.aws
$ sudo vi /home/[user]/.aws/config 
# copy config file content to this editing view.

$ setting credentials
$ sudo vi ~/.aws/credentials
# copy credentials file content to this editing view with [credentials provided]
```

- config file content: 
 ```sh 
[default]
region=us-east-1
output=json
```

- credentials file content: 
 ```sh 
[default]
aws_access_key_id=[provided by administrator]
aws_secret_access_key=[provided by administrator]
```

> Note: The credentials will be provided by the sysadmin

For more info: [Configuration and credential file settings]

### :paperclip: Copying script to instance
Copy speedtest_cli-script.sh of this repo to instance using scp 

> Note: Please update id variable with site id


### :runner: Setting up cron job.
 ```sh 
$ chmod +x /home/[user]/speedtest_cli-script.sh 
$ crontab -e
# copy crontab file contet to con editor.
```

- crontab file: 
 ```sh 
0 * * * * /home/[user]/speedtest_cli-script.sh
```


##  :question: Get help
Please email to [rafah.larios@gmail.com](rafah.larios@gmail.com)




[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)
    
   [Speedtest CLI]: <https://www.speedtest.net/apps/cli>
   [jq]: <https://stedolan.github.io/jq/>
   [CentOS 7]: <https://www.centos.org/download/>
   [AWS CLI]: <https://aws.amazon.com/cli/>
   [Configuration and credential file settings]: <https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html>
   
   
