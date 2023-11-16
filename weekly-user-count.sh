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

# Scheduling to run: each 7 minute, between 6-20 hours, from Monday till Friday
7 6-20 * * 1-5 /usr/local/bin/user-count/weekly-user-count.sh

# End of Crontab -----------------------------
'


: '
# Start of store program -----------------------------
# store the program at /usr/local/bin/user-count
# name it "weekly-user-count.sh "
vim /usr/local/bin/user-count/weekly-user-count.sh
# End of store program -----------------------------
'


# writes current user(s) - START -----------------------------
# who | \                                   # who - show who is logged on
# awk '{print $1}' | \                   # prints 1st column
# awk '!NF || !seen[$0]++' \            # remove duplicate lines
# >> /usr/local/bin/user-count/daily-user-log-in.txt # write program to text file.

who | \
    awk '{print $1}' | \
    awk '!NF || !seen[$0]++' \
    >> /usr/local/bin/user-count/daily-user-log-in.txt
# writes current user(s) - END -----------------------------


# user count - START -----------------------------
# sorts duplicate lines and exports to daily-user-count.txt file.
sort -u /usr/local/bin/user-count/daily-user-log-in.txt > /usr/local/bin/user-count/daily-user-count.txt
# user count - END -----------------------------

# Create the directory if it does not exist - START
# Files will be stored in Weekly diectory.
if [ ! -d "/usr/local/bin/user-count/weekly" ]; then
    mkdir -p "/usr/local/bin/user-count/weekly"
fi
# Create the directory if it does not exist - END

# user WEEKLY count - START -----------------------------
# "date +%A" - shows day
# "date +"%Y-%m-%d"" - shows date (2023-11-16)
# " awk 'END{print NR}' " - counts lines.
awk 'END{print NR}' /usr/local/bin/user-count/daily-user-count.txt > /usr/local/bin/user-count/weekly/daily-user-count-"$(date +"%A")-$(date +"%Y-%m-%d")"
# user WEEKLY count - END -----------------------------


# Look at the directory weekly - Start
for entry in "weekly"/*; do
  if [ -f "$entry" ]; then
    echo "$entry" >> weekly.txt
    cat "$entry" >> weekly.txt
  fi
done
# Look at the directory  weekly - End


# replace " - " with " " using awk command.
awk '{gsub(/-/, " "); print}' <  weekly.txt >  weekly1.txt

# remove "weekly" word using awk command
awk '{gsub("weekly/", ""); print}' <  weekly1.txt >  weekly2.txt


# send email & remove files - START -----------------------------

# daily 20:00 delete files: daily-user-log-in.txt & daily-user-count.txt,
# if files are not deleted daily, next day files will be appended (data incorrect, corrupt)
#if [ "$(date +%H)" = "20" ]; then
# For testing purpose use following line
if [ "$(date +%d)" = "$(date +%d)" ]; then
# For production use follwoing line
#if [ "$(date +%H)" = "20" ]; then
    rm /usr/local/bin/user-count/daily-user*.txt
fi

# For testing purpose use following line:
if [ "$(date +%d)" = "$(date +%d)" ]; then
echo -e "hostname - $(hostname): \n$(cat /usr/local/bin/user-count/weekly2.txt)"

# Production
# send an email if it's Friday at 20:00
#if [ "$(date +%d-%H:%M:%S)" = "15-20:00:00" ]; then

# Send email - START -----------------------------
# echo "This is the body of the email" | mail -s "Subject line" -a /path/to/file.txt  recipient@example.com
#echo -e "hostname - $(hostname): \n$(cat /usr/local/bin/user-count/weekly2.txt)"  | \
#mail -s "$(hostname) weekly user count" root@localhost
# Send email - END -----------------------------

# Clean up - START -----------------------------
    # Delete a files.
    rm -f /usr/local/bin/user-count/weekly*.txt
# Clean up - END -----------------------------
fi
# send email & remove files - END -----------------------------
