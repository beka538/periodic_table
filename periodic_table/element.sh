#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

MAIN() {
  if [[ ! $1 ]]
  then
    echo "Please provide an element as an argument."
  else
    ELEMENT $1
  fi

}

ELEMENT() {
  ELEMENT_TO_SEARCH=$1

  #if atomic number
  if [[ $ELEMENT_TO_SEARCH =~ ^[0-9]{1,2}$ ]]
  then
    
    # set atomic number
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$ELEMENT_TO_SEARCH")
  
  #else if atomic symbol
  elif [[ $ELEMENT_TO_SEARCH =~ ^[A-Za-z]{1,2}$ ]]
  then
    
    # set atomic number
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$ELEMENT_TO_SEARCH'")
  
  #else if element name
  elif [[ $ELEMENT_TO_SEARCH =~ ^[a-zA-Z]*$ ]]
  then
  
    # set atomic number
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$ELEMENT_TO_SEARCH'")
  # error
  else
    echo "That didn't work!"
  fi

  # if atomic number doesn't exist
  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo "I could not find that element in the database."
  else
    
    # join tables
    ELEMENT_INFO_JOINED=$($PSQL "SELECT name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties ON elements.atomic_number=properties.atomic_number INNER JOIN types
  ON properties.type_id=types.type_id WHERE elements.atomic_number=$ATOMIC_NUMBER")
        ELEMENT_INFO=$(echo "$ELEMENT_INFO_JOINED" | sed -r "s/\|/ /g")
    echo "$ELEMENT_INFO" | while read NAME SYMBOL TYPE MASS MELTING BOILING
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done

  fi
  

}

MAIN $1
