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
      @revealed_letters = []
      @guessed_letters = []
      @lives_left = 0
      @possible_words = File.readlines('5desk.txt', chomp: true).select { |word| word.length.between?(5, 12) }
    end

    def new_game
      generate_secret_word
      self.guessed_letters = []
      self.lives_left = 6

      play_game
    end

    private

    def generate_secret_word
      self.secret_word = possible_words.sample.upcase
      self.revealed_letters = Array.new(secret_word.length) { '_' }
    end

    def play_game
      puts "\nWelcome to Hangman! The computer will randomly select a word and it is your job to try to guess it."
      puts 'You have 6 lives. Try to guess every letter!'

      until lives_left.zero?
        print_game_status
        guess = ask_for_guess
        verify_guess(guess)
      end
    end

    def ask_for_guess
      guess = ''
      loop do
        guess = gets.chomp.upcase
        break if guess.length == 1 && guess.match?(/[A-Z]/) && guessed_letters.none?(guess)

        print 'Invalid input. Please enter a valid guess: '
      end
      guess
    end

    def print_game_status
      puts
      puts revealed_letters.join(' ')
      puts "Lives Left: #{lives_left}"
      puts "Guessed Letters: #{guessed_letters.join(', ')}"
      print 'Guess a letter: '
    end
  end
end

game = Hangman::Game.new
game.new_game
