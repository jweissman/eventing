require 'spec_helper'
require 'eventing'

shared_examples :an_event do |*args|
  before do
    @events_received = []
    @on_event_handler = Proc.new { |event| @events_received << event }
    described_class.subscribe(&@on_event_handler)
  end

  it 'should publish and receive' do
    expect { described_class.publish!(*args) }.to change { @events_received.count }.by(1)
    event = @events_received.first
    expect(event).to be_a(described_class)
  end

  it 'should unsubscribe and not receive' do
    described_class.unsubscribe(&@on_event_handler)
    expect { described_class.publish!(*args) }.not_to change { @events_received.count }
  end
end

describe CoffeeReadyEvent do
  it_should_behave_like :an_event, {id: 1}
end

describe DrinkPouredEvent do
  it_should_behave_like :an_event, {beverage_type: 'tea'}
end

describe DrinkDrunkEvent do
  it_should_behave_like :an_event
end

describe "event pipeline" do
  it 'should chain events together' do
    CoffeeReadyEvent.subscribe do |event|
      DrinkPouredEvent.publish!(beverage_type: "coffee")
    end

    DrinkPouredEvent.subscribe do |drink_poured|
      expect(drink_poured.beverage_type).to eq("coffee")
      DrinkDrunkEvent.publish!
    end

    @drink_was_drunk = false
    DrinkDrunkEvent.subscribe do |event|
      @drink_was_drunk = true
    end

    expect { CoffeeReadyEvent.publish!(id: 1) }.to change { @drink_was_drunk }.from(false).to(true)
  end
end

describe 'callbacks on an object' do
  let(:controller) { DrinkController.new }
  let(:observer) { DrinkObserver.new }

  it 'should permit an observer model to listen to events' do
    CoffeeReadyEvent.subscribe(&observer.method(:ready))
    DrinkPouredEvent.subscribe(&observer.method(:poured))
    DrinkDrunkEvent.subscribe(&observer.method(:drunk))

    expect { controller.prepare!(id: 1) }.to change { observer.drinks_readied }.by([1])
    expect( Drink.find(1).state ).to eq(:prepared)
  end
end
