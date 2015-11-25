#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
#include <boost/crc.hpp>
#include <boost/format.hpp>

/*
G001:1942
OrigROM: 0010~A010 = A000
C960~CBA0 = 240
CBA0~16BA0 = A000
16BA0~18000 = 1460
CBA0 + 1460 = E000

G002:1943
OrigROM: 0010~20010 = 20000
CA70~CCB0 = 240
CCB0~2CCB0 = 20000
2CCB0~2E000 = 1350
CCB0+1350 = E000

G146:Donkey Kong Math
OrigROM: 0010~6010 = 6000
C710~C910 = 200
C910~16910 = A000
16910~17800 = EF0
C910+EF0 = D800

G145:Brush Roller
OrigROM: 0010~6010 = 6000
CAB0~CCB0 = 200
CCB0~16CB0 = A000
16CB0~18000 = 1350
CCB0+1350 = E000
*/

const char marker1[] = {'S','e','t',':','%','x','\0','\0','N','o','w',':','%','x','\0','\0','N','e','e','d',':','%','x','\0'};
const int marker1Size = sizeof(marker1);

const char marker2[] = "OSD buffer overflow\n";
const int marker2Size = sizeof(marker2);

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
	file.seekg(0, std::ios::beg);

	std::vector<char> buffer(size);
	if (file.read(buffer.data(), size))
	{
		const char* xstart = std::search(buffer.data(), buffer.data() + size, marker1, marker1 + marker1Size) + marker1Size;
		int xsize = size - 0xE000;
		if (xstart == NULL || xstart >= buffer.data() + size)
		{
			xstart = std::search(buffer.data(), buffer.data() + size, marker2, marker2 + marker1Size) + 0x200;
			if (xsize % blockSize != 0)
				xsize = size - 0xD800;
		}
		if (xstart == NULL || xstart >= buffer.data() + size || xsize <= 0 || xsize % blockSize != 0 || (xstart - buffer.data()) % 0x10 != 0)
		{
			std::cerr << "ERROR: " << fname << " " << xstart - buffer.data() << " " << xsize << std::endl;
			return;
		}
		boost::crc_32_type crcResult;
		crcResult.process_bytes(xstart, xsize);
		std::cout << fname << " " << crcResult.checksum() << " " << xsize << " [ ";
		for (int i = 0; i < xsize; i += blockSize)
		{
			boost::crc_32_type crcBlock;
			crcBlock.process_bytes(xstart + i, blockSize);
			std::cout << crcBlock.checksum() << " ";
		}
		std::cout << "]" << std::endl;
	}
}

void proc_files()
{
	for (int i = 1; i <= 300; i ++)
	{
		proc_file(str(boost::format("G%03d.BIN") % i));
	}
}

int main()
{
	proc_files();
	return 0;
}