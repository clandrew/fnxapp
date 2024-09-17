#include "pch.h"

using namespace Microsoft::WRL;

void VerifyHR(HRESULT hr)
{
	if (FAILED(hr))
	{
		__debugbreak();
	}
}

void PrintUsage()
{
	std::cout << "Usage: BitmapEmbedder [source] [dest pallette source file] [dest image source file] [dest image source file label name] [--halfsize] [--compile-offsets] [-add-transparency]\n";
	std::cout << "For example, \n";
	std::cout << "    BitmapEmbedder wormhole.bmp colors.s pixmap.s IMG\n";
	std::cout << "\n";
	std::cout << "--halfsize:           Optional parameter. Causes dest image to be half the size of the original.";
	std::cout << "--compile-offsets:    Optional parameter. Causes explicit compile offsets to be emitted for image data, adding additional ones where the data is longer than one bank.";
	std::cout << "--add-transparency:   Optional parameter. Inserts a color at palette index 0, and emits image data with no pixel of palette index 0.";
}

std::vector<unsigned char> MakeHalfsizeWithPadding(std::vector<unsigned char> indexedBuffer, int imageWidth, int imageHeight)
{
	// Assumption: this is a 1byte per pixel image.
	std::vector<unsigned char> result;

	int rowCount = 0;
	for (int y = 0; y < imageHeight; ++y)
	{
		if (y % 2 == 1)
			continue;

		std::vector<unsigned char> row;
		for (int x = 0; x < imageWidth; ++x)
		{
			if (x % 2 == 1)
				continue;

			int i = y * imageWidth + x;
			row.push_back(indexedBuffer[i]);
		}
		while (row.size() < imageWidth)
		{
			row.push_back(0);
		}

		result.insert(result.end(), row.begin(), row.end());
		rowCount++;
	}

	std::vector<unsigned char> emptyRow(imageWidth, 0);
	while (rowCount < imageHeight)
	{
		result.insert(result.end(), emptyRow.begin(), emptyRow.end());
		rowCount++;
	}

	return result;
}

std::vector<unsigned char> MakeHalfsize(std::vector<unsigned char> indexedBuffer, int imageWidth, int imageHeight)
{
	// Assumption: this is a 1byte per pixel image.
	std::vector<unsigned char> result;

	for (int i = 0; i < indexedBuffer.size(); ++i)
	{
		int x = i % imageWidth;
		int y = i / imageWidth;

		if (x % 2 == 1)
			continue;

		if (y % 2 == 1)
			continue;

		result.push_back(indexedBuffer[i]);
	}
	return result;
}

