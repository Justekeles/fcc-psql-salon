#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"


MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi

  
  SERVICE_OPTIONS=$($PSQL "SELECT * FROM services")
  echo "$SERVICE_OPTIONS" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  # check that it's a valid selection
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # get customer's number
    SERVICE_SELECTION=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed -r 's/^ *| *$//') 
    echo "What's your phone number?"
    read CUSTOMER_PHONE
    # check if the customer's number has been recorded before
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed -r 's/^ *| *$//')
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo "I don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      ADD_CUSTOMER=echo $($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      if [[ $ADD_CUSTOMER == "INSERT 0 1" ]]
      then
        echo "You are now added as a customer, '$CUSTOMER_NAME'"
      fi
    fi

    echo -e "\nWhat time would you like your $SERVICE_SELECTION, $CUSTOMER_NAME?"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    if [[ $ADD_APPOINTMENT == "INSERT 0 1" ]]
    then
      echo -e "\nI have put you down for a $SERVICE_SELECTION at $SERVICE_TIME, $CUSTOMER_NAME."
    fi

  fi

}

MAIN_MENU
