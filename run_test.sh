#!/bin/bash

# Import the PostgreSQL environment credentials.
source env.sh

SQL_ADDR="jdbc:postgresql://localhost/?currentSchema=A2"
REPORT_FILE="$1"

# Set up the temporary workspace folder.
workspace=$(mktemp -d)
opFile="$workspace/output.txt"
trap "rm -rf $workspace" EXIT

function logResult() {
    if [ "$1" -ne 0 ]
    then
        echo "$2" | tee -a "$REPORT_FILE"
    else
        echo "$3" | tee -a "$REPORT_FILE"
    fi
}

##################################
#   constructor()
##################################
echo "Run Test -- constructor()" | tee -a "$REPORT_FILE"

rm -f "$opFile"
psql -f "assets/a2.ddl" "$STUDENT_AUTH" &> /dev/null
timeout -k 0 5s java -jar driver.jar "constructor" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "$opFile" &> /dev/null
diff "$opFile" "assets/true.txt" &> /dev/null
logResult "$?" "false" "true"

##################################
#   connectDB()
##################################
echo "Run Test -- connectDB()" | tee -a "$REPORT_FILE"

psql -f "assets/a2.ddl" "$STUDENT_AUTH" &> /dev/null

# -- Given valid credentials, a connection is established.
rm -f "$opFile"
timeout -k 0 5s java -jar driver.jar "connect" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "$opFile" &> /dev/null
diff "$opFile" "assets/true.txt" &> /dev/null
logResult "$?" "false" "true"

# -- Given invalid parameters (a bad password), no connection is established.
rm -f "$opFile"
timeout -k 0 5s java -jar driver.jar "connect" "$SQL_ADDR" "$STUDENT_USER" "a_bad_password" "$opFile" &> /dev/null

# -- Given invalid parameters (a bad username and password), no connection is established.
timeout -k 0 5s java -jar driver.jar "connect" "$SQL_ADDR" "a_bad_user" "a_bad_password" "$opFile" &> /dev/null

# -- Given invalid parameters (a bad server port), no connection is established.
timeout -k 0 5s java -jar driver.jar "connect" "jdbc:postgresql://localhost:22/" "a_bad_port" "a_bad_port" "$opFile" &> /dev/null

# -- Given invalid parameters (a bad url:driver), no connection is established.
timeout -k 0 5s java -jar driver.jar "connect" "jdbc:unknown://localhost/" "a_bad_driver" "a_bad_driver" "$opFile" &> /dev/null

diff "$opFile" "assets/output/connect.01.test-01.data" &> /dev/null
logResult "$?" "false" "true"

##################################
#   disconnectDB()
##################################
echo "Run Test -- disconnectDB()" | tee -a "$REPORT_FILE"

function setupDisconnect() {
    rm -f "$opFile"
    psql -f "assets/a2.ddl" "$STUDENT_AUTH" &> /dev/null
}

# -- No connection previously existed. The closure attempt fails.
setupDisconnect
timeout -k 0 5s java -jar driver.jar "disconnect" "NULL_CONNECTION" "NULL_CONNECTION" "NULL_CONNECTION" "1" "$opFile" &> /dev/null
diff "$opFile" "assets/false.txt" &> /dev/null
logResult "$?" "false" "true"

# -- The previous connection was already closed. The closure attempt fails.
setupDisconnect
timeout -k 0 5s java -jar driver.jar "disconnect" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "2" "$opFile" &> /dev/null
diff "$opFile" "assets/false.txt" &> /dev/null
logResult "$?" "false" "true"

# -- A connection was previously established. The closure attempt succeeds.
setupDisconnect
timeout -k 0 5s java -jar driver.jar "disconnect" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "3" "$opFile" &> /dev/null
diff "$opFile" "assets/true.txt" &> /dev/null
logResult "$?" "false" "true"

##################################
#   insertPlayer()
##################################
echo "Run Test -- insertPlayer()" | tee -a "$REPORT_FILE"