int main(int argc, void** argv)
{
	if (argc < 4)
	{
		PrintUsage();
		return 1;
	}

	std::string sourceFilenameCmdLine = (char*)argv[1];
	std::wstring sourceFilename(sourceFilenameCmdLine.begin(), sourceFilenameCmdLine.end());

	std::string destPaletteFilenameCmdLine = (char*)argv[2];
	std::wstring destPaletteFilename(destPaletteFilenameCmdLine.begin(), destPaletteFilenameCmdLine.end());

	std::string destImageFilenameCmdLine = (char*)argv[3];
	std::wstring destImageFilename(destImageFilenameCmdLine.begin(), destImageFilenameCmdLine.end());

	std::string destLabelCmdLine = (char*)argv[4];

	bool emitCompileOffsets = false;
	bool halfsize = false;
	bool addTransparency = false;
	for (int i = 5; i < argc; ++i)
	{
		std::string arg = (char*)argv[i];
		if (arg == "--halfsize")
		{
			halfsize = true;
		}
		else if (arg == "--compile-offsets")
		{
			emitCompileOffsets = true;
		}
		else if (arg == "--add-transparency")
		{
			addTransparency = true;
		}
	}

	ComPtr<IWICImagingFactory> m_wicImagingFactory;

	VerifyHR(CoInitialize(nullptr));

	VerifyHR(CoCreateInstance(
		CLSID_WICImagingFactory,
		NULL,
		CLSCTX_INPROC_SERVER,
		IID_IWICImagingFactory,
		(LPVOID*)&m_wicImagingFactory));

	ComPtr<IWICBitmapDecoder> decoder;
	VerifyHR(m_wicImagingFactory->CreateDecoderFromFilename(
		sourceFilename.c_str(),
		NULL,
		GENERIC_READ,
		WICDecodeMetadataCacheOnLoad, &decoder));

	ComPtr<IWICBitmapFrameDecode> spSource;
	VerifyHR(decoder->GetFrame(0, &spSource));

	ComPtr<IWICFormatConverter> spConverter;
	VerifyHR(m_wicImagingFactory->CreateFormatConverter(&spConverter));

	VerifyHR(spConverter->Initialize(
		spSource.Get(),
		GUID_WICPixelFormat8bppIndexed,
		WICBitmapDitherTypeNone,
		NULL,
		0.f,
		WICBitmapPaletteTypeMedianCut));

	UINT srcImageWidth, srcImageHeight;
	VerifyHR(spConverter->GetSize(&srcImageWidth, &srcImageHeight));

	std::vector<unsigned char> indexedBuffer;

	indexedBuffer.resize(srcImageWidth * srcImageHeight);
	VerifyHR(spConverter->CopyPixels(
		NULL,
		srcImageWidth,
		static_cast<UINT>(indexedBuffer.size()),
		reinterpret_cast<BYTE*>(indexedBuffer.data())));

	ComPtr<IWICPalette > spPalette;
	VerifyHR(m_wicImagingFactory->CreatePalette(&spPalette));
	VerifyHR(spConverter->CopyPalette(spPalette.Get()));

	UINT uiColorCount = 0;
	VerifyHR(spPalette->GetColorCount(&uiColorCount));

	std::vector<WICColor> colors;
	colors.resize(uiColorCount);
	UINT uiActualColorCount = 0;
	VerifyHR(spPalette->GetColors(uiColorCount, colors.data(), &uiActualColorCount));

	if (addTransparency)
	{
		WICColor transparentPlaceholder = 0x563412;
		colors.insert(colors.begin(), transparentPlaceholder);
	}

	{
		// Dump the palette
		std::wstring outputFile = destPaletteFilename;
		std::ofstream out(outputFile);
		out << "LUT_" << destLabelCmdLine << "_START\n";
		int colorIndex = 0;
		for (auto it = colors.begin(); it != colors.end() && colorIndex < 256; ++it)
		{
			UINT rgb = *it;

			int b = rgb & 0xFF;
			rgb >>= 8;
			int g = rgb & 0xFF;
			rgb >>= 8;
			int r = rgb & 0xFF;
			rgb >>= 8;

			out << ".byte $" 
				<< std::setfill('0') << std::setw(2) << std::hex << b << ", $" 
				<< std::setfill('0') << std::setw(2) << std::hex << g << ", $" 
				<< std::setfill('0') << std::setw(2) << std::hex << r << ", $00\n";

			++colorIndex;
		}
		int fillerColors = 256 - colors.size();
		for (int i = 0; i < fillerColors; ++i)
		{
			out << ".byte $FF, $00, $FF, 0\n";
		}

		out << "\n";
		out << "LUT_" << destLabelCmdLine << "_END = *";
	}

	if (halfsize)
	{
		indexedBuffer = MakeHalfsize(indexedBuffer, srcImageWidth, srcImageHeight);
	}
	{
		// Dump the image data
		std::wstring outputFile = destImageFilename;
		std::ofstream out(outputFile);

		out << "\n";

		int bank = 2;
		int lineLength = 16; // Emit 16 bytes per line
		int lineCount = 0;
		assert(indexedBuffer.size() % lineLength == 0);
		for (int i = 0; i < indexedBuffer.size(); i += lineLength)
		{
			if (emitCompileOffsets)
			{
				if (lineCount % 4096 == 0)
				{
					out << "* = $";
					if (lineCount == 0)
					{
						out << "0";
					}
					out << bank << "0000\n";
					bank++;
				}
			}
			if (lineCount == 0)
			{
				out << destLabelCmdLine << "_START = *\n";
			}

			int counter = 0;

			{
				out << ".byte ";
				bool firstInLine = true;

				for (int j = 0; j < lineLength; ++j)
				{
					int datum = (int)(indexedBuffer[i + j]);

					// Look up datum in remapped palette
					WICColor c = colors[datum];
					UINT remapper[]{
						0xff708800,
						0xff608010,
						0xff587000,
						0xff506000,
						0xffe0e0e8,
						0xfff8f8f8,
						0xffd0d0d0,
						0xff90a020,
						0xff58a0e0,
						0xff70b8f8,
						0xff4090d0,
						0xff98d8f8,
						0xffe8e8e8,
						0xffc0c0c0,
						0xffb8b8b8,
						0xffa8a8b0,
						0xff989898,
						0xff788080,
						0xff686868,
						0xff709000,
						0xff405000,
						0xff505050,
						0xff404040,
						0xff181818,
						0xff282828,
						0xff201000,
						0xff080000,
						0xff382800,
						0xff585858,
						0xff403000,
						0xff304000
					};

					int remappedDatum = datum;
					bool found = false;
					for (int j = 0; j < ARRAYSIZE(remapper); ++j)
					{
						if (c == remapper[j])
						{
							remappedDatum = j + 1;
							found = true;
							break;
						}
					}
					if (!found)
					{
						if (c == 0xff201008)
						{
							remappedDatum = 0x36;
							found = true;
						}
						else if (c == 0xff483800)
						{
							remappedDatum = 0x37;
							found = true;
						}
						else if (c == 0xff584818)
						{
							remappedDatum = 0x38;
							found = true;
						}
						else if (c == 0xff203000)
						{
							remappedDatum = 0x39;
							found = true;
						}
						else if (c == 0xff887000)
						{
							remappedDatum = 0x3A;
							found = true;
						}
						else if (c == 0xff806800)
						{
							remappedDatum = 0x3B;
							found = true;
						}
						else if (c == 0xff786000)
						{
							remappedDatum = 0x3C;
							found = true;
						}
						else if (c == 0xff685000)
						{
							remappedDatum = 0x3D;
							found = true;
						}
						else if (c == 0xff503800)
						{
							remappedDatum = 0x3E;
							found = true;
						}
						else if (c == 0xff685018)
						{
							remappedDatum = 0x3F;
							found = true;
						}
						else if (c == 0xff000000)
						{
							remappedDatum = 0x0;
							found = true;
						}
						else if (c == 0xffff00ff)
						{
							remappedDatum = 0x0;
							found = true;
						}
						//
					}

					if (!found)
					{
						__debugbreak();
					}

					if (addTransparency)
					{
						datum++;
					}
					if (!firstInLine)
					{
						out << ", ";
					}
					out << "$" << std::setfill('0') << std::setw(2) << std::hex << remappedDatum;
					firstInLine = false;
					counter++;
				}
				out << "\n";
			}

			lineCount++;
		}

		out << destLabelCmdLine << "_END = *";
	}
}
