# CSCC43 Fall 2020 - Assignment 2 JDBC Marking Scheme

## Constructor (1.0 marks)

```
Class.forName("org.postgresql.Driver");
```

| Weight | Description |
| --- | --- |
| 1.0 | There are many drivers for various versions of SQL (MySQL, PostgreSQL, MariaDB, etc...). You are expected to initialize the PostgreSQL driver in the constructor. |

## connectDB (2.0 marks)

```
connection = DriverManager.getConnection(URL, username, password);
```

| Weight | Description |
| --- | --- |
| 1.0 | Given invalid parameters, no connection is established. |
| 1.0 | Given valid credentials, a connection is established. |

## disconnectDB (2.0 marks)

```
connection.close();
```

| Weight | Description |
| --- | --- |
| 0.5 | No connection previously existed. The closure attempt fails. |
| 0.5 | The previous connection was already closed. The closure attempt fails. |
| 1.0 | A connection was previously established. The closure attempt succeeds. |

## insertPlayer (5.0 marks)

```
INSERT INTO player
VALUES (?, ?, ?, ?)
```

| Weight | Description |
| --- | --- |
| 2.0 | Given valid parameters, the insertion succeeds. |
| 0.5 | Given an ``int pid`` that violates the ``PRIMARY KEY`` constraint, the insertion fails. |
| 0.5 | Given an ``int cid`` that violates the ``FOREIGN KEY`` reference, the insertion fails. |
| 2.0 | Given a malicious ``String`` for ``String pname``, the insertion succeeds. |

## getChampions (5.0 marks)

```
SELECT COUNT(*)
FROM champion
WHERE pid = ?
```

| Weight | Description |
| --- | --- |
| 1.0 | Given an ``int pid`` that doesn't exist, returns <= 0. |
| 1.0 | Given an ``int pid`` with a single championship, returns 1. |
| 3.0 | Given an ``int pid`` with N championships, return N. |

## getCourtInfo (5.0 marks)

```
SELECT (c.courtid, c.courtname, c.capacity, t.tname)
FROM court c, tournament t
WHERE c.tid = t.tid
AND c.courtid = ?
```

| Weight | Description |
| --- | --- |
| 1.0 | Given an ``int courtid`` that doesn't exist, returns the empty string. |
| 4.0 | Given valid parameters, returns a correctly formatted string. |

## chgRecord (5.0 marks)

```
UPDATE record
SET wins = ?, losses = ?
WHERE pid = ? AND year = ?
```

| Weight | Description |
| --- | --- |
| 1.0 | Given an ``int pid`` that does not exist, no records are updated. |
| 1.0 | Given an ``int year`` that an ``int pid`` did not play in, no records are updated. |
| 3.0 | Given valid parameters, the correct player is updated. |

## deleteMatchBetween (5.0 marks)

```
DELETE FROM event
WHERE (winid = ? AND lossid = ?)
OR (winid = ? AND lossid = ?)
```

| Weight | Description |
| --- | --- |
| 1.0 | Given an ``int p1id`` or ``int p2id`` that does not exist, no records are updated. |
| 2.0 | Given parameters ``(winner, loser)`` as ``(p1id, p2id)``, records are correctly updated. |
| 2.0 | Given parameters ``(loser, winner)`` as ``(p1id, p2id)``, records are correctly updated. |

## listPlayerRanking (5.0 marks)

```
SELECT pname, globalrank
FROM player
ORDER BY globalrank DESC
```

| Weight | Description |
| --- | --- |
| 1.0 | Given a relation with no entries, returns the empty string. |
| 4.0 | Given a populated relation table, returns the correct rankings. |

## findTriCircle (5.0 marks)
```
SELECT COUNT(*) FROM
(
    SELECT e1.winid, e2.winid, e3.winid
    FROM event e1, event e2, event e3
    WHERE e1.winid < e2.winid AND e2.winid < e3.winid
    AND (
        (e1.winid = e3.lossid AND e2.winid = e1.lossid AND e3.winid = e2.lossid)
        OR
        (e1.winid = e2.lossid AND e2.winid = e3.lossid AND e3.winid = e1.lossid)
    )
) alias;
```

| Weight | Description |
| --- | --- |
| 0.5 | Given a relation with no tri-circles, returns 0. |
| 0.5 | Given a relation with 1 tri-circle (A, B, C), returns 1. |
| 0.5 | Given a relation with 1 tri-circle (A, C, B), returns 1. |
| 3.5 | Given a relation with N tri-circles, returns N. |

## updateDB (5.0 marks)
```
CREATE TABLE championPlayers (
    pid INTEGER,
    pname VARCHAR NOT NULL,
    nchampions INTEGER
)

INSERT INTO championPlayers
(
    SELECT p.pid, p.pname, COUNT(c.tid) AS nchampions
    FROM player p
    JOIN champion c
    ON c.pid = p.pid
    GROUP BY p.pid
)
```

| Weight | Description |
| --- | --- |
| 2.0 | Given valid input parameters, a table ``championPlayers`` is created. |
| 3.0 | Given valid input parameters, the table ``championPlayers`` is populated correctly. |