function setupInsert() {
    rm -f "$opFile"
    psql -f "assets/a2.ddl" "$STUDENT_AUTH" &> /dev/null
    psql -f "assets/country/01.sql" "$STUDENT_AUTH" &> /dev/null
    psql -f "assets/player/01.sql" "$STUDENT_AUTH" &> /dev/null
}

# -- Given valid parameters, the insertion succeeds.
setupInsert
timeout -k 0 5s java -jar driver.jar "insert" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "57382" "Tena Penrose" "51" "288639" "$opFile" &> /dev/null
diff "$opFile" "assets/true.txt" &> /dev/null
logResult "$?" "false" "true"
psql -a -c "SELECT * FROM A2.player ORDER BY pid ASC;" "$STUDENT_AUTH" &> "$opFile"
diff "$opFile" "assets/output/players.01.test-01.data" &> /dev/null
logResult "$?" "false" "true"

# -- Given an ``int pid`` that violates the ``PRIMARY KEY`` constraint, the insertion fails.
setupInsert
timeout -k 0 5s java -jar driver.jar "insert" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "30105" "Charles Xu" "51" "509184" "$opFile" &> /dev/null
diff "$opFile" "assets/false.txt" &> /dev/null
logResult "$?" "false" "true"
psql -a -c "SELECT * FROM A2.player ORDER BY pid ASC;" "$STUDENT_AUTH" &> "$opFile"
diff "$opFile" "assets/output/players.01.normal.data" &> /dev/null
logResult "$?" "false" "true"

# -- Given an ``int cid`` that violates the ``FOREIGN KEY`` reference, the insertion fails.
setupInsert
timeout -k 0 5s java -jar driver.jar "insert" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "57382" "Charles Xu" "51" "123456" "$opFile" &> /dev/null
diff "$opFile" "assets/false.txt" &> /dev/null
logResult "$?" "false" "true"
psql -a -c "SELECT * FROM A2.player ORDER BY pid ASC;" "$STUDENT_AUTH" &> "$opFile"
diff "$opFile" "assets/output/players.01.normal.data" &> /dev/null
logResult "$?" "false" "true"

# -- Given a malicious ``String`` for ``String pname``, the insertion succeeds.
setupInsert
timeout -k 0 5s java -jar driver.jar "insert" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "57382" "--!#*@^*()*(^&*%" "51" "288639" "$opFile" &> /dev/null
diff "$opFile" "assets/true.txt" &> /dev/null
logResult "$?" "false" "true"
psql -a -c "SELECT * FROM A2.player ORDER BY pid ASC;" "$STUDENT_AUTH" &> "$opFile"
diff "$opFile" "assets/output/players.01.test-02.data" &> /dev/null
logResult "$?" "false" "true"

##################################
#   getChampions()
##################################
echo "Run Test -- getChampions()" | tee -a "$REPORT_FILE"

function testBadChampion() {
    if [ -f "$1" ]
    then
        val=$(cat "$1")
        if [ "$val" -le 0 ]
        then
            echo "true" | tee -a "$REPORT_FILE"
        else
            echo "false" | tee -a "$REPORT_FILE"
        fi
    else
        echo "false" | tee -a "$REPORT_FILE"
    fi
}

psql -f "assets/a2.ddl" "$STUDENT_AUTH" &> /dev/null
psql -f "assets/country/01.sql" "$STUDENT_AUTH" &> /dev/null
psql -f "assets/player/01.sql" "$STUDENT_AUTH" &> /dev/null
psql -f "assets/tournament/01.sql" "$STUDENT_AUTH" &> /dev/null
psql -f "assets/champion/01.sql" "$STUDENT_AUTH" &> /dev/null

# -- Given an ``int pid`` with N championships, return N.
rm -f "$opFile"
timeout -k 0 5s java -jar driver.jar "champions" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "58110" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "champions" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "73300" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "champions" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "106747" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "champions" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "12336" "$opFile" &> /dev/null
diff "$opFile" "assets/output/champions.test-01.data" &> /dev/null
logResult "$?" "false" "true"

