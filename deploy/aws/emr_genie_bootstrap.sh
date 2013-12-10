#!/bin/bash

##
#
#  Copyright 2013 Netflix, Inc.
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
#
##

set -x
set -e

# Install Tomcat
cd $HOME; wget http://mirror.sdunix.com/apache/tomcat/tomcat-6/v6.0.37/bin/apache-tomcat-6.0.37.tar.gz
tar zxvf apache-tomcat-6.0.37.tar.gz

# Change port to 7001 to work out of the box
perl -p -i.bak -ne "s#8080#7001#g" /home/hadoop/apache-tomcat-6.0.37/conf/server.xml
    
# update /home/hadoop/apache-tomcat-6.0.37/conf/web.xml to enable directory browsing
perl -0777 -p -i.bak -ne 's#(<param-name>listings</param-name>\s*<param-value>)false(</param-value>)#\1true\2#;' \
    /home/hadoop/apache-tomcat-6.0.37/conf/web.xml

# Set up Genie specific properties
export CATALINA_HOME=/home/hadoop/apache-tomcat-6.0.37
export CATALINA_OPTS="-Darchaius.deployment.applicationId=genie -Dnetflix.datacenter=cloud"

# Set up directories needed
mkdir -p /mnt/tomcat/genie-jobs;
ln -fs /mnt/tomcat/genie-jobs $CATALINA_HOME/webapps
mkdir -p /opt/mapr/pig/pig-0.11/conf; touch /opt/mapr/pig/pig-0.11/conf/pig.properties

# Set up genie - get the latest from GitHub
git clone https://github.com/korrelate/genie.git
cd $HOME/genie; ./gradlew clean build -x test
cd $HOME/genie; ./local_deploy.sh

# Start Tomcat
cd $CATALINA_HOME/logs; $CATALINA_HOME/bin/startup.sh;
