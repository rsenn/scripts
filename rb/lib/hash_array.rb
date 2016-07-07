require 'rexml/document'

""" XmlHash class """
class XmlHash < Hash
    @tagname = ''
    @tagpath = ''
  attr_accessor :tagname, :tagpath
    def initialize(elem=REXML::Element.new,name="")
        super({})
        if elem.is_a? REXML::Element then
            elem.attributes.each do |n,a|
                self.store(n, a.to_s)
            end
            @tagname = elem.name
            @tagpath = elem.xpath.gsub(/^\/*[A-Z]+\//, "").downcase
        elsif elem.is_a? Hash then
            self.merge!(elem)
            @tagname = name
            @tagpath = "//"+name
        end
    end
    def to_s(multiline=false, name=@tagname)
        if @tagpath != "" then name = @tagpath end
        if multiline then
            ml_t = "\n"
            ml_s = "#{ml_t}  "
        end
        name + " {#{ml_s}" + self.map { |k,v| k + "=" + HashArray.quoteval(v) }.join(",#{ml_s}") + "#{ml_t}}"
    end
end


""" HashArray class """
class HashArray < Array
  @tagname = ''
  attr_accessor :tagname
  def initialize(elems)
      if elems.size > 0 and elems.first.is_a? REXML::Element then
          super HashArray.elements2hashes(elems) 
          @tagname = String(elems.first.name)
      elsif elems.is_a? HashArray or (elems.size > 0 and elems.first.is_a? XmlHash) then
          super elems
          @tagname = elems.is_a?(HashArray) ? elems.tagname : elems.first.tagname
      else
          super []
        @tagname = ""
      end
  end

  def HashArray.hash2str(h, multiline=false, name="",noquote=false)
          if multiline then
              ml_t = "\n"
              ml_s = "#{ml_t}  "
          end
          if h.is_a? Hash then
              "{{#{ml_s}" + (name != "" ? "<"+name+">" : "") + h.map { |k,v| k.to_s + "=" + HashArray.quoteval(v,noquote) }.join(",#{ml_s}") + "#{ml_t}}}"
          elsif h.is_a? XmlHash then
              h.to_s(multiline, name)
          elsif h.is_a? Array then
              if h.first.is_a? Hash then noquote = true end

              "[[#{ml_s}" + (name != "" ? "<"+name+">" : "") + h.map { |i| 
                  HashArray.quoteval(i,noquote)
              }.join(",#{ml_s}") + "#{ml_t}]]"
          else
              h.to_s
          end
  end

  def to_s(multiline=false, name=@tagname)
    arr = self
    name + "[[\n " + self.map { |h| 
          i = arr.find_index(h)
       if not h.is_a? XmlHash then h = XmlHash.new h end
       if h.is_a? XmlHash then
           h.to_s( multiline, (h.tagname != "" ? h.tagname : self.tagname) + i.to_s )
      else
   HashArray.hash2str(h, multiline, self.tagname, true)
       end
      }.join(",\n ") + "\n]]"
  end
  def merge_all
      ret = XmlHash.new
      self.each { |h|
          ret = h.merge ret
      }
      return ret
  end
  def map_cond(name, value=nil) 
      HashArray.new(self.map { |h| 
          if (value != nil and h[name] != value) or (value == nil and !h.has_key?(name)) then
              h = nil
          else
            XmlHash.new h
          end
      }.delete_if { |h| h == nil })
  end
  def get_hash(attr_key, attr_value) 
r = Hash.new
      self.map { |h|
  k = h[attr_key]
  v = h[attr_value]
          r[k.to_sym] = v
      }
      return r
  end
  def get_value(name) 
      Array.new(self.map { |h| h[name] })
  end
           
  def HashArray.get_elements(s,xml)
    HashArray.new xml.elements.to_a("//" + s)
  end

  def HashArray.get_element(s,xml)
    get_elements(s,xml).merge_all
  end
  

  """ Convert a REXML Elements List to a List of Hashes """
  def HashArray.elements2hashes(elems) 
    elems.map { |e|    XmlHash.new(e) }.delete_if { |h| h.size == 0 }
  end
end
