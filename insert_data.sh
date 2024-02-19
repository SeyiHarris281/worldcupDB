#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# empty out db tables to restart
echo $($PSQL "TRUNCATE table games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_G OPPONENT_G
do
  if [[ $YEAR != 'year' ]]
  then
    # get winner_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
      # if winner not in db 
      if [[ -z $WINNER_ID ]]
      then
        # add winner to teams table
        INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
        if [[ $INSERT_WINNER_RESULT == 'INSERT 0 1' ]]
        then
          echo inserted $WINNER into teams
        fi
        # get new winner_id
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
      fi
      

    # get opponent_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
      # if opponent not in db
      if [[ -z $OPPONENT_ID ]]
      then
        # add opponent to teams table
        INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
        if [[ $INSERT_OPPONENT_RESULT == 'INSERT 0 1' ]]
        then
          echo inserted $OPPONENT into teams
        fi
        # get new opponent_id
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
      fi
        

    # add record to games table
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_G, $OPPONENT_G)")
    if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]
    then
      echo -e "\ninserted into games table"
      echo "~ year, round, winner, opponent, winner goals, opponent goals ~"
      echo $YEAR, $ROUND, $WINNER, $OPPONENT, $WINNER_G, $OPPONENT_G
    fi
  fi
done