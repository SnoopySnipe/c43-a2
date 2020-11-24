package com.kthisiscvpv.driver;

import java.sql.DriverManager;

import com.kthisiscvpv.Assignment2;
import com.kthisiscvpv.RunnableDriver;

public class InsertDriver extends RunnableDriver {

	@Override
	public void help() {
		System.err.println("Input:");
		System.err.println("\t[URL] [User] [Password] [pid] [pname] [globalRank] [cid] [Output File]");

		System.err.println("Output:");
		System.err.println("\t[a=Boolean]");

		System.err.println("Description:");
		System.err.println("\ta -> Player was successfully inserted into the database.");
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
		String pname = args[4];
		int globalRank = Integer.parseInt(args[5]);
		int cid = Integer.parseInt(args[6]);

		boolean status = a2.insertPlayer(pid, pname, globalRank, cid);
		appendFile(Boolean.toString(status), args[7]);

		a2.connection.close();
	}
}
