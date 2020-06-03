import sys
import argparse

class MyParser:
    def __init__(self):
        self.parser = argparse.ArgumentParser()
        self.parser.add_argument('location', type=str, nargs=1)
        self.parser.add_argument('number', type=int, nargs=2)
        self.parsed = self.parser.parse_args()

    def Parse(self, fileName):
        f = open(fileName, 'r')
        filedata = f.read()
        f.close()

        filedata = filedata.replace("nopath", str(self.parsed.location[0]))
        filedata = filedata.replace("notassigned", str(self.parsed.number[0]))
        filedata = filedata.replace("sitefolderid", str(self.parsed.number[1]))
        filedata = filedata.replace("noid", str(self.parsed.number[0]))

        f = open(fileName, 'w')
        f.write(filedata)
        f.close()

myParser = MyParser()
myParser.Parse('sample.sh')
myParser.Parse('Main.R')
myParser.Parse('CallSTEPWAT2.R')
myParser.Parse('STEPWAT_DIST/sample.sh')