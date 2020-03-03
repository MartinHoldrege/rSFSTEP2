import sys
import argparse

f = open('Main.R','r')
filedata = f.read()
f.close()

parser = argparse.ArgumentParser()
parser.add_argument('location', type=str, nargs=1)
parser.add_argument('number', type=int, nargs=2)
parsed = parser.parse_args()

newdata = filedata.replace("nopath",str(parsed.location[0]))
filedata = newdata
newdata = filedata.replace("notassigned",str(parsed.number[0]))

filedata = newdata
newdata = filedata.replace("sitefolderid",str(parsed.number[1]))

fileout='Main.R'
f = open(fileout,'w')
f.write(newdata)
f.close()

f = open('sample.sh','r')
filedata = f.read()
f.close()
tempstring=str(parsed.location[0])+"/"+"Main.R"
newdata = filedata.replace("notassigned",tempstring)
filedata = newdata
newdata = filedata.replace("noid",str(parsed.number[0]))
fileout='sample.sh'
f = open(fileout,'w')
f.write(newdata)
f.close()

fileout='STEPWAT_DIST/sample.sh'
f = open(fileout, 'r')
filedata = f.read()
f.close()
newdata = filedata.replace("noid",str(parsed.number[0]))
f = open(fileout,'w')
f.write(newdata)
f.close()

f = open('OutputDatabase.R','r')
filedata = f.read()
f.close()
newdata = filedata.replace("nopath",str(parsed.location[0]))
filedata = newdata
newdata = filedata.replace("notassigned",str(parsed.number[0]))

filedata = newdata
newdata = filedata.replace("sitefolderid",str(parsed.number[1]))

fileout='OutputDatabase.R'
f = open(fileout,'w')
f.write(newdata)
f.close()


