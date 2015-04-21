#!/usr/bin/env bash

sudo mongod --shutdown
sudo mysqladmin shutdown
sudo nginx -s stop
