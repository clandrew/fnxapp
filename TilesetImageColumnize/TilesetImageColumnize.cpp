// TilesetImageColumnize.cpp : This file contains the 'main' function. Program execution begins and ends there.
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

int main()
{
	std::wstring sourceFilename = L"D:\\repos\\fnxapp\\demo\\tinyvicky\\rsrc\\tileset.png";
	std::wstring destFilename = L"D:\\repos\\fnxapp\\demo\\tinyvicky\\rsrc\\tileset_formatted.png";

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
		GUID_WICPixelFormat32bppRGB,
		WICBitmapDitherTypeNone,
		NULL,
		0.f,
		WICBitmapPaletteTypeMedianCut));

	UINT srcImageWidth, srcImageHeight;
	VerifyHR(spConverter->GetSize(&srcImageWidth, &srcImageHeight));

	int tileSize = 16;
	int srcImageWidthInTiles = srcImageWidth / tileSize;
	int srcImageHeightInTiles = srcImageHeight / tileSize;
	int numTiles = srcImageWidthInTiles * srcImageHeightInTiles;
	int destWidth = tileSize;
	int destHeight = tileSize * numTiles;


	ComPtr<IWICBitmapEncoder> encoder;
	VerifyHR(m_wicImagingFactory->CreateEncoder(GUID_ContainerFormatPng, NULL, &encoder));

	ComPtr<IWICStream> stream;
	VerifyHR(m_wicImagingFactory->CreateStream(&stream));

	VerifyHR(stream->InitializeFromFilename(destFilename.c_str(), GENERIC_WRITE));
	VerifyHR(encoder->Initialize(stream.Get(), WICBitmapEncoderNoCache));

	ComPtr<IWICBitmap> destWicBitmap;
	VerifyHR(m_wicImagingFactory->CreateBitmap(
		destWidth,
		destHeight,
		GUID_WICPixelFormat32bppRGB, WICBitmapCacheOnDemand, &destWicBitmap));

	std::vector<UINT> sourceBuffer;
	int sourceBufferStride = srcImageWidth * 4;
	int sourceBufferSize = sourceBufferStride * srcImageHeight;
	WICRect srcLockRect{};
	srcLockRect.X = 0;
	srcLockRect.Y = 0;
	srcLockRect.Width = srcImageWidth;
	srcLockRect.Height = srcImageHeight;
	sourceBuffer.resize(sourceBufferSize);
	VerifyHR(spConverter->CopyPixels(&srcLockRect, sourceBufferStride, sourceBufferSize, reinterpret_cast<BYTE*>(sourceBuffer.data())));

	{
		// Lock scope

		ComPtr<IWICBitmapLock> destWicBitmapLock;
		VerifyHR(destWicBitmap->Lock(nullptr, WICBitmapLockWrite, &destWicBitmapLock));
		UINT lockedSizeDest;
		BYTE* lockedDataByte;
		VerifyHR(destWicBitmapLock->GetDataPointer(&lockedSizeDest, &lockedDataByte));
		UINT* lockedDataDest = reinterpret_cast<UINT*>(lockedDataByte);

		int destIndex = 0;
		for (int tileY = 0; tileY < srcImageHeightInTiles; ++tileY)
		{
			for (int tileX = 0; tileX < srcImageWidthInTiles; ++tileX)
			{
				int srcX = tileX * tileSize;
				int srcY = tileY * tileSize;
				int srcIndex = (srcY * srcImageWidth) + srcX;

				for (int y = 0; y < tileSize; ++y)
				{
					for (int x = 0; x < tileSize; ++x)
					{
						UINT pixel = sourceBuffer[srcIndex + x];
						lockedDataDest[destIndex + x] = pixel;
					}
					srcIndex += srcImageWidth;
					destIndex += tileSize;
				}
			}
		}
	}

	ComPtr<IWICBitmapFrameEncode> frameEncode;
	ComPtr<IPropertyBag2> wicPropertyBag;
	VerifyHR(encoder->CreateNewFrame(&frameEncode, &wicPropertyBag));

	VerifyHR(frameEncode->Initialize(wicPropertyBag.Get()));

	VerifyHR(frameEncode->SetSize(destWidth, destHeight));

	VerifyHR(frameEncode->SetResolution(96, 96));

	WICPixelFormatGUID destFormat = GUID_WICPixelFormat32bppRGB;
	VerifyHR(frameEncode->SetPixelFormat(&destFormat));

	VerifyHR(frameEncode->WriteSource(destWicBitmap.Get(), nullptr));

	VerifyHR(frameEncode->Commit());

	VerifyHR(encoder->Commit());

	VerifyHR(stream->Commit(STGC_DEFAULT));
}