#include <iostream>
#include <fstream>
#include <vector>
#include <boost/crc.hpp>

/*
find . -iname *.nes | while read FNAME; do ./rominfo "$FNAME"; done 1>../nesinf.txt 2>../neserr.txt
*/

const int blockSize = 8 * 1024;

void proc_file(std::string fname)
{
	std::cout << std::hex;
	std::cerr << std::hex;

	std::ifstream file(fname.c_str(), std::ios::binary | std::ios::ate);
	if (file.fail())
	{
		std::cerr << "ERROR: " << fname << " doesn't exist." << std::endl;
		return;
	}
	std::streamsize size = file.tellg();
	int blks = (size - 0x10) / blockSize;
	if (size <= 0x10 || blks <= 0 || (size - 0x10) % blockSize != 0)
	{
		std::cerr << "ERROR: " << fname << " size wrong: " << size << std::endl;
		return;
	}

	file.seekg(0x10, std::ios::beg);
	std::vector<char> buffer(blockSize);
	std::cout << "[ ";
	for (int i = 0; i < blks; i ++)
	{
		if (file.read(buffer.data(), blockSize))
		{
			boost::crc_32_type crcBlock;
			crcBlock.process_bytes(buffer.data(), blockSize);
			std::cout << crcBlock.checksum() << " ";
		}
	}
	std::cout << "] " << fname << std::endl;
}

int main(int argc, char** argv)
{
	if (argc > 1)
	{
		for (int i = 1; i < argc; i ++)
		{
			proc_file(argv[i]);
		}
	}
	return 0;
}