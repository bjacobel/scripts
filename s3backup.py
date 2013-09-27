#!/usr/local/bin/python

# rewuires boto and boto-rsync (available through pip) 

from subprocess import call
import boto
import os
import sys
import getopt

try:
    opts, args = getopt.getopt(sys.argv[1:],"b:",["bucket="])
except getopt.GetoptError:
    print('s3backup.py [-b <s3 bucket>]')
    sys.exit(2)

for opt, arg in opts:
    if opt == "-b":
        BUCKET = arg

ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID')
SECRET_KEY = os.environ.get('AWS_SECRET_KEY')

if ACCESS_KEY_ID is None:
    ACCESS_KEY_ID = raw_input('Your access key ID: ')
if SECRET_KEY is None:
    SECRET_KEY = raw_input('Your secret key: ')

try:
    print "Backing up to bucket {}".format(BUCKET)
except:
    BUCKET = os.path.basename(os.path.abspath(__file__))

backup_command = "boto-rsync -w -a {access} -s {secret} s3://{bucket}/ ./".format(access=ACCESS_KEY_ID, secret=SECRET_KEY, bucket=BUCKET)

call(backup_command, shell=True)