# encoding: utf-8

require 'test/unit'

require 'protocol'

class TestProtocols < Test::Unit::TestCase

  class Elf
    def shoots?
      true
    end
  end

  Stinky = Protocol.new do
    provides :stinks?
  end


  StinkyElf = Stinky.as(Elf) do
    def stinks?
      _subject.shoots?
    end
  end


  def setup
    elf = Elf.new
    @stinky_elf = Stinky << elf
  end


  def test_stinky_elf_is_stinky
    assert @stinky_elf.stinks?
  end


  def test_stinky_elf_can_shoot
    assert @stinky_elf.shoots?
    assert @stinky_elf.respond_to? :shoots?
  end


  def test_incomplete_implementation_raises
    orc = Class.new
    exc = assert_raises(Protocol::IncompleteImplementationError) do
      Stinky.as(orc){}
    end
  end

end # class TestProtocols
