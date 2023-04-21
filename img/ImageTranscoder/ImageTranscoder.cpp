// ImageTranscoder.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include "pch.h"

using namespace Microsoft::WRL;

void VerifyHR(HRESULT hr)
{
	if (FAILED(hr))
	{
		__debugbreak();
	}
}

int main(int argc, void** argv)
{
	std::wstring filename = L"D:\\repos\\fnxapp\\img\\rsrc\\wormhole.bmp";

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
		filename.c_str(),
		NULL,
		GENERIC_READ,
		WICDecodeMetadataCacheOnLoad, &decoder));

	ComPtr<IWICBitmapFrameDecode> spSource;
	VerifyHR(decoder->GetFrame(0, &spSource));

	ComPtr<IWICFormatConverter> spConverter;
	VerifyHR(m_wicImagingFactory->CreateFormatConverter(&spConverter));

	VerifyHR(spConverter->Initialize(
		spSource.Get(),
		GUID_WICPixelFormat32bppPBGRA,
		WICBitmapDitherTypeNone,
		NULL,
		0.f,
		WICBitmapPaletteTypeMedianCut));

	UINT srcImageWidth, srcImageHeight;
	VerifyHR(spConverter->GetSize(&srcImageWidth, &srcImageHeight));

	assert(srcImageWidth == 640);

	std::vector<UINT> rgbBuffer;

	rgbBuffer.resize(srcImageWidth * srcImageHeight);
	VerifyHR(spConverter->CopyPixels(
		NULL,
		srcImageWidth * sizeof(UINT),
		static_cast<UINT>(rgbBuffer.size()) * sizeof(UINT),
		reinterpret_cast<BYTE*>(rgbBuffer.data())));

	// Figure out the set of unique colors
	std::set<UINT> pallette;
	for (int i = 0; i < srcImageWidth * srcImageHeight; ++i)
	{
		pallette.insert(rgbBuffer[i]);
	}

	std::vector<byte> result;
	int trancodedDataSize = (srcImageWidth * srcImageHeight);
	result.resize(trancodedDataSize);

	// Zero out
	for (size_t i = 0; i < result.size(); ++i)
	{
		result[i] = 0;
	}

	int resultIndex = 0;
	for (int y = 0; y < srcImageHeight; ++y)
	{
		for (int x = 0; x < srcImageWidth; ++x)
		{
			UINT srcRgb = rgbBuffer[(y * srcImageWidth) + x];

			// Look up result in pallette
			auto it = pallette.find(srcRgb);
			int color = std::distance(pallette.begin(), it);
			result[resultIndex] = color;
			++resultIndex;
		}
	}
	{
		std::string outputFile = "D:\\repos\\fnxapp\\img\\rsrc\\colors.s";
		std::ofstream out(outputFile);
		out << "LUT_START\n";
		for (auto it = pallette.begin(); it != pallette.end(); ++it)
		{
			UINT rgb = *it;

			int b = rgb & 0xFF;
			rgb >>= 8;
			int g = rgb & 0xFF;
			rgb >>= 8;
			int r = rgb & 0xFF;
			rgb >>= 8;

			out << ".byte " << r << ", " << g << ", " << b << ", 0\n";
		}
		int fillerColors = 256 - pallette.size();
		for (int i = 0; i < fillerColors; ++i)
		{
			out << ".byte 255, 0, 255, 0\n";
		}

		out << "\n";
		out << "LUT_END = *";
	}
	{
		std::string outputFile = "D:\\repos\\fnxapp\\img\\rsrc\\pixmap.s";
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
				out << (int)(result[i + j]);
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
