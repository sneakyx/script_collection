#!/bin/bash
#########################################################################
#                          moodle_control.sh                            #
#       this script makes it easier to handle moodle containers         #
# usage:        moodle_control.sh $name $pass1 $pass2 $port $action     #
# Paramters:                                                            #
#               $action create/stop/delete/start/update/full-delete     #
#                       (full-delete deletes also database -all Your    #
#                       data will be lost- use with cation!)            #
#                       (start means starting existing container!)      # 
#               $name   exchange with Your favorite name   (needed)     #
#               $pass1  password for mysql admin    \   only used       #
#               $pass2  password for moodle user >  with parameter      #
#               $port   which port should be used?   /   create!        #
#               $adress which adress is moodle URL? /                   #
#-----------------------------------------------------------------------#
#      V 2016-10-30-21-12  made by sneaky(x) or Rothaar Systems         #
#                        dedicated to my family                         #
#                   released under Apache 2.0 licence                   #
#               http://www.apache.org/licenses/LICENSE-2.0              #
#########################################################################

if  [ -z $2 ]  ; then
        echo >&2 'error: missing parameters'
        echo >&2 "usage: moodle_control.sh create/stop/delete/start/update/full-delete $name"
        exit 1
fi
case "$1" in
	stop)
		# just stops container
		docker stop mysql-moodle-$2 moodle-$2
		echo container was stoped
	;;
	start)
		# just starts container
		docker start mysql-moodle-$2 moodle-$2

		echo container was started
	;;
	delete)
		# stops and deletes container
		docker stop mysql-moodle-$2 moodle-$2
		docker rm mysql-moodle-$2 moodle-$2
		echo container was deleted, data is stored in /home/moodle/$2
	;;
	
	full-delete)
		# stops and deletes container
		# deletes also all Your data stored in container!
		docker stop mysql-moodle-$2 moodle-$2
		docker rm mysql-moodle-$2 moodle-$2
		rm -r /home/moodle/$2
		echo all Your data was deleted!
	;;
	update)
		# stops, deletes and updates the container.
		if  [ -z $3 ] && [ -z $4 ] && [ -z $5 ]; then
	        echo >&2 'error: missing parameters'
	        echo >&2 'usage: build_new_container.sh start/stop/update/create $name $root-pass $pass2 $port'
	        exit 1
		fi	

		docker pull mysql
		docker pull sneaky/moodle-test
		docker stop mysql-moodle-$2 moodle-$2
		docker rm mysql-moodle-$2 moodle-$2
		
	;&
	
	create)
		# creates new images 
		if  [ -z $6 ] ; then
	        echo >&2 'error: missing parameters'
	        echo >&2 'usage: build_new_container.sh create $name $root-pass $pass2 $port $address'
	        exit 1
		fi	
		# creating folders
		mkdir -p /home/moodle/$2/mysql /home/moodle/$2/moodledata /home/moodle/$2/html
		
		# create and run mysql container
		
		docker run -d --name mysql-moodle-$2 \
			-e MYSQL_ROOT_PASSWORD=$3 \
			-e MYSQL_DATABASE=moodle \
			-e MYSQL_USER=moodle \
			-e MYSQL_PASSWORD=$4 \
			-v /home/moodle/$2/mysql:/var/lib/mysql mysql
		
		# create and run moodle container
		
		docker run -d \
			--name moodle-$2 \
			-p $5:80 \
			-e MOODLE_URL=$6 \
			-v /home/moodle/$2/moodledata:/var/moodledata \
			--link mysql-moodle-$2:mysql \
			sneaky/moodle-test
		echo container was created/ updated
	;;
	*)	
		echo >&2 'error: missing parameters'
        echo >&2 'usage: moodle_control.sh start/stop/update/create/delete/full-delete $name'
        	
esac