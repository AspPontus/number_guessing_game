#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GENERATE_NUMBER=$(( RANDOM%1000 + 1 ))
NUMBER_OF_GUESSES=0

echo "Enter your username:" 
read USERNAME_INPUT

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME_INPUT'")

if [[ -z $USER_ID ]]
    then
      INSERT_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME_INPUT')")
      echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
    else 
    
      USERNAME=$($PSQL "SELECT username FROM users WHERE user_id=$USER_ID")
      GAME_COUNT=$($PSQL "SELECT COUNT(user_id) FROM games WHERE user_id=$USER_ID")
      BEST_GAME=$($PSQL "SELECT number_of_guesses FROM games WHERE user_id=$USER_ID ORDER BY number_of_guesses ASC LIMIT 1")
      echo "Welcome back, $USERNAME! You have played $GAME_COUNT games, and your best game took $BEST_GAME guesses."
    fi  
 


echo "Guess the secret number between 1 and 1000:"
read GUESS

echo $GENERATE_NUMBER

GUESS_NUMBER() {

    if [[ ! $GUESS =~ ^[0-9]+$ ]]
      then
        NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))
        echo "That is not an integer, guess again:"
        read GUESS
        GUESS_NUMBER
    elif [[ $GUESS < $GENERATE_NUMBER ]]
      then
        NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))
        echo "It's higher than that, guess again:"
        read GUESS
        GUESS_NUMBER
    elif [[ $GUESS > $GENERATE_NUMBER ]]
      then
        NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))
        echo "It's lower than that, guess again:"
        read GUESS   
        GUESS_NUMBER 
    else
      NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))
        USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME_INPUT'")
        INSERT_GAME=$($PSQL "INSERT INTO games (user_id, number_of_guesses) VALUES ($USER_ID , $NUMBER_OF_GUESSES)") 
        echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $GENERATE_NUMBER. Nice job!"
  fi
}  

 GUESS_NUMBER
