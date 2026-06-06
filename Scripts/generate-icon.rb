#!/usr/bin/env ruby
# Generates a simple placeholder App Store icon. Replace before final submission.

require "zlib"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
ICONSET = File.join(ROOT, "Assets", "AppIcon.appiconset")
ICNS_ICONSET = File.join(ROOT, "Assets", "NextBuild.iconset")
FileUtils.mkdir_p(ICONSET)
FileUtils.rm_rf(ICNS_ICONSET)
FileUtils.mkdir_p(ICNS_ICONSET)

def png_chunk(type, data)
  [data.bytesize].pack("N") + type + data + [Zlib.crc32(type + data)].pack("N")
end

def write_png(path, size)
  rows = +""
  size.times do |y|
    rows << 0
    size.times do |x|
      nx = x.to_f / [size - 1, 1].max
      ny = y.to_f / [size - 1, 1].max
      rounded = [x, y, size - 1 - x, size - 1 - y].min
      alpha = rounded < size * 0.08 ? (rounded / (size * 0.08) * 255).round : 255

      r = (12 + 30 * nx).round
      g = (105 + 60 * (1.0 - ny)).round
      b = (112 + 50 * ny).round

      if x > size * 0.32 && x < size * 0.68 && y > size * 0.28 && y < size * 0.72
        r = [r + 210, 255].min
        g = [g + 210, 255].min
        b = [b + 210, 255].min
      end

      rows << r << g << b << alpha
    end
  end

  ihdr = [size, size, 8, 6, 0, 0, 0].pack("NNCCCCC")
  data = "\x89PNG\r\n\x1a\n".b
  data << png_chunk("IHDR", ihdr)
  data << png_chunk("IDAT", Zlib::Deflate.deflate(rows))
  data << png_chunk("IEND", "")
  File.binwrite(path, data)
end

[
  ["icon_16x16.png", 16],
  ["icon_16x16@2x.png", 32],
  ["icon_32x32.png", 32],
  ["icon_32x32@2x.png", 64],
  ["icon_128x128.png", 128],
  ["icon_128x128@2x.png", 256],
  ["icon_256x256.png", 256],
  ["icon_256x256@2x.png", 512],
  ["icon_512x512.png", 512],
  ["icon_512x512@2x.png", 1024],
].each do |filename, size|
  write_png(File.join(ICONSET, filename), size)
  write_png(File.join(ICNS_ICONSET, filename), size)
end

contents = <<~JSON
{
  "images" : [
    { "filename" : "icon_16x16.png", "idiom" : "mac", "scale" : "1x", "size" : "16x16" },
    { "filename" : "icon_16x16@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "16x16" },
    { "filename" : "icon_32x32.png", "idiom" : "mac", "scale" : "1x", "size" : "32x32" },
    { "filename" : "icon_32x32@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "32x32" },
    { "filename" : "icon_128x128.png", "idiom" : "mac", "scale" : "1x", "size" : "128x128" },
    { "filename" : "icon_128x128@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "128x128" },
    { "filename" : "icon_256x256.png", "idiom" : "mac", "scale" : "1x", "size" : "256x256" },
    { "filename" : "icon_256x256@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "256x256" },
    { "filename" : "icon_512x512.png", "idiom" : "mac", "scale" : "1x", "size" : "512x512" },
    { "filename" : "icon_512x512@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "512x512" }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON

File.write(File.join(ICONSET, "Contents.json"), contents)
system("iconutil", "-c", "icns", ICNS_ICONSET, "-o", File.join(ROOT, "Assets", "NextBuild.icns"))
