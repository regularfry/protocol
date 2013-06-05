# encoding: utf-8

# A simple protocol implementation for ruby.
#
# Use like so:
#
#
# class Elf
#   def shoots?
#     true
#   end
# end
#
#
# Stinky = Protocol.new do
#   provides :stinks?
# end
#
#
# StinkyElf = Stinky.as(Elf) do
#   def stinks?
#     !_subject.shoots?
#   end
# end
#
#
# elf = Elf.new
# stinky_elf = Stinky << elf # or StinkyElf.new(elf) if you prefer
# stinky_elf.shoots? # => true
# stinky_elf.stinks? # => false
#
module Protocol

  # Define a new protocol.  Takes a block defining which instance
  # methods an implementation of the protocol must define.
  # See ImplementationCheck for more details of this block.
  def self.new(&blk)
    check = ImplementationCheck.new( &blk )
    protocol = ::Class.new( ProtocolClass )
    protocol.set_check( check )
    protocol
  end



  # Exception rather than StandardError, since it's
  # an unrecoverable wrongness not to have completely
  # implemented a protocol
  class IncompleteImplementationError < Exception
    def initialize( kls, protocol, missing_methods )
      super("The #{kls} implementation of "\
        "#{protocol} is missing "\
        "#{missing_methods.join(", ")}")
    end
  end


  # The superclass of the wrapper classes which get applied to each
  # instance which has a protocol applied.
  class DelegateClass
    attr_reader :_subject
    def initialize(subject)
      @_subject = subject
    end

    def method_missing( sym, *args, &blk )
      _subject.__send__(sym, *args, &blk )
    end

    def respond_to_missing?(sym, include_all)
      _subject.respond_to?(sym, include_all)
    end
  end


  class ProtocolClass

    def self.as(kls, &blk)
      # We want one of these per protocol, and since we can't subclass
      # Class, I'm making it lazily.  Yes, this isn't threadsafe.
      # I'll fix that later.
      @delegate_class_lookup ||= {}
      delegate_class = ::Class.new(DelegateClass, &blk)
      check_implementation( delegate_class )
      @delegate_class_lookup[kls] = delegate_class
      delegate_class
    end


    def self.<<(obj)
      @delegate_class_lookup[obj.class].new(obj)
    end


    # Called on the subclass made by Protocol.new
    def self.set_check(check)
      @check = check
    end


    def self.check_implementation( delegate_class )
      @check.check(delegate_class, self)
    end


  end # class ProtocolClass


  class ImplementationCheck
    def initialize(&blk)
      @methods = []
      apply_definition(&blk)
    end

    # DSL method.  Documents the instance methods which define the
    # protocol.
    def provides( *method_names )
      @methods += method_names
    end


    # Raises an IncompleteImplementationError if the protocol isn't
    # completely defined by an instance of kls. Returns true
    # otherwise.  Because this actually makes an instance of kls, this
    # should only be used with DelegateClass subclasses.
    def check( kls, protocol )
      # I'm not particularly happy with the implementation of this
      # check method.  Better ideas welcome.
      fake_obj = kls.new( :fake_subject )
      unimplemented = @methods.reject{|m| fake_obj.respond_to?( m ) }
      if unimplemented.any?
        raise IncompleteImplementationError.new( kls, protocol, unimplemented )
      end
      true
    end


    private
    def apply_definition(&blk)
      self.instance_exec(&blk)
    end

  end


end # module Protocol

