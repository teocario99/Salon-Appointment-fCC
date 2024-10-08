#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ ~~~~~ MY SALON ~~~~~ ~~~~~\n"

echo -e "\nWelcome to My Salon, how can I help you?"

MAIN_MENU(){

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  LIST_SERVICES=$($PSQL "SELECT service_id, name FROM services")

  echo -e "\n$LIST_SERVICES" | while read SERVICE_ID BAR NAME
  do
   echo "$SERVICE_ID) $NAME"
  done 

  READ_SELECTION



}

READ_SELECTION(){
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-3]+$ ]]
  then
  MAIN_MENU "I could not find that service. What would you like today?"
  else
  SERVICE_TEXT=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SERVICE_NAME_FORMATTED=$( echo $SERVICE_TEXT | sed 's/ //g')
  PROCESS_REQ  
  fi
  

}

PROCESS_REQ(){
#ask phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
#get customer name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
#if not found  
  if [[ -z $CUSTOMER_NAME ]]
  then
  INSERT_NEW_RECORD
  else
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME' AND phone = '$CUSTOMER_PHONE'")
  CUSTOMER_NAME_FORMATTED=$( echo $CUSTOMER_NAME | sed 's/ //g')
  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  TIME_FORMATTED=$(echo $SERVICE_TIME | sed 's/ //g')
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $TIME_FORMATTED, $CUSTOMER_NAME_FORMATTED."
  fi
}

INSERT_NEW_RECORD(){

  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  CUSTOMER_NAME_FORMATTED=$( echo $CUSTOMER_NAME | sed 's/ //g')
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME' AND phone = '$CUSTOMER_PHONE'")
  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  TIME_FORMATTED=$( echo $SERVICE_TIME | sed 's/ //g')
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $TIME_FORMATTED, $CUSTOMER_NAME_FORMATTED."


}

MAIN_MENU
