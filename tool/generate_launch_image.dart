// Generates dark launch images for iOS splash screen.
// Run: dart run tool/generate_launch_image.dart

import 'dart:io';
import 'dart:typed_data';

void main() {
  // Generate a 1x1 dark PNG that iOS will scale/tile
  // Color: #0A0A1A (matches app background)
  final png = _createSolidPng(1, 1, 10, 10, 26);

  final basePath = 'ios/Runner/Assets.xcassets/LaunchImage.imageset';
  File('$basePath/LaunchImage.png').writeAsBytesSync(png);
  File('$basePath/LaunchImage@2x.png').writeAsBytesSync(png);
  File('$basePath/LaunchImage@3x.png').writeAsBytesSync(png);
  print('Launch images generated (dark background #0A0A1A)');
}

Uint8List _createSolidPng(int w, int h, int r, int g, int b) {
  // Minimal valid PNG: 1x1 pixel
  final out = BytesBuilder();

  // PNG signature
  out.add([137, 80, 78, 71, 13, 10, 26, 10]);

  // IHDR chunk
  final ihdr = BytesBuilder();
  ihdr.add(_uint32(w)); // width
  ihdr.add(_uint32(h)); // height
  ihdr.add([8]); // bit depth
  ihdr.add([2]); // color type (RGB)
  ihdr.add([0]); // compression
  ihdr.add([0]); // filter
  ihdr.add([0]); // interlace
  _writeChunk(out, 'IHDR', ihdr.toBytes());

  // IDAT chunk - raw pixel data with zlib wrapper
  final rawData = BytesBuilder();
  for (int y = 0; y < h; y++) {
    rawData.addByte(0); // filter: none
    for (int x = 0; x < w; x++) {
      rawData.add([r, g, b]);
    }
  }
  final compressed = _deflateRaw(rawData.toBytes());
  _writeChunk(out, 'IDAT', compressed);

  // IEND chunk
  _writeChunk(out, 'IEND', Uint8List(0));

  return out.toBytes();
}

Uint8List _uint32(int value) {
  return Uint8List.fromList([
    (value >> 24) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 8) & 0xFF,
    value & 0xFF,
  ]);
}

void _writeChunk(BytesBuilder out, String type, Uint8List data) {
  out.add(_uint32(data.length));
  final typeBytes = type.codeUnits;
  out.add(typeBytes);
  out.add(data);

  // CRC32
  final crcData = BytesBuilder();
  crcData.add(typeBytes);
  crcData.add(data);
  out.add(_uint32(_crc32(crcData.toBytes())));
}

Uint8List _deflateRaw(Uint8List data) {
  // Minimal zlib: header + stored block + adler32
  final out = BytesBuilder();
  out.add([0x78, 0x01]); // zlib header (deflate, no dict)

  // Stored block (no compression)
  final len = data.length;
  out.addByte(1); // BFINAL=1, BTYPE=00 (stored)
  out.add([len & 0xFF, (len >> 8) & 0xFF]);
  out.add([(~len) & 0xFF, ((~len) >> 8) & 0xFF]);
  out.add(data);

  // Adler32
  int a = 1, b2 = 0;
  for (final byte in data) {
    a = (a + byte) % 65521;
    b2 = (b2 + a) % 65521;
  }
  final adler = (b2 << 16) | a;
  out.add(_uint32(adler));

  return out.toBytes();
}

int _crc32(Uint8List data) {
  var crc = 0xFFFFFFFF;
  for (final byte in data) {
    crc ^= byte;
    for (var i = 0; i < 8; i++) {
      if ((crc & 1) != 0) {
        crc = (crc >> 1) ^ 0xEDB88320;
      } else {
        crc >>= 1;
      }
    }
  }
  return crc ^ 0xFFFFFFFF;
}
