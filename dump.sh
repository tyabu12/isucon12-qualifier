#!/bin/bash

for dbfile in `ls ~/initial_data`
do 
  touch ~/webapp/tenant/${dbfile}.dump
  sqlite3 ${dbfile} .dump > ~/webapp/tenant/${dbfile}.dump
done

