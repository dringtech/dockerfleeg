#!/usr/bin/env bash

cd ~docker

sudo mongod --logpath $LOGS/mongo.log &
sudo mysqld 2> $LOGS/mysql.err > $LOGS/mysql.log &
sudo nginx

