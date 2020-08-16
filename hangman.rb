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

    attr_accessor :secret_word, :revealed_letters, :guessed_letters, :lives_left, :possible_words

    def initialize
      @secret_word = ''
      @revealed_letters = ''
      @guessed_letters = []
      @lives_left = 0
      @possible_words = File.readlines('5desk.txt', chomp: true).select { |word| word.length.between?(5, 12) }
    end

    def start_game
      generate_secret_word
      self.guessed_letters = []
      self.lives_left = 6
    end

    private

    def generate_secret_word
      self.secret_word = possible_words.sample
      self.revealed_letters = '_' * secret_word.length
    end
  end
end
