#!/usr/bin/env ruby

require 'rubygems'
require 'RMagick'
require 'pp'


INPUTFILE = ARGV[0]

if ARGV.length > 1 then 
  OUTPUTFILE = ARGV[1]
else 
  OUTPUTFILE = File.basename INPUTFILE.gsub(/\.[^.]*$/, ".gif")
end

OUTPUTEXT = File.extname OUTPUTFILE

puts "Test: #{OUTPUTEXT}"

TILE_COLS = 4
TILE_ROWS = 4

img = Magick::Image.read(INPUTFILE)[0]
pp img

COMP = case OUTPUTEXT
         when /jpg$|jpeg$/i
           Magick::LosslessJPEGCompression
         when /png$|mng$/i
           Magick::ZipCompression
         else
           nil
       end

if OUTPUTEXT.casecmp ".gif" then
  img = img.quantize(number_colors=256, colorspace=Magick::RGBColorspace, dither=Magick::RiemersmaDitherMethod, tree_depth=0)
end

TILE_WIDTH = img.columns/TILE_COLS
TILE_HEIGHT = img.rows/TILE_ROWS

# create a new empty image to composite the tiles upon:
new_img = Magick::Image.new(img.columns, img.rows)

# tiles will be an array of Image objects


tiles = (TILE_COLS * TILE_ROWS).times.inject(Magick::ImageList.new) do |arr, idx|
  arr << Magick::Image.constitute(TILE_WIDTH, TILE_HEIGHT, 'RGB',
               img.dispatch( idx%TILE_COLS * TILE_WIDTH, 
                             idx/TILE_COLS * TILE_HEIGHT,
                             TILE_WIDTH, TILE_HEIGHT, 'RGB' )
                 )
end

# Basically go through the same kind of loop, but using composite
#tiles.each_with_index do |tile, idx| tile.display end
pp tiles

#tiles.animate(20)
tiles.delay = 20
tiles.write(OUTPUTFILE) do
  self.compression = Magick::LZWCompression
end

#new_img.write("
