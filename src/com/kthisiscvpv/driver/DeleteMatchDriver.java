package com.kthisiscvpv.driver;

import java.sql.DriverManager;

import com.kthisiscvpv.Assignment2;
import com.kthisiscvpv.RunnableDriver;

public class DeleteMatchDriver extends RunnableDriver {

	@Override
	public void help() {
		System.err.println("Input:");
		System.err.println("\t[URL] [User] [Password] [p1id] [p2id] [Output File]");

		System.err.println("Output:");
		System.err.println("\t[a=Boolean]");

		System.err.println("Description:");
		System.err.println("\ta -> Match between players were successfully deleted.");
	}

	@Override
	public void run(String... args) throws Exception {
		if (args.length != 6) {
			help();
			System.exit(1);
		}

		Class.forName("org.postgresql.Driver");
		Assignment2 a2 = new Assignment2();
		a2.connection = DriverManager.getConnection(args[0], args[1], args[2]);

		int p1id = Integer.parseInt(args[3]);
		int p2id = Integer.parseInt(args[4]);

		boolean result = a2.deleteMatchBetween(p1id, p2id);
		appendFile(Boolean.toString(result), args[5]);

		a2.connection.close();
	}
}