# -- Given an ``int pid`` with a single championship, returns 1.
rm -f "$opFile"
timeout -k 0 5s java -jar driver.jar "champions" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "97567" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "champions" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "54226" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "champions" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "34598" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "champions" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "106424" "$opFile" &> /dev/null
diff "$opFile" "assets/output/champions.test-02.data" &> /dev/null
logResult "$?" "false" "true"

# -- Given an ``int pid`` that doesn't exist, returns <= 0.
rm -f "$opFile"
timeout -k 0 5s java -jar driver.jar "champions" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "12345" "$opFile" &> /dev/null
if [ -f "$opFile" ]
then
    val=$(cat "$opFile")
    if [ "$val" -le 0 ]
    then
        echo "true" | tee -a "$REPORT_FILE"
    else
        echo "false" | tee -a "$REPORT_FILE"
    fi
else
    echo "false" | tee -a "$REPORT_FILE"
fi

##################################
#   getCourtInfo()
##################################
echo "Run Test -- getCourtInfo()" | tee -a "$REPORT_FILE"

psql -f "assets/a2.ddl" "$STUDENT_AUTH" &> /dev/null
psql -f "assets/country/01.sql" "$STUDENT_AUTH" &> /dev/null
psql -f "assets/tournament/01.sql" "$STUDENT_AUTH" &> /dev/null
psql -f "assets/court/01.sql" "$STUDENT_AUTH" &> /dev/null

# -- Given an ``int courtid`` that doesn't exist, returns the empty string.
rm -f "$opFile"
timeout -k 0 5s java -jar driver.jar "courtinfo" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "12345" "$opFile" &> /dev/null
diff "$opFile" "assets/empty.txt" &> /dev/null
logResult "$?" "false" "true"

# -- Given valid parameters, returns a correctly formatted string.
rm -f "$opFile"
timeout -k 0 5s java -jar driver.jar "courtinfo" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "147232" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "courtinfo" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "693172" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "courtinfo" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "678057" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "courtinfo" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "608369" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "courtinfo" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "181993" "$opFile" &> /dev/null
diff "$opFile" "assets/output/court.01.test-01.data" &> /dev/null
logResult "$?" "false" "true"

##################################
#   chgRecord()
##################################
echo "Run Test -- chgRecord()" | tee -a "$REPORT_FILE"

function setupChange() {
    rm -f "$opFile"
    psql -f "assets/a2.ddl" "$STUDENT_AUTH" &> /dev/null
    psql -f "assets/country/01.sql" "$STUDENT_AUTH" &> /dev/null
    psql -f "assets/player/01.sql" "$STUDENT_AUTH" &> /dev/null
    psql -f "assets/record/01.sql" "$STUDENT_AUTH" &> /dev/null
}

# -- Given an ``int pid`` that does not exist, no records are updated.
setupChange
timeout -k 0 5s java -jar driver.jar "change" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "12345" "1990" "0" "0" "$opFile" &> /dev/null
diff "$opFile" "assets/false.txt" &> /dev/null
logResult "$?" "false" "true"
psql -c "SELECT * FROM A2.record ORDER BY (pid, year) ASC;" "$STUDENT_AUTH" > "$opFile"
diff "$opFile" "assets/output/record.01.normal.data" &> /dev/null
logResult "$?" "false" "true"

# -- Given an ``int year`` that an ``int pid`` did not play in, no records are updated.
setupChange
timeout -k 0 5s java -jar driver.jar "change" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "54226" "12345" "0" "0" "$opFile" &> /dev/null
diff "$opFile" "assets/false.txt" &> /dev/null
logResult "$?" "false" "true"
psql -c "SELECT * FROM A2.record ORDER BY (pid, year) ASC;" "$STUDENT_AUTH" > "$opFile"
diff "$opFile" "assets/output/record.01.normal.data" &> /dev/null
logResult "$?" "false" "true"

