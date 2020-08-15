# frozen-string-literal: true

require 'json'

# Mixin to make child classes serializable
module Serializable
  @serializer = JSON

  def serialize
    obj = {}

    instance_variables.map do |var|
      obj[var] = instance_variable_get(var)
    end

    @serializer.dump obj
  end

  def unserialize(string)
    obj = @serializer.parse(string)
    obj.keys.each do |key|
      instance_variable_set(key, obj[key])
    end
  end
end

module Hangman
  # This class represents the overall game state
  class Game
    include Serializable
  end

  # This class represents the word to be guessed, along with what letters have been revealed
  class Word
    include Serializable
  end
end
