require 'eventing/version'

module Eventing
  module Pubsub
    # add to handlers
    def subscribe(&cb)
      # we could check that handler IS a proc here too?
      raise "Only procs can .subscribe to events" unless cb.is_a?(Proc)
      handlers << cb
    end

    # remove from handlers
    def unsubscribe(&cb)
      handlers.delete(cb)
    end

    # fire new entity of type with args at handlers
    def publish!(*args)
      message = new(*args)
      handlers.each do |handler|
        # we could check that handler IS a proc
        handler.call(message)
        # wrap, check exception -- and don't break but try to continue with next handlers
      end
    end

    private

    def handlers
      @handlers ||= []
    end
  end

  class Event
    extend Pubsub
  end
end
