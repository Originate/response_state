class ResponseState
  attr_accessor :status

  def initialize
    @status = :registration
  end

  def self.init
    ResponseState.new.tap do |result|
      yield result
      result.status = :frozen
    end
  end

  def define_instance_method name, &block
    (class << self; self; end).class_eval do
      define_method name, &block
    end
  end


  def method_missing name, *args, &block
    if @status == :registration
      define_instance_method name, &block
    end
  end
end
