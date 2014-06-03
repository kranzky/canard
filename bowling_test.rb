require './bowling'

describe Game do
  let(:game) { Game.new }

  it "should return 0 when a gutter game is bowled" do
    20.times { game.roll(0) }
    expect(game.score).to eq(0)
  end
 
  it "should return 20 if all ones are bowled" do
    20.times { game.roll(1) }
    expect(game.score).to eq(20)
  end

  it "should take spares into account" do
    game.roll(5)
    game.roll(5)
    game.roll(3)
    17.times { game.roll(0) }
    expect(game.score).to eq(16)
  end

  it "should take strikes into account" do
    game.roll(10)
    game.roll(3)
    game.roll(4)
    16.times { game.roll(0) }
    expect(game.score).to eq(24)
  end

  it "should return 300 if a perfect game is bowled" do
    12.times { game.roll(10) }
    expect(game.score).to eq(300)
  end

  it "should work with the example game given in the requirements" do
   [1,4,4,5,6,4,5,5,10,0,1,7,3,6,4,10,2,8,6].each do |pins|
      game.roll(pins)
    end
    expect(game.score).to eq(133)
  end

# it "should not work if the game is not valid" do
#   expect(game.score).to quack("only called at the very...")
#   expect(game.roll(11)).to quack("takes the number of...")
#   expect(game.roll(5.5)).to quack("takes the number of...")
#   expect(game.roll(nil)).to quack
#   expect(30.times { game.roll(0) }).to quack
# end
end
