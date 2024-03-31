#!/bin/bash

# DB connection:
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Promting for a username:

START_SCRIPT() {
if [[ $1 ]]
then
  echo -e "\n$1"
fi

echo -e "Enter your username:\n"
read username

}

WELCOME_SECTION() {
START_SCRIPT
# Check if a username is entered

if [[ -z $username ]]
then
  START_SCRIPT "Please enter a valid username"
fi

# Check if username exists in DB

CHECK_USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$username';")

# If username don't exist in DB

if [[ -z $CHECK_USERNAME ]]
then
  ADD_USER_TO_DB=$($PSQL "INSERT INTO users(username) VALUES('$username');")
  echo "Welcome, $username! It looks like this is your first time here."
else
  games_played=$($PSQL "SELECT games_played FROM users WHERE username = '$username';")
  best_game=$($PSQL "SELECT best_game FROM users WHERE username = '$username';")
  echo -e "\nWelcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi
}

# Creating a variable with a random number between 1 and 1000
secret_number=$(( RANDOM % 1000 + 1))



# Building the function that handles the user guesses

NUMBER_GUESS() {
  WELCOME_SECTION
  GUESS_FUNC() {
    # Prompting the user for their guess
    echo "Guess the secret number between 1 and 1000:"
    read USER_GUESS

    # Incrementing the guess variable for each time the function is run
    ((number_of_guesses++))

  }

number_of_guesses=0

  # Call the guess function to initialize the guessing
  GUESS_FUNC
  if ! [[ $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
    GUESS_FUNC
  fi

  # Checking if the guess is correct or not

  while [[ $USER_GUESS -ne $secret_number ]]
  do
    # Check if user guess is greater than number
    if [[ $USER_GUESS -gt $secret_number ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
    
    # Then prompt the user again
    GUESS_FUNC
  done

  # If user guesses correct:
  echo -e "\nYou guessed it in $number_of_guesses tries. The secret number was $secret_number. Nice job!"

  # Update the user profile:
  if [[ $number_of_guesses -lt $best_game|| $best_game -eq 0 ]]; then
    UPDATE_USER_BEST=$($PSQL "UPDATE users SET best_game = '$number_of_guesses' WHERE username = '$username';")
fi
  ((TOTAL_GAMES_PLAYED= games_played + 1 ))
  UPDATE_USER_HISTORY=$($PSQL "UPDATE users SET games_played = '$TOTAL_GAMES_PLAYED' WHERE username = '$username'")
  
exit
}

NUMBER_GUESS
