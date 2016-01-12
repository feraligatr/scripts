import re

xmlList = {}
xmlFile = open("mrock_song_client.xml");
for xmlLine in xmlFile:
	m = re.search(r"<m_szPath>(.*)</m_szPath>", xmlLine)
	if m:
		xmlList[m.group(1)] = '-'

folderList = []
folderFile = open("fn.txt");
for folderLine in folderFile:
	folderName = folderLine.strip()
	if len(folderName) > 0:
		folderList.append(folderName)

for xmlName in xmlList.keys():
	if xmlName in folderList:
		folderList.remove(xmlName)
		del xmlList[xmlName]

for folderName in folderList:
	if not folderName.startswith('v'):
		folderList.remove(folderName)

i = 0
xmlFile = open("mrock_song_client.xml");
outFile = open("out.xml", "w")
for xmlLine in xmlFile:
	m = re.search(r"<m_szPath>(.*)</m_szPath>", xmlLine)
	if m and (m.group(1) in xmlList) and i < len(folderList):
		outFile.write(xmlLine.replace('>' + m.group(1) + '<', '>' + folderList[i] + '<'))
		i = i + 1
	else:
		outFile.write(xmlLine)
