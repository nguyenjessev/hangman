# frozen-string-literal: true

require 'json'

# Mixin to make child classes serializable
module Serializable
  @@serializer = JSON

  def serialize
    obj = {}

    instance_variables.map do |var|
      obj[var] = instance_variable_get(var)
    end

    @@serializer.dump(obj)
  end

  def unserialize(string)
    obj = @@serializer.parse(string)
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
      @secret_word = []
      @revealed_letters = []
      @guessed_letters = []
      @lives_left = 0
      @possible_words = File.readlines('5desk.txt', chomp: true).select { |word| word.length.between?(5, 12) }
    end

    def new_game
      generate_secret_word
      self.guessed_letters = []
      self.lives_left = 6

      puts "\nWelcome to Hangman! The computer will randomly select a word and it is your job to try to guess it."
      puts 'You have 6 lives. Try to guess every letter!'

      play_game
    end

    private

    def generate_secret_word
      self.secret_word = possible_words.sample.upcase.split('')
      self.revealed_letters = Array.new(secret_word.length) { '_' }
    end

    def play_game
      until lives_left.zero?
        print_game_status
        guess = ask_for_guess
        verify_guess(guess)
        break if word_revealed?
      end

      print_game_status
      puts 'Game over!'
      puts word_revealed? ? 'You win!' : 'You lose!'
      puts "The word was: #{secret_word.join}"
    end

    def ask_for_guess
      guess = ''
      loop do
        print 'Guess a letter (enter "save" to save the game): '
        guess = gets.chomp.upcase
        break if guess.length == 1 && guess.match?(/[A-Z]/) && guessed_letters.none?(guess)

        if guess == 'SAVE'
          save_game
        else
          puts 'Invalid input. Please try again.'
        end
      end
      guess
    end

    def print_game_status
      puts
      puts revealed_letters.join(' ')
      puts "Lives Left: #{lives_left}"
      puts "Guessed Letters: #{guessed_letters.join(', ')}"
    end

    def verify_guess(guess)
      guessed_letters << guess
      if secret_word.include?(guess)
        secret_word.each_index { |i| revealed_letters[i] = guess if guess == secret_word[i] }
      else
        puts "\nIncorrect!"
        self.lives_left -= 1
      end
    end

    def word_revealed?
      secret_word == revealed_letters
    end

    def save_game
      File.open('save_file.txt', 'w') { |save_file| save_file.puts serialize }

      puts "\nGame saved! The program will now exit."
      exit
    end

    def load_game
      if File.exist?('save_file.txt')
        begin
          save_data = File.read('save_file.txt')
          unserialize(save_data)
          puts "\nGame successfully loaded from file."
          play_game
        rescue StandardError
          puts "\nAn error occurred."
        end
      else
        puts "\nNo save file found."
      end
    end

    def serialize
      obj = {}
      obj[:secret_word] = secret_word
      obj[:revealed_letters] = revealed_letters
      obj[:guessed_letters] = guessed_letters
      obj[:lives_left] = lives_left

      @@serializer.dump(obj)
    end
  end
end

game = Hangman::Game.new
game.new_game
