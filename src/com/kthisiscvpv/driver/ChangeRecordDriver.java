package com.kthisiscvpv.driver;

import java.sql.DriverManager;

import com.kthisiscvpv.Assignment2;
import com.kthisiscvpv.RunnableDriver;

public class ChangeRecordDriver extends RunnableDriver {

	@Override
	public void help() {
		System.err.println("Input:");
		System.err.println("\t[URL] [User] [Password] [pid] [year] [wins] [losses] [Output File]");

		System.err.println("Output:");
		System.err.println("\t[a=Boolean]");

		System.err.println("Description:");
		System.err.println("\ta -> Reported result of player update query.");
	}

	@Override
	public void run(String... args) throws Exception {
		if (args.length != 8) {
			help();
			System.exit(1);
		}

		Class.forName("org.postgresql.Driver");
		Assignment2 a2 = new Assignment2();
		a2.connection = DriverManager.getConnection(args[0], args[1], args[2]);

		int pid = Integer.parseInt(args[3]);
		int year = Integer.parseInt(args[4]);
		int wins = Integer.parseInt(args[5]);
		int losses = Integer.parseInt(args[6]);

		boolean result = a2.chgRecord(pid, year, wins, losses);
		appendFile(Boolean.toString(result), args[7]);

		a2.connection.close();
	}
}
