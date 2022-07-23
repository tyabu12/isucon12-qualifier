#!/bin/bash

for dbfile in `ls ~/initial_data`
do 
  sqlite3 ~/initial_data/${dbfile} .dump > /home/isucon/webapp/sql/tenant/init_data/${dbfile}.dump
done

