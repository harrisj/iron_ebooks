#encoding: UTF-8

class MarkovChainer
   attr_reader :order
   def initialize(order)
     @order = order
     @beginnings = []
     @freq = {}
   end

   def add_text(text)
     # make sure each paragraph ends with some sentence terminator
     text.gsub!(/\n\s*\n/m, ".")
     text << "."
     seps = /([.!?;])/
     sentence = ""
     text.split(seps).each { |p|
       if seps =~ p
         add_sentence(sentence, p)
         sentence = ""
       else
         sentence = p
       end
     }
   end

   def generate_sentence
     res = @beginnings[rand(@beginnings.size)]
     return nil if res.nil?
     loop {
       unless nw = next_word_for(res[-order, order])
         return res[0..-2].join(" ") + res.last
       end
       res << nw
     }
   end

private
   def add_sentence(str, terminator)
     words = str.scan(/[\w'’\-]+/)
     return unless words.size > order # ignore short sentences
     words << terminator
     buf = []
     words.each { |w|
       buf << w
       if buf.size == order + 1
         (@freq[buf[0..-2]] ||= []) << buf[-1]
         buf.shift
       end
     }
     @beginnings << words[0, order]
   end

   def next_word_for(words)
     arr = @freq[words]
     arr && arr[rand(arr.size)]
   end
end
