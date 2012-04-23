require 'rmagick'

color_white = Magick::Pixel.new(65535, 65535, 65535, 65535)
color_black = Magick::Pixel.new(0, 0, 0, 65535)
Dir['*.png'].each do |name|
  next if /black/ === name
  black = Magick::Image.read("./#{name}").first
  black.crop(0, 14, 24, 10).color_histogram
  [1,2,3].zip([2,3,4]).map{|a,b|a*b}
  min = black.export_pixels(0, 0, 24, 14, 'I').min
  if min > 20_000
    24.times.each do |col|
      black.export_pixels(0, col, 24, 1, 'I').each_with_index do |pixel, index|
        if pixel > 60_000
          color = color_black
        else
          color = color_white
        end
        index += col * 24
        co = index % 24
        ro = index / 24
        black = black.color_point(co, ro, color)
      end
    end
  else
    24.times.each do |col|
      black.export_pixels(0, col, 24, 1, 'I').each_with_index do |pixel, index|
        if pixel < 20_000
          color = color_black
        else
          color = color_white
        end
        index += col * 24
        co = index % 24
        ro = index / 24
        black = black.color_point(co, ro, color)
      end
    end
  end
  black.quantize(4, Magick::GRAYColorspace).write("./black_#{name}")
end