# -- Given valid parameters, the correct player is updated.
setupChange
timeout -k 0 5s java -jar driver.jar "change" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "20579" "1956" "3" "4" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "change" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "52512" "1955" "0" "1" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "change" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "68081" "1962" "10" "33" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "change" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "88999" "1964" "0" "0" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "change" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "106747" "1963" "29" "38" "$opFile" &> /dev/null
diff "$opFile" "assets/output/record.01.test-01.data" &> /dev/null
logResult "$?" "false" "true"
psql -c "SELECT * FROM A2.record ORDER BY (pid, year) ASC;" "$STUDENT_AUTH" > "$opFile"
diff "$opFile" "assets/output/record.01.test-02.data" &> /dev/null
logResult "$?" "false" "true"

##################################
#   deleteMatchBetween()
##################################
echo "Run Test -- deleteMatchBetween()" | tee -a "$REPORT_FILE"

function setupDelete() {
    rm -f "$opFile"
    psql -f "assets/a2.ddl" "$STUDENT_AUTH" &> /dev/null
    psql -f "assets/country/01.sql" "$STUDENT_AUTH" &> /dev/null
    psql -f "assets/player/01.sql" "$STUDENT_AUTH" &> /dev/null
    psql -f "assets/tournament/01.sql" "$STUDENT_AUTH" &> /dev/null
    psql -f "assets/court/01.sql" "$STUDENT_AUTH" &> /dev/null
    psql -f "assets/event/01.sql" "$STUDENT_AUTH" &> /dev/null
}

# -- Given an ``int p1id`` or ``int p2id`` that does not exist, no records are updated.
setupDelete
timeout -k 0 5s java -jar driver.jar "delete" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "12345" "67890" "$opFile" &> /dev/null
diff "$opFile" "assets/false.txt" &> /dev/null
logResult "$?" "false" "true"
psql -c "SELECT * FROM A2.event ORDER BY eid ASC;" "$STUDENT_AUTH" > "$opFile"
diff "$opFile" "assets/output/delete.01.normal.data" &> /dev/null
logResult "$?" "false" "true"

# -- Given parameters ``(winner, loser)`` as ``(p1id, p2id)``, records are correctly updated.
setupDelete
timeout -k 0 5s java -jar driver.jar "delete" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "106424" "24058" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "delete" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "101648" "33439" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "delete" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "68064" "24804" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "delete" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "60808" "20579" "$opFile" &> /dev/null
diff "$opFile" "assets/output/delete.01.test-01.data" &> /dev/null
logResult "$?" "false" "true"
psql -c "SELECT * FROM A2.event ORDER BY eid ASC;" "$STUDENT_AUTH" > "$opFile"
diff "$opFile" "assets/output/delete.01.test-02.data" &> /dev/null
logResult "$?" "false" "true"

# -- Given parameters ``(loser, winner)`` as ``(p1id, p2id)``, records are correctly updated.
setupDelete
timeout -k 0 5s java -jar driver.jar "delete" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "24058" "106424" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "delete" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "33439" "101648" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "delete" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "24804" "68064" "$opFile" &> /dev/null
timeout -k 0 5s java -jar driver.jar "delete" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "20579" "60808" "$opFile" &> /dev/null
diff "$opFile" "assets/output/delete.01.test-01.data" &> /dev/null
logResult "$?" "false" "true"
psql -c "SELECT * FROM A2.event ORDER BY eid ASC;" "$STUDENT_AUTH" > "$opFile"
diff "$opFile" "assets/output/delete.01.test-02.data" &> /dev/null
logResult "$?" "false" "true"

##################################
#   listPlayerRanking()
##################################
echo "Run Test -- listPlayerRanking()" | tee -a "$REPORT_FILE"

# -- Given a relation with no entries, returns the empty string.
rm -f "$opFile"
psql -f "assets/a2.ddl" "$STUDENT_AUTH" &> /dev/null
timeout -k 0 5s java -jar driver.jar "list" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "$opFile" &> /dev/null
diff "$opFile" "assets/empty.txt" &> /dev/null
logResult "$?" "false" "true"

