#!/bin/sh

# Copyright © 2022 Kaleido, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://swww.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Extract the database name from the end of the PSQL URL, and check it's there
DB_PARAMS=`echo ${PSQL_URL} | sed 's!^.*/!!'`
DB_NAME=`echo ${DB_PARAMS} | sed 's!?.*!!'`
echo "Database name: '${DB_NAME}'"
USER_NAME=`echo ${PSQL_URL} | sed 's!^.*//!!' | sed 's!:.*$!!'`
echo "Username: '${USER_NAME}'"
COLONS=`echo -n $DB_NAME | sed 's/[^:]//g'`
if [ -z "${DB_NAME}" ] || [ -n "${COLONS}" ]
then
  echo "Error: Postgres URL does not appear to contain a database name (required)."
  exit 1
fi

# Check we can connect to the PSQL server using the default "postgres" database
PSQL_SERVER=`echo ${PSQL_URL} | sed "s!${DB_PARAMS}!!"`postgres
until psql -c "SELECT 1;" ${PSQL_SERVER}; do
  echo "Waiting for PSQL server connection..."
  sleep 1
done

# Create the database if it doesn't exist
if ! psql -c "SELECT datname FROM pg_database WHERE datname = '${DB_NAME}';" ${PSQL_SERVER} | grep ${DB_NAME}
then
  echo "Database '${DB_NAME}' does not exist; creating."
  psql -c "CREATE DATABASE \"${DB_NAME}\" WITH OWNER \"${USER_NAME}\";" ${PSQL_SERVER}
fi

# Wait for the database itself to be available
until psql -c "SELECT 1;" ${PSQL_URL}; do
  echo "Waiting for database..."
  sleep 1
done

# Do the migrations
migrate -database ${PSQL_URL} -path db/migrations/postgres up
