require 'rmagick'

color_white = Magick::Pixel.new(65535, 65535, 65535, 65535)
color_black = Magick::Pixel.new(0, 0, 0, 65535)

tile_size = 12
bottom_corner_size = 5

Dir['./train2/*.png'].each do |name|
  next if /black/ === name
  black = Magick::Image.read("./#{name}").first.resize(tile_size, tile_size)
  black.crop(0, tile_size - bottom_corner_size, tile_size, bottom_corner_size).color_histogram
  if black.export_pixels(0, 0, tile_size, tile_size - bottom_corner_size, 'I').min > 20_000
    tile_size.times.each do |col|
      black.export_pixels(0, col, tile_size, 1, 'I').each_with_index do |pixel, index|
        color = pixel > 60_000 ? color_black : color_white
        index += col * tile_size
        co = index % tile_size
        ro = index / tile_size
        black = black.color_point(co, ro, color)
      end
    end
  else
    tile_size.times.each do |col|
      black.export_pixels(0, col, tile_size, 1, 'I').each_with_index do |pixel, index|
        color = pixel < 20_000 ? color_black : color_white
        index += col * tile_size
        co = index % tile_size
        ro = index / tile_size
        black = black.color_point(co, ro, color)
      end
    end
  end
  black.quantize(4, Magick::GRAYColorspace).write("./black_#{name.split('/').last}")
end
