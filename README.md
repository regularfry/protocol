protocol
========


A simple library to help tackle the expression problem.


The Problem
-----------

We often want to define methods on a class which are only applicable
in a specific context.  That context may be a linguistic, semantic, or
execution scope.

Ruby has a few ways of doing this, but most (other than Refinements)
have the problem that, once these methods are defined on an instance,
that instance is permanently modified, and the "context-specific"
definitions leak out.

A Solution
----------

Protocols are an idea from clojure.  They define an interface which is
presented by a type, such that the interface is decoupled from the
underlying data.

This library implements protocols as a tight syntax for defining
delegate classes.  For instance:

    class Elf
      def shoots?
        true
      end
    end


    Stinky = Protocol.new do
      provides :stinks?
    end


    Stinky.as(Elf) do
      def stinks?
        true
      end
    end


    elf = Elf.new
    stinky_elf = Stinky << elf
    stinky_elf.stinks? # => true


Here, we've got our base class `Elf`, with an instance method
`shoots?`.  We define a protocol which can apply to any class,
`Stinky`, and then we give the implementation of the `Stinky` protocol
which applies to the `Elf` class.

Now, when we want to *use* the protocol, given an instance of `Elf` we
can get a `Stinky` with the `<<` operator.

Because `Stinky.as(Elf)` here internally defines a delegate, `elf` is
unmodified by this operation. The trade-off is that the protocol
implementation (in the `as` block) doesn't then have access to
instance variables defined on `elf`, but the delegate *is* available
to methods in the protocol as `_subject`.

Author
------

Alex Young <alex@blackkettle.org>
