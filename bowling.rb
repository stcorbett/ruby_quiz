require "rubygems"
require "ruby-debug"
require "yaml"

class Frame
  @@frame_num = 1
  
  def self.num
    @@frame_num
  end
  
  def initialize(roll1, roll2 = nil)
    @rolls = []
    @rolls << roll1.to_i
    @rolls << roll2.to_i if roll2
    @num = @@frame_num
    pins
    score
    @@frame_num += 1
  end
  
  def num
    @num
  end
  
  def rolls
    @rolls
  end
  
  def pins
    @pins = 0
    @rolls.each{|r| @pins += r}
    @pins
  end
  
  def extra_roll= (roll)
    @rolls << roll.to_i
    pins
    rolls
  end
  
  def strike?
    rolls.size == 1 && pins == 10 
  end
  
  def spare?
    rolls.size == 2 && pins == 10
  end
  
  def extra_points
    return 0 unless strike? or spare?
    @extra_points.to_i
  end
  
  def extra_points= (pins)
    @extra_points = pins
    score
  end
  
  def score
    @score = pins + extra_points
  end
  
  def pprint
    %(  frame: #{num}
        rolls: #{rolls[0]}, #{rolls[1]}#{ rolls[2] ? ", " + rolls[2].to_s : ''}
        score: #{score}
    )
  end
  
end

puts ARGV.first
ARGV.shift

@frames = []
@rolls = []

# rolls: 6 2 7 1 10 9 0 8 2 10 10 3 5 7 2 5 5 8
# command: ruby bowling.rb John 6 2 7 1 10 9 0 8 2 10 10 3 5 7 2 5 5 8

ARGV.each{|r| @rolls << r.to_i}

# Build rolls into frames
while Frame.num <= 10
  if @rolls.first == 10
    @frames << Frame.new( @rolls.shift )
    @frames.last.extra_points = @rolls[0] + @rolls[1] unless Frame.num == 10
  else
    @frames << Frame.new( @rolls.shift, @rolls.shift )
    @frames.last.extra_points = @rolls[0] if @frames.last.spare?
  end
end

if @frames.last.pins == 10
  raise "missing extra rolls for frame 10" if @rolls.empty?
  @rolls.each do |r|
    @frames.last.extra_roll = r
  end
  raise "The input rolls are not a valid set of rolls" if @frames.last.rolls.size > 3
end

y @frames
@total = 0
puts ""
@frames.each do |f|
  @total += f.score;
  puts f.pprint + " total: #{@total}"
end

# Notes:

# calculating frame scores:
  # 1: iterate through @frames, pull the next 1 or 2 rolls as needed
  # 2: Frame stores all frames/rolls as a class Var, each frame has access to the next 1 or 2 rolls
  # 3: calculate it while building rolls into frames 

# when do you move to a new frame?
  # strike
  # 2 rolls
# when do you add current rolls to a past score?
  # strike (next two rolls)
  # spare (next roll)
