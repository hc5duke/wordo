require 'rmagick'

color = Magick::Pixel.new(9000, 9000, 9000, 65535)
#Dir['*.png'].each do |name|
['1000.png', '133.png', '371.png'].each do |name|
  white = Magick::Image.read("./#{name}").first
  black = white
  min = black.export_pixels(0, 0, 24, 14, 'I').min
  if min > 20_000
    24.times.each do |col|
      pixels = black.export_pixels(0, col, 24, 1, 'I')
      max = pixels.max
      if max > 60_000
        index = pixels.index(max) + col * 24
        col = index % 24
        row = index / 24
        black = black.color_floodfill(col, row, color)
      end
    end
  end
  black.quantize(8, Magick::GRAYColorspace).write("./black_#{name}")
end
