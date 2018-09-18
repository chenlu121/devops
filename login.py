#!/usr/local/bin/python3
import getpass
def checkin(user,passwd):
	userinfo={'zhangsan':'123456','lisi':'654321'}
	if user in userinfo and password==userinfo[user]:
		print('login ok')
	else:
		print('user or password input wrong') 

username=input('input username:')
password=getpass.getpass('input password:')
checkin(username,password)

