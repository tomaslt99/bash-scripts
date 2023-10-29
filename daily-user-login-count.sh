#!/bin/bash
#
# Author:
# 
# Contact: 
# mobile: 
# e-mail: 
# Purpose:
# Display daily user login in count.



# Requrement:
# Before starting program, setup cron job 1st.

: '
# Start of Crontab -----------------------------
# Setup crontab before running program.

# enable and start cron
systemctl enable crond
systemctl reload crond


# Schedule jobs with cron 

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed


## Instead of root user, use dedicated sudo user that does not require password for each task, command.
crontab -e -u root

# Scheduling to run: each 7 minute, between 6-20 hours, each day
7 6-20 * * * /usr/local/bin/daily-user-log-in.sh

# End of Crontab -----------------------------
'


: '
# Start of store program -----------------------------
# store the program at /usr/local/bin/
# name it " daily-user-log-in.sh"
vim /usr/local/bin/daily-user-log-in.sh

# Store Program  - Start -----------------------------
# End of store program -----------------------------
'


# writes current user(s) - START -----------------------------
who \                                   # who - show who is logged on
|  awk '{print $1}' \                   # prints 1st column
| awk '!NF || !seen[$0]++' \            # remove duplicate lines
>> /usr/local/bin/daily-user-log-in.txt # write program to text file.
# writes current user(s) - END -----------------------------


# user count - START -----------------------------
echo "$(date +%x) $(date +%A)" \        # "date +%x" - shows date (10/29/2023), "date +%A" - shows day.
- $(hostname) daily user login count is \
$(awk 'END{print NR}' /usr/local/bin/daily-user-count.txt).     # " awk 'END{print NR}' " - counts lines.
# user count - END -----------------------------


# Send email - START ----------------------------- 
# sending email from terminal, syntax:
# echo "This is the body of the email" | mail "Subject line" -a /path/to/file.txt  recipient@example.com

echo "$(date +%x) $(date +%A)" - $(hostname) daily user login in count is $(awk 'END{print NR}' /usr/local/bin/daily-user-log-in.txt). | mail -s "Daily user count" root@localhost
# Send email - END -----------------------------


# Clean up - START -----------------------------
# Delete a files.

# if is 20:00, will remove files. 
if [ $(date +%H) -eq 20 ]; then
    rm /usr/local/bin/daily-user-log-in.txt
    rm /usr/local/bin/daily-user-count.txt
fi
# Clean up - END -----------------------------
