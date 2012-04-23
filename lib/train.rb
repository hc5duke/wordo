require 'rmagick'
require 'ai4r'

# Train the network
puts "Training the network, please wait."
# types = [ '_blank', '_dl', '_dw', '_tl', '_tw' ] + ('a'..'z').to_a
types = ('a'..'z').to_a
@image_size = 12
# Create a network with 256 inputs, and 31 outputs
# blank, tw, tl, dw, dl, a-z = 31
net = Ai4r::NeuralNetwork::Backpropagation.new([ 2 * @image_size, types.count ])
images = {}
pix = {}

def pix_from_image(image)
  image_h = image.resize(@image_size, 1)
  image_v = image.resize(1, @image_size)
  pixels  = image_h.export_pixels(0, 0, image_h.columns, image_h.rows, "I")
  pixels += image_v.export_pixels(0, 0, image_v.columns, image_v.rows, "I")
  pixels.map{ |pixel| pixel / 65_536.0 }
end

100.times do |t|
  puts "*" * 80
  puts t
  types.each_with_index do |type, index|
    file_names = Dir["./tmp/train1/#{type}/*.png"]
    puts "Training #{type} - #{file_names.length} files"
    # expected output
    zeros = [0] * types.count
    zeros[index] = 1

    # Load training data
    file_names.each_with_index do |file_name, file_index|
      if !pix[file_name]
        image          = (images[file_name]   ||= Magick::Image.read(file_name).first)
        pix[file_name] = pix_from_image(image)
      end
      net.train(pix[file_name], zeros)
    end
  end
end

#image = images.values[rand(images.count)]
count = 0
images.each do |name, image|
  pixels = pix_from_image(image)
  evaled = net.eval(pixels)
  if name.split('/')[3] != types[evaled.index(evaled.max)]
    puts [name.split('/')[3], types[evaled.index(evaled.max)]]
    count += 1
  end
end and count
