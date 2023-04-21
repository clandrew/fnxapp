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

	std::string outputFile = "D:\\repos\\fnxapp\\img\\rsrc\\pixmap.s";
	std::ofstream out(outputFile);

	out << "\n";
	out << "* = $020000\n";
	out << "IMG_START = *\n";

	// Output the result as hex directives. Hex pseudo-op is limited to 64 characters, or 32 bytes; need to pick lineLength <= 32
	int lineLength = 16;
	assert(result.size() % lineLength == 0);
	for (int i = 0; i < result.size(); i += lineLength)
	{
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
	}
}
