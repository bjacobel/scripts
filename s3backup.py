#!/usr/local/bin/python

# rewuires boto and boto-rsync (available through pip) 

import subprocess
import boto
import os
import sys
from getopt import getopt

ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID')
SECRET_KEY = os.environ.get('AWS_SECRET_ID')

if ACCESS_KEY_ID is None:
    ACCESS_KEY_ID = raw_input('Your access key ID: ')
if SECRET_KEY is None:
    SECRET_KEY = raw_input('Your secret key: ')

backup_command = "boto-rsync -w -a {access} -s {secret} s3://{bucket}/ ./".format(access=ACCESS_KEY_ID, secret=SECRET_KEY, bucket=sys.argv[1])