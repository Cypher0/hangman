class Game

  def initialize
    @misses = []
    @guess = ''
    @progress = []
    @guessed_letters = []
  end

  def load_dictionary
    @dictionary = []
    File.open('5desk.txt', 'r').readlines.each do |line|
      @dictionary << line if line.strip.length.between?(5, 12)
    end
  end

  def pick_word
    @word = @dictionary.sample.strip.downcase.split('')
  end

  def guess_a_letter
    puts 'Guess a letter! (Or type "save" to save your game): '
    guess = gets.chomp.downcase
    if guess.downcase == 'save'
      save_game
      game_loop
    else
      if @misses.include?(guess) || @progress.include?(guess)
        puts 'You have already tried that letter!'
        guess_a_letter
      elsif ('a'..'z').include?(guess.downcase)
        @guess = guess
      else
        puts 'That is not a valid guess! Make sure to use a single character between A and Z.'
        guess_a_letter
      end
    end
  end

  def save_game
    puts "Enter a name for your saved game: "
    name = gets.chomp
    saved_game = File.open("saves/#{name}", 'w')
    saved_game.puts Marshal::dump($a)
    puts 'Game saved!'
  end

  def start_menu
    puts 'Welcome to Hangman!'
    puts 'Do you want to start a (N)ew game or (L)oad a previously saved game?'
    choice = gets.chomp
    if choice.downcase == 'n'
      start
    elsif choice.downcase == 'l'
      load_game
      $a.game_loop
    else
      puts 'I didn\'t understand that, please try again.'
      start_menu
    end
  end

  def load_game
    puts 'Enter the name of your saved file: '
    name = gets.chomp
    if File.exist?("saves/#{name}")
      game_file = File.open("saves/#{name}", 'r')
      $a = Marshal::load(game_file)
    else
      puts 'No game found with that name.'
      start_menu
    end
  end

  def game_loop
    loop do
      check_progress
      break if game_over?
      display_progress
      guess_a_letter
    end
    if @progress == @word
      puts "You guessed it, the word was #{@word.join.upcase}! You win!"
    else 
      puts "Out of turns! The correct word was #{@word.join.upcase}!"
    end
  end


  def check_progress
    @progress = []
    @word.each do |letter|
      if letter == @guess || @guessed_letters.include?(letter)
        @progress << letter
      else
        @progress << '_'
      end
    end
    @word.include?(@guess) ? @guessed_letters << @guess : @misses << @guess unless @guess == ''
  end

  def display_progress
    puts @progress.join.upcase
    puts "Misses: #{@misses}"
    puts "You have #{6 - @misses.size} missed guesses left."
  end

  def game_over?
    @misses.size > 5 || @progress == @word
  end

  def start
    load_dictionary
    pick_word
    puts @word
    game_loop
  end
end

$a = Game.new
$a.start_menu