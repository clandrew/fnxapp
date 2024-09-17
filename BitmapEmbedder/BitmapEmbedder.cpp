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

byte RemapColorToArbitraryPalette(WICColor c)
{
	switch (c)
	{
		// On Foenix platform, transparency is reserved for index 0. Black and magenta are used for transparency here
		case 0xff000000: return 0x0;
		case 0xffff00ff: return 0x0;

		case 0xff708800: return 0x1;
		case 0xff608010: return 0x2;
		case 0xff587000: return 0x3;
		case 0xff506000: return 0x4;
		case 0xffe0e0e8: return 0x5;
		case 0xfff8f8f8: return 0x6;
		case 0xffd0d0d0: return 0x7;
		case 0xff90a020: return 0x8;
		case 0xff58a0e0: return 0x9;
		case 0xff70b8f8: return 0xA;
		case 0xff4090d0: return 0xB;
		case 0xff98d8f8: return 0xC;
		case 0xffe8e8e8: return 0xD;
		case 0xffc0c0c0: return 0xE;
		case 0xffb8b8b8: return 0xF;
		case 0xffa8a8b0: return 0x10;
		case 0xff989898: return 0x11;
		case 0xff788080: return 0x12;
		case 0xff686868: return 0x13;
		case 0xff709000: return 0x14;
		case 0xff405000: return 0x15;
		case 0xff505050: return 0x16;
		case 0xff404040: return 0x17;
		case 0xff181818: return 0x18;
		case 0xff282828: return 0x19;

		case 0xff201000: return 0x20;
		case 0xff080000: return 0x21;
		case 0xff382800: return 0x22;
		case 0xff585858: return 0x23;
		case 0xff403000: return 0x24;
		case 0xff304000: return 0x25;
			
		// Sprite
		case 0x402800: return 0x26;
		case 0x583800: return 0x27;
		case 0x703800: return 0x28;
		case 0x081008: return 0x29;
		case 0xa87038: return 0x2A;
		case 0x005008: return 0x2B;
		case 0xe0a070: return 0x2C;
		case 0xd09058: return 0x2D;
		case 0x485860: return 0x2E;
		case 0xa8b8c8: return 0x2F;
		case 0x788090: return 0x30;
		case 0x086018: return 0x31;
		case 0x002068: return 0x32;
		case 0x004090: return 0x33;

		// 34 and 35 unused for some reason.

		// Appears in tileset but not in reference image
		case 0xff201008: return 0x36;
		case 0xff483800: return 0x37;
		case 0xff584818: return 0x38;
		case 0xff203000: return 0x39;
		case 0xff887000: return 0x3A;
		case 0xff806800: return 0x3B;
		case 0xff786000: return 0x3C;
		case 0xff685000: return 0x3D;
		case 0xff503800: return 0x3E;
		case 0xff685018: return 0x3F;

		// HUD should be appended at the end. HUD uses its own dedicated LUT currently, 
		// but we could put it onto the same LUT because we have the luxury of 256 colors.


		default:
		{
			assert(false); // Unrecognized color
			return 0x0;
		}
	}

/*

.byte $08, $50, $00, $00	; $25
.byte $70, $a0, $e0, $00	; $26
.byte $58, $90, $d0, $00	; $27
.byte $60, $58, $48, $00	; $28
.byte $c8, $b8, $a8, $00	; $29
.byte $90, $80, $78, $00	; $2A
.byte $18, $60, $08, $00	; $2B
.byte $68, $20, $00, $00	; $2C
.byte $90, $40, $00, $00	; $2D

; For HUD
.byte $f8, $f8, $f8, $00	; $2E
.byte $00, $58, $58, $00	; $2F
.byte $00, $c0, $c8, $00	; $30
.byte $00, $f8, $f8, $00	; $31
.byte $00, $80, $80, $00	; $32
.byte $f8, $f8, $a8, $00	; $33
.byte $f8, $b8, $40, $00	; $34
.byte $c0, $00, $00, $00	; $35
*/
	
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

					WICColor c = colors[datum]; // 0-0x35

					datum = RemapColorToArbitraryPalette(c);

					if (addTransparency)
					{
						datum++;
					}
					if (!firstInLine)
					{
						out << ", ";
					}
					out << "$" << std::setfill('0') << std::setw(2) << std::hex << datum;
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
