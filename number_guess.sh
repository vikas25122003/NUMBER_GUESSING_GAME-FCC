#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

#checking if username exists :
USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  
  ADD_USER=$($PSQL "insert into users(username,games_played) values('$USERNAME',0)")
  
  USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")
  GAMES_PLAYED=0
  BEST_GAME="NULL"

else 
  GAMES_PLAYED=$($PSQL "select games_played from users where user_id=$USER_ID")
  BEST_GAME=$($PSQL "select best_game from users where user_id=$USER_ID")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#Secret Number Generation :
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
echo $SECRET_NUMBER

#Guess the Number:
echo -e "\nGuess the secret number between 1 and 1000:"
read USER_GUESS

NUMBER_OF_GUESSES=1

until [[ $USER_GUESS -eq $SECRET_NUMBER ]]
do
   if ! [[ $USER_GUESS =~ ^[0-9]+$ ]]
   then
    echo "That is not an integer, guess again:"
    read USER_GUESS
    (( NUMBER_OF_GUESSES++ ))

  elif [[ $USER_GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read USER_GUESS
    (( NUMBER_OF_GUESSES++ ))

  else
    echo "It's higher than that, guess again:"
    read USER_GUESS
    (( NUMBER_OF_GUESSES++ ))
   fi
done

#When Secret Number Guessed : 
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
UPDATE_GAMES_PLAYED=$($PSQL "update users set games_played=$GAMES_PLAYED where user_id=$USER_ID")

if [[ $BEST_GAME == "NULL" || $BEST_GAME -gt $NUMBER_OF_GUESSES ]]
then
  UPDATE_BEST_GAME=$($PSQL "update users set best_game=$NUMBER_OF_GUESSES where user_id=$USER_ID")
fi

