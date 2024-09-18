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

byte RemapColorToArbitraryPalette(WICColor c)
{
	switch (c)
	{
		// On Foenix platform, transparency is reserved for index 0. Black and magenta are used for transparency here
		case 0xff000000: return 0x0;
		case 0xffff00ff: return 0x0;
		case 0xffffffff: return 0x0;

		// For tileset
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

		case 0xff201000: return 0x1A;
		case 0xff080000: return 0x1B;
		case 0xff382800: return 0x1C;
		case 0xff585858: return 0x1D;
		case 0xff403000: return 0x1E;
		case 0xff304000: return 0x1F;

		// Tileset, cont'd
		case 0xff201008: return 0x20;
		case 0xff483800: return 0x21;
		case 0xff584818: return 0x22;
		case 0xff203000: return 0x23;
		case 0xff887000: return 0x24;
		case 0xff806800: return 0x25;

		case 0xff786000: return 0x26;
		case 0xff685000: return 0x27;
		case 0xff503800: return 0x28;
		case 0xff685018: return 0x29;

			// Sprite
		case 0xffa87038: return 0x2A;
		case 0xff005008: return 0x2B;
		case 0xffe0a070: return 0x2C;
		case 0xffd09058: return 0x2D;

		case 0xff485860: 
		case 0xff435259:
			return 0x2E;

		case 0xffa8b8c8: 
		case 0xff9cabba:
			return 0x2F;

		case 0xff788090: 
		case 0xff6c7381:
			return 0x30;

		case 0xff086018: return 0x31;
		case 0xff002068: return 0x32;
		case 0xff004090: return 0x33;
		case 0xff402800: return 0x34;
		case 0xff583800: return 0x35;
		case 0xff703800: return 0x36;

		// This is the "fake black." mapped to 2 different possible values apparently depending on where it was captured from
		case 0xff081008: 
		case 0xff070e07: 
			return 0x37;

		// HUD colors
		case 0xff585800: return 0x38;
		case 0xffc8c000: return 0x39;
		case 0xfff8f800: return 0x3A;
		case 0xff808000: return 0x3B;
		case 0xffa8f8f8: return 0x3C;
		case 0xff40b8f8: return 0x3D;
		case 0xff0000c0: return 0x3E;


		default:
		{
			assert(false); // Unrecognized color
			return 0x0;
		}
	}
	
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

	std::string destImageFilenameCmdLine = (char*)argv[2];
	std::wstring destImageFilename(destImageFilenameCmdLine.begin(), destImageFilenameCmdLine.end());

	std::string destLabelCmdLine = (char*)argv[3];

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
					
					int x = i % srcImageWidth + j;
					int y = i / srcImageWidth;

					datum = RemapColorToArbitraryPalette(c);

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
	}
}
