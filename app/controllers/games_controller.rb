# frozen_string_literal: true

require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def generate_grid(grid_size)
    letters = []
    vowel_numbers = (1..4).to_a.sample
    consanants = grid_size - vowel_numbers
    vowel_numbers.to_i.times do
      letters << ['A', 'E', 'I', 'O','U'].sample
    end
    consanants.to_i.times do
      letters << ('A'..'Z').grep(/[^AEIOU]/).sample
    end
    letters
    # TODO: generate random grid of letters
  end

  def new
    @letters = generate_grid(9)
    @string_letters = @letters.join('')
  end

  def score
    @word = params[:word]
    @string_letters = params[:letters]
    @letters = @string_letters.split('')
    @results = run_game(@word, @letters, @string_letters)
  end

  private

  def process_attempt(dict, attempt, grid, result, string_letters)
    if dict['error'] == 'word not found'
      result[:message] = "Sorry but #{attempt.capitalize} is not a valid English word"
    elsif attempt.upcase.chars.all? { |letter| grid.delete_at(grid.index(letter)) if grid.include?(letter) }
      result[:message] = "Congratulations! #{attempt.capitalize} is a valid English word"
    else
      result[:message] = "Sorry but #{attempt.capitalize} can't be built from #{string_letters}"
    end
  end

  def call_api(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    dict_serialized = URI.open(url).read
    JSON.parse(dict_serialized)
  end

  def run_game(attempt, grid, string_letters)
    result = {}
    dict = call_api(attempt)
    process_attempt(dict, attempt, grid, result, string_letters)
    result
  end
end
