#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <map>
#include <algorithm>

#define USE_REGEX_CXX11 1
#define USE_REGEX_BOOST 2
#define USE_REGEX_XPRESSIVE 3

#define USE_REGEX USE_REGEX_CXX11

#if USE_REGEX == USE_REGEX_CXX11
// g++ -std=c++11 ./dbcomp.cpp
#include <regex>
#elif USE_REGEX == USE_REGEX_BOOST
#include "boost/regex"
#elif USE_REGEX == USE_REGEX_XPRESSIVE
#include <boost/xpressive>
#endif

struct RomInfo
{
	std::string filename;
	std::vector<unsigned long> checksums;
};

typedef std::map<unsigned long, std::vector<const RomInfo*> > RomHash;

struct BinInfo
{
	std::string filename;
	unsigned long size;
	unsigned long crc;
	std::vector<unsigned long> checksums;
};

void load_rom_db(std::vector<RomInfo>& romDB, std::string fname)
{
	std::ifstream file(fname.c_str());
	if (file.fail())
	{
		std::cerr << "ERROR: " << fname << " doesn't exist." << std::endl;
		return;
	}

#if USE_REGEX == USE_REGEX_CXX11
	std::regex linePattern("\\[ (.*) \\] \\./(.*)");
	std::regex segPattern("[0-9a-fA-F]+");
	std::sregex_token_iterator itEnd;
	std::string line;
	while (std::getline(file, line))
	{
		std::smatch sm;
		if (std::regex_match(line, sm, linePattern) && sm.size() == 3)
		{
			RomInfo inf;
			inf.filename = sm[2];
			std::string segments = sm[1];
			std::sregex_token_iterator itSeg(segments.begin(), segments.end(), segPattern, 0);
			while (itSeg != itEnd)
			{
				//inf.checksums.push_back(std::stoul(*itSeg, nullptr, 16));
				inf.checksums.push_back(strtoul(itSeg->str().c_str(), NULL, 16));
				++ itSeg;
			}
			romDB.push_back(std::move(inf));
		}
	}
#elif USE_REGEX == USE_REGEX_BOOST
	boost::regex linePattern("\\[( [0-9a-fA-F]+)* \\] \\./(.*)");
	std::string line;
	while (std::getline(file, line))
	{
		boost::smatch sm;
		if (boost::regex_match(line, sm, linePattern))
		{
			for (int i = 0; i < sm.size(); i ++)
			{
				std::cout << i << ": " << sm[i] << std::endl;
				for (int j = 0; j < sm.captures(i).size(); j ++)
				{
					std::cout << i << "[" << j << "]: " << sm.captures(i)[j] << std::endl;
				}
			}
		}
	}
#elif USE_REGEX == USE_REGEX_XPRESSIVE
#endif
}

void load_bin_db(std::vector<BinInfo>& binDB, std::string fname)
{
	std::ifstream file(fname.c_str());
	if (file.fail())
	{
		std::cerr << "ERROR: " << fname << " doesn't exist." << std::endl;
		return;
	}

#if USE_REGEX == USE_REGEX_CXX11
	std::regex linePattern("(G[0-9]*\\.BIN) ([0-9a-fA-F]+) ([0-9a-fA-F]+) \\[ (.*) \\]");
	std::regex segPattern("[0-9a-fA-F]+");
	std::sregex_token_iterator itEnd;
	std::string line;
	while (std::getline(file, line))
	{
		std::smatch sm;
		if (std::regex_match(line, sm, linePattern) && sm.size() == 5)
		{
			BinInfo inf;
			inf.filename = sm[1];
			inf.crc = strtoul(sm.str(2).c_str(), NULL, 16);
			inf.size = strtoul(sm.str(3).c_str(), NULL, 16);
			std::string segments = sm[4];
			std::sregex_token_iterator itSeg(segments.begin(), segments.end(), segPattern, 0);
			while (itSeg != itEnd)
			{
				//inf.checksums.push_back(std::stoul(*itSeg, nullptr, 16));
				inf.checksums.push_back(strtoul(itSeg->str().c_str(), NULL, 16));
				++ itSeg;
			}
			binDB.push_back(std::move(inf));
		}
	}
#elif USE_REGEX == USE_REGEX_BOOST
#elif USE_REGEX == USE_REGEX_XPRESSIVE
#endif
}

