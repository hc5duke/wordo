require 'rmagick'

screen_width = 640
screen_height = 960
offset_top = 130
num_tiles = 15
tile_offset_left = 6
tile_offset_right = 12
tile_offset_top = 9
tile_offset_bottom = 9
tile_size = (screen_width / num_tiles).to_i
tile_width = tile_size - tile_offset_left - tile_offset_right
tile_height = tile_size - tile_offset_top - tile_offset_bottom
colorspace = 3

count = 0

file_names = Dir['./tmp/boards/*.png']
file_names.each do |file_name|
  image = Magick::Image.read(file_name).first.resize(screen_width, screen_height)
  num_tiles.times.each do |row|
    top = offset_top + row * screen_width / num_tiles + tile_offset_top
    num_tiles.times.map do |col|
      left = col * screen_width / num_tiles + tile_offset_left
      img = image.crop(left.to_i, top.to_i, tile_width, tile_height)
      img.write("./tmp/train2/#{count}.png")
      count += 1
    end
  end
end
