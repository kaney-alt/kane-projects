#!/bin/bash

# Define PSQL variable for PostgreSQL command
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Function to display available services
display_services() {
  echo "1) cut"
  echo "2) color"
  echo "3) perm"
  echo "4) style"
  echo "5) trim"
}

# Display the salon welcome message
echo "~~~~~ MY SALON ~~~~~"
echo
echo "Welcome to My Salon, how can I help you?"

# Display services
display_services

# Get the service_id from the user
while true; do
  echo "Please enter the number of the service you'd like to book:"
  read SERVICE_ID_SELECTED

  # Validate service selection
  if [[ $SERVICE_ID_SELECTED =~ ^[1-5]$ ]]; then
    break
  else
    # If invalid input, show the list again and prompt the user
    echo "I could not find that service. What would you like today?"
    display_services
  fi
done

# Get the phone number from the user
echo "What's your phone number?"
read CUSTOMER_PHONE

# Check if the phone number already exists in the customers table
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# If customer doesn't exist, add them to the customers table
if [[ -z $CUSTOMER_ID ]]
then
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  # Insert the new customer into the customers table
  INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  # Get the customer_id of the newly added customer
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
fi

# Get the service name based on the service_id
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

# Get the appointment time from the user
echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Insert the appointment into the appointments table
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Output the confirmation message
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
