SET search_path TO A2;

INSERT INTO country VALUES (794951, 'Russia'); -- (cid, cname)

INSERT INTO player VALUES (31779, 'Aletha Swint', 1, 794951); -- (pid, pname, globalrank, cid)
INSERT INTO player VALUES (33939, 'Golda Hruska', 2, 794951);
INSERT INTO player VALUES (80884, 'Charita Kerbs', 3, 794951);

INSERT INTO tournament VALUES (99507, 'The National Russian Tournament', 794951); -- (tid, tname, cid)
INSERT INTO court VALUES (907592, 'e47188e21a', 5000, 99507); -- (courtid, courtname, capacity, tid)
INSERT INTO champion VALUES (31779, 2020, 99507); -- (pid, year, tid)

INSERT INTO record VALUES (31779, 2020, 1, 1); -- (pid, year, wins, losses)
INSERT INTO record VALUES (33939, 2020, 1, 1);
INSERT INTO record VALUES (80884, 2020, 1, 1);

INSERT INTO event VALUES (729207, 2020, 907592, 31779, 33939, 40); -- eid, year, courtid, winid, lossid, duration
INSERT INTO event VALUES (843916, 2020, 907592, 33939, 80884, 89);
INSERT INTO event VALUES (303234, 2020, 907592, 80884, 31779, 57);
