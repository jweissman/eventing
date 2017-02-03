require 'rspec'
require 'eventing'
require 'pry'

include Eventing

# model
class Drink
  attr_accessor :id, :state, :kind

  def initialize(id:)
    @id = id
    @state = :unprepared
    @kind = 'coffee'
  end

  def self.find(id)
    @drinks ||= {}
    @drinks[id] ||= Drink.new(id: id)
  end
end

# event
class DrinkReadyEvent < Event
  attr_reader :id
  def initialize(id:)
    @id = id
  end
end

class DrinkPouredEvent < Event
  attr_reader :id, :beverage_type
  def initialize(id:, beverage_type:)
    @id = id
    @beverage_type = beverage_type
  end
end

class DrinkDrunkEvent < Event
  attr_reader :id
  def initialize(id:)
    @id = id
  end
end

# ctrl
class DrinkController
  def prepare!(id:)
    @drink = Drink.find(id)
    @drink.state = :prepared
    DrinkReadyEvent.publish!(id: id)
  end

  def pour!(id:)
    @drink = Drink.find(id)
    @drink.state = :poured
    DrinkPouredEvent.publish!(id: id, beverage_type: @drink.kind)
  end

  def drink!(id:)
    @drink = Drink.find(id)
    @drink.state = :drunk
    DrinkDrunkEvent.publish!(id: id)
  end
end

# observer
class DrinkObserver
  def ready(event)
    drinks_readied; @drinks_readied << event.id
    controller.pour!(id: event.id)
  end

  def poured(event)
    controller.drink!(id: event.id)
  end

  def drunk(event)
  end

  def drinks_readied
    @drinks_readied ||= []
  end

  private
  def controller
    DrinkController.new
  end
end
