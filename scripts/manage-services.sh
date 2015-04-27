#!/usr/bin/env bash

SERVICE_HOME=~docker
SERVICES="signon static panopticon publisher asset-manager contentapi www search"
LOG_DIR=${SERVICE_HOME}/logs

function start-rails-service {
    local service=$1
    local pidfile=${SERVICE_HOME}/$service/${service}.pid

    pushd ${SERVICE_HOME}/$service > /dev/null
    foreman start > ${LOG_DIR}/${service}.log 2> ${LOG_DIR}/${service}.err &
    echo $! > ${pidfile}
    popd > /dev/null
}

function stop-rails-service {
    local service=$1
    local pidfile=${SERVICE_HOME}/$service/${service}.pid
    echo Stopping ${service}
    [ -f ${pidfile} ] && kill $(cat ${pidfile}) && rm ${pidfile}
}

function start-databases {
    sudo mongod --logpath $LOGS/mongo.log &
    sudo mysqld 2> $LOGS/mysql.err > $LOGS/mysql.log &
}

function stop-databases {
    sudo mongod --shutdown
    sudo mysqladmin shutdown
}

function start-nginx {
    sudo nginx
}
function stop-nginx {
    sudo nginx -s stop
}

function start-all {
    start-databases
    for srv in $SERVICES
    do
        start-rails-service $srv
    done
    start-nginx
}

function stop-all {
    stop-nginx
    for srv in $SERVICES
    do
        stop-rails-service $srv
    done
    stop-databases
}

$*