void gen_rom_hash(RomHash& romHash, std::vector<RomInfo>& romDB)
{
	for (std::vector<RomInfo>::const_iterator itRom = romDB.cbegin(); itRom != romDB.cend(); ++ itRom)
	{
		for (std::vector<unsigned long>::const_iterator itChecksum = itRom->checksums.cbegin(); itChecksum != itRom->checksums.cend(); ++ itChecksum)
		{
			if (romHash.find(*itChecksum) == romHash.end())
			{
				romHash[*itChecksum] = std::vector<const RomInfo*>();
			}
			std::vector<const RomInfo*>& romList = romHash[*itChecksum];
			if (std::find(romList.begin(), romList.end(), &(*itRom)) == romList.end())
			{
				romList.push_back(&(*itRom));
			}
		}
	}
}

void match_roms(RomHash& romHash, std::vector<BinInfo>& binDB)
{
	for (std::vector<BinInfo>::const_iterator itBin = binDB.cbegin(); itBin != binDB.cend(); ++ itBin)
	{
		int noMatch = 0;
		std::map<const RomInfo*, int> romCoverage;
		for (std::vector<unsigned long>::const_iterator itChecksum = itBin->checksums.cbegin(); itChecksum != itBin->checksums.cend(); ++ itChecksum)
		{
			if (romHash.find(*itChecksum) == romHash.end())
			{
				noMatch ++;
			}
			else
			{
				std::vector<const RomInfo*>& romList = romHash[*itChecksum];
				for (std::vector<const RomInfo*>::const_iterator itRom = romList.cbegin(); itRom != romList.cend(); ++ itRom)
				{
					if (romCoverage.find(*itRom) == romCoverage.end())
					{
						romCoverage[*itRom] = 0;
					}
					romCoverage[*itRom] ++;
				}
			}
		}

		std::cout << itBin->filename << ": ";
		if (noMatch > 0)
		{
			std::cout << "NOMATCH=" << noMatch << " ";
		}

		int maxMatch = 0;
		for (std::map<const RomInfo*, int>::iterator itCoverage = romCoverage.begin(); itCoverage != romCoverage.cend(); ++ itCoverage)
		{
			if (itCoverage->second > maxMatch)
			{
				maxMatch = itCoverage->second;
			}
		}
		if (maxMatch > 0)
		{
			int maxMatched = 0;
			int minUnmatched = 9999;
			for (std::map<const RomInfo*, int>::iterator itCoverage = romCoverage.begin(); itCoverage != romCoverage.cend(); ++ itCoverage)
			{
				if (itCoverage->second == maxMatch)
				{
					int matched = 0, unmatched = 0;
					for (std::vector<unsigned long>::const_iterator itChecksum = itCoverage->first->checksums.cbegin(); itChecksum != itCoverage->first->checksums.cend(); ++ itChecksum)
					{
						if (std::find(itBin->checksums.cbegin(), itBin->checksums.cend(), *itChecksum) == itBin->checksums.cend())
						{
							unmatched ++;
						}
						else
						{
							matched ++;
						}
					}
					if (maxMatched < matched)
					{
						maxMatched = matched;
					}
					if (minUnmatched > unmatched)
					{
						minUnmatched = unmatched;
					}
				}
			}
			if (maxMatch == itBin->checksums.size())
			{
				if (minUnmatched == 0)
				{
					std::cout << "PERFECT ";
				}
				else
				{
					std::cout << "GOOD ";
				}
			}
			else
			{
				std::cout << "MATCH=" << maxMatch << "/" << itBin->checksums.size() << " ";
			}
			std::cout << "MatchFile=";
			for (std::map<const RomInfo*, int>::iterator itCoverage = romCoverage.begin(); itCoverage != romCoverage.cend(); ++ itCoverage)
			{
				if (itCoverage->second == maxMatch)
				{
					int matched = 0, unmatched = 0;
					for (std::vector<unsigned long>::const_iterator itChecksum = itCoverage->first->checksums.cbegin(); itChecksum != itCoverage->first->checksums.cend(); ++ itChecksum)
					{
						if (std::find(itBin->checksums.cbegin(), itBin->checksums.cend(), *itChecksum) == itBin->checksums.cend())
						{
							unmatched ++;
						}
						else
						{
							matched ++;
						}
					}
					if (unmatched == minUnmatched)
					{
						std::cout << "\"" << itCoverage->first->filename << "\"[" << matched << "/" << (matched + unmatched) << "], ";
					}
				}
			}
		}
		std::cout << std::endl;
	}
}

int main()
{
	std::vector<RomInfo> romDB;
	std::cout << "Loading Rom DataBase ..." << std::endl;
	load_rom_db(romDB, "nesinf.txt");

	std::vector<BinInfo> binDB;
	std::cout << "Loading Bin DataBase ..." << std::endl;
	load_bin_db(binDB, "vcdinf.txt");

	RomHash romHash;
	std::cout << "Generating Cache ..." << std::endl;
	gen_rom_hash(romHash, romDB);

	match_roms(romHash, binDB);

	return 0;
}