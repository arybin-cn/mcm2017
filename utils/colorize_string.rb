require 'term/ansicolor'
String.include Term::ANSIColor
class << String
  def rand_color
    %i{red green cyan magenta}[rand 4]
  end
end
