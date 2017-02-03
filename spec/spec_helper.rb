require 'rspec'
require 'eventing'
require 'pry'

include Eventing

class CoffeeReadyEvent < Event
  attr_reader :id
  def initialize(id:)
    @id = id
  end
end

class DrinkPouredEvent < Event
  attr_reader :beverage_type
  def initialize(beverage_type:)
    @beverage_type = beverage_type
  end
end

class DrinkDrunkEvent < Event; end

class Drink
  attr_accessor :id, :state

  def initialize(id:)
    @id = id
    @state = :unprepared
  end

  def self.find(id)
    @drinks ||= {}
    @drinks[id] ||= Drink.new(id: id)
  end
end

class DrinkController
  def prepare!(id:)
    @drink = Drink.find(id)
    @drink.state = :prepared
    CoffeeReadyEvent.publish!(id: id)
  end
end

class DrinkObserver
  def ready(event)
    drinks_readied; @drinks_readied << event.id
  end

  def poured(event)
  end

  def drunk(event)
  end

  def drinks_readied
    @drinks_readied ||= []
  end
end
