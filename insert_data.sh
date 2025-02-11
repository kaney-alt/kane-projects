#!/bin/bash

# Check if the script is running in test mode
if [[ $1 == "test" ]]; then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Clear out existing data in the teams and games tables
echo $($PSQL "TRUNCATE teams, games RESTART IDENTITY")

# Read through the CSV file
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip header
  if [[ $WINNER != "winner" && $YEAR != "year" ]]; then

    # Check if the winner team exists in the database
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")

    # If the winner team doesn't exist, insert it
    if [[ -z $WINNER_ID ]]; then
      INSERT_WINNER_NAME=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
      if [[ $INSERT_WINNER_NAME == "INSERT 0 1" ]]; then
        echo "Inserted into teams: $WINNER"
      fi
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    fi

    # Check if the opponent team exists in the database
    OPPO_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")

    # If the opponent team doesn't exist, insert it
    if [[ -z $OPPO_ID ]]; then
      INSERT_OPPO_NAME=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
      if [[ $INSERT_OPPO_NAME == "INSERT 0 1" ]]; then
        echo "Inserted into teams: $OPPONENT"
      fi
      OPPO_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    fi

    # Insert the game data into the games table
    GAME_INSERT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
                         VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPO_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $GAME_INSERT == "INSERT 0 1" ]]; then
      echo "Inserted game: $YEAR - $ROUND - $WINNER vs $OPPONENT"
    fi
  fi
done