# -- Given a populated relation table, returns the correct rankings.
rm -f "$opFile"
psql -f "assets/a2.ddl" "$STUDENT_AUTH" &> /dev/null
psql -f "assets/country/01.sql" "$STUDENT_AUTH" &> /dev/null
psql -f "assets/player/01.sql" "$STUDENT_AUTH" &> /dev/null
timeout -k 0 5s java -jar driver.jar "list" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "$opFile" &> /dev/null
diff "$opFile" "assets/output/list.01.test-01.asc.data" &> /dev/null # We ignore order. Check both ASC and DESC traces.
logResult "$?" "false" "true"
diff "$opFile" "assets/output/list.01.test-01.desc.data" &> /dev/null
logResult "$?" "false" "true"

##################################
#   findTriCircle()
##################################
echo "Run Test -- findTriCircle()" | tee -a "$REPORT_FILE"

# -- Given a relation with no tri-circles, returns 0.
rm -f "$opFile"
psql -f "assets/a2.ddl" "$STUDENT_AUTH" &> /dev/null
timeout -k 0 5s java -jar driver.jar "tricircle" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "$opFile" &> /dev/null
diff "$opFile" "assets/output/tri.01.test-01.data" &> /dev/null
logResult "$?" "false" "true"

# -- Given a relation with 1 tri-circle (A, B, C), returns 1.
rm -f "$opFile"
psql -f "assets/a2.ddl" "$STUDENT_AUTH" &> /dev/null
psql -f "assets/tri/tri-test-01.sql" "$STUDENT_AUTH" &> /dev/null
timeout -k 0 5s java -jar driver.jar "tricircle" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "$opFile" &> /dev/null
diff "$opFile" "assets/output/tri.02.test-01.data" &> /dev/null
logResult "$?" "false" "true"

# -- Given a relation with 1 tri-circle (A, C, B), returns 1.
rm -f "$opFile"
psql -f "assets/a2.ddl" "$STUDENT_AUTH" &> /dev/null
psql -f "assets/tri/tri-test-02.sql" "$STUDENT_AUTH" &> /dev/null
timeout -k 0 5s java -jar driver.jar "tricircle" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "$opFile" &> /dev/null
diff "$opFile" "assets/output/tri.02.test-01.data" &> /dev/null
logResult "$?" "false" "true"

# -- Given a relation with N tri-circles, returns N.
rm -f "$opFile"
psql -f "assets/a2.ddl" "$STUDENT_AUTH" &> /dev/null
psql -f "assets/tri/tri-test-03.sql" "$STUDENT_AUTH" &> /dev/null
timeout -k 0 5s java -jar driver.jar "tricircle" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "$opFile" &> /dev/null
diff "$opFile" "assets/output/tri.03.test-01.data" &> /dev/null
logResult "$?" "false" "true"

##################################
#   updateDB()
##################################
echo "Run Test -- updateDB()" | tee -a "$REPORT_FILE"

rm -f "$opFile"
psql -f "assets/a2.ddl" "$STUDENT_AUTH" &> /dev/null
psql -f "assets/country/01.sql" "$STUDENT_AUTH" &> /dev/null
psql -f "assets/player/01.sql" "$STUDENT_AUTH" &> /dev/null
psql -f "assets/tournament/01.sql" "$STUDENT_AUTH" &> /dev/null
psql -f "assets/champion/01.sql" "$STUDENT_AUTH" &> /dev/null

timeout -k 0 5s java -jar driver.jar "update" "$SQL_ADDR" "$STUDENT_USER" "$STUDENT_PASSWORD" "$opFile" &> /dev/null
diff "$opFile" "assets/true.txt" &> /dev/null
logResult "$?" "false" "true"

psql -c "SELECT * FROM A2.championPlayers ORDER BY pid ASC;" "$STUDENT_AUTH" &> "$opFile"
cat "$opFile" | grep -q "does not exist"
logResult "$?" "true" "false" # If it contains this string, then we have a problem.

diff "$opFile" "assets/output/update.01.test-01.data" &> /dev/null
logResult "$?" "false" "true"

##################################
#   Automarker completed.
##################################
echo "Report file: $REPORT_FILE"
