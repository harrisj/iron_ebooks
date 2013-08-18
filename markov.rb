#encoding: UTF-8

CONTRACTION_APOSTROPHE_SUBSTITUTE = 'qqq'
CONTRACTIONS = %w(aren't can't couldn't didn't doesn't don't hadn't hasn't haven't he'd he'll he's I'd I'll I'm I've isn't it's let's mightn't mustn't shan't she'd she'll she's shouldn't that's there's they'd they'll they're they've we'd we're we've weren't what'll what're what's what've where's who'd who'll who're who's who've won't wouldn't you'd you'll you're you've)

class MarkovChainer
   attr_reader :order
   def initialize(order)
     @order = order
     @beginnings = []
     @freq = {}
   end

   def add_text(text)
    # remove curly apostrophes
    text.gsub!(/’/, "'")

    # make sure each paragraph ends with some sentence terminator
    text.gsub!(/[\r\n]+\p{Space}*[\r\n]+/m, ".")
    text << "."
    seps = /[.:;?!]/
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
         out = res[0..-2].join(" ") + (res.last || '.')
         out.gsub!(CONTRACTION_APOSTROPHE_SUBSTITUTE, "'")
         return out
       end
       res << nw
     }
   end

  def add_sentence(sentence)
    if sentence =~ /[.:;?!]$/
      add_sentence_internal(sentence[0, sentence.length - 1], sentence[sentence.length - 1, 1])
    else
      add_sentence_internal(sentence, '.')
    end
  end

private
   def add_sentence_internal(str, terminator)
    str.gsub!(/’/, "'")

    CONTRACTIONS.each do |c|
      str.gsub!(/#{c}/i) {|m| m.gsub("'", CONTRACTION_APOSTROPHE_SUBSTITUTE)}
    end
    str.gsub!(/'s/, CONTRACTION_APOSTROPHE_SUBSTITUTE)

    #puts str
     words = str.scan(/[\p{Word}'’\-]+/)
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
