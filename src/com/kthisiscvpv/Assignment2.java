package com.kthisiscvpv;

import java.sql.*;

public class Assignment2 {

	public Connection connection;

	private Statement sql;
	private PreparedStatement ps;
	private ResultSet rs;

	public Assignment2() {

	}

	/**
	 * Using the input parameters, establish a connection to be used for this
	 * session. Returns true if connection is successful.
	 * 
	 * @param URL      JDBC complete server address
	 * @param username SQL server account username
	 * @param password SQL server account password
	 * @return connection with SQL server successfully established
	 */
	public boolean connectDB(String URL, String username, String password) {
		return false;
	}

	/**
	 * Disconnects the session from the server.
	 * 
	 * @return active session with SQL server successfully terminated
	 */
	public boolean disconnectDB() {
		return false;
	}

	public boolean insertPlayer(int pid, String pname, int globalRank, int cid) {
		return false;
	}

	public int getChampions(int pid) {
		return 0;
	}

	public String getCourtInfo(int courtid) {
		return "";
	}

	public boolean chgRecord(int pid, int year, int wins, int losses) {
		return false;
	}

	public boolean deleteMatchBetween(int p1id, int p2id) {
		return false;
	}

	public String listPlayerRanking() {
		return "";
	}

	public int findTriCircle() {
		return 0;
	}

	public boolean updateDB() {
		return false;
	}
}
