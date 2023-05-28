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
	std::cout << "Usage: BitmapEmbedder [source] [dest pallette source file] [dest image source file]\n";
	std::cout << "For example, \n";
	std::cout << "    BitmapEmbedder wormhole.bmp colors.s pixmap.s\n";
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

	assert(srcImageWidth == 640);

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

	// Only 255 actual colors are allowed, because you need to make room for transparency
	WICColor magenta = 0xFF00FF;
	colors.insert(colors.begin(), magenta);

	std::vector<byte> result;
	result.resize(srcImageWidth * srcImageHeight);

	// Zero out
	for (size_t i = 0; i < result.size(); ++i)
	{
		result[i] = 0;
	}

	{
		// Dump the palette
		std::wstring outputFile = destPaletteFilename;
		std::ofstream out(outputFile);
		out << "LUT_START\n";
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
		out << "LUT_END = *";
	}
	{
		std::wstring outputFile = destImageFilename;
		std::ofstream out(outputFile);

		out << "\n";

		int bank = 2;
		int lineLength = 16;
		int lineCount = 0;
		assert(result.size() % lineLength == 0);
		for (int i = 0; i < result.size(); i += lineLength)
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
			if (lineCount == 0)
			{
				out << "IMG_START = *\n";
			}

			out << ".byte ";

			for (int j = 0; j < lineLength; ++j)
			{
				int datum = (int)(indexedBuffer[i + j]);
				datum++; // Allow for magenta
				out << "$" << std::setfill('0') << std::setw(2) << std::hex << datum;
				if (j < lineLength - 1)
				{
					out << ", ";
				}
			}
			out << "\n";

			lineCount++;
		}

		out << "IMG_END = *";
	}
}
