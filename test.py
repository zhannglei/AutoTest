import subprocess

host = 'wfq-0'
cmd = "ssh %s" % host
session = subprocess.Popen(cmd, stdin=subprocess.PIPE,stdout=subprocess.PIPE,shell=True)
print session.stdout.read()