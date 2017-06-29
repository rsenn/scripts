
require 'rubygems'
#require 'htmlentities'
require 'pp'
require 'libeagle'

def get_subobj(obj, *list_names)
  list_names.each do |list_name|
    list_name = list_name.to_s
    method_object = obj.method( "object_#{list_name}".to_sym )
    obj = method_object.call
  end
  obj
end


begin
  if ARGV.length == 0 then
    $stderr.puts "ERROR: No argument"
    exit 2
  end
  board_file = ARGV.shift
  
 
  

  def read_board(file_name, element_names)
    cmds = []
    eagle = LibEagle::Parser.parseFile(file_name)
    elements_arr =  get_subobj(eagle, :drawing, :board, :elements, :element)
    elements = elements_arr.map do |e|
    rot = e.attribute_rot
      if not rot.is_a? String then rot = "R0" end
    
      h = {
        :name => e.attribute_name,      
        :x => (e.attribute_x.to_f / 25.4).round(1),
        :y => (e.attribute_y.to_f / 25.4).round(1),
        :r => rot.gsub(/^R/, "").to_i,
        :p => e.attribute_package,
      }
      if element_names.empty? or element_names.include?(name) then
        cmds.push "MOVE #{h[:name]} (#{h[:x]} #{h[:y]})"
        cmds.push "ROTATE =R#{h[:r]} #{h[:name]}"
   #     cmds.push "PACKAGE #{h[:p]} #{h[:name]}"
      end
      pp e
    end
    cmds
  end

  puts read_board(board_file, ARGV).join("; ")
end
