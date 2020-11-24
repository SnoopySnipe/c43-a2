package com.kthisiscvpv.driver;

import java.sql.DriverManager;

import com.kthisiscvpv.Assignment2;
import com.kthisiscvpv.RunnableDriver;

public class DisconnectDriver extends RunnableDriver {

	@Override
	public void help() {
		System.err.println("Input:");
		System.err.println("\t[URL] [User] [Password] [Method] [Output File]");

		System.err.println("Output:");
		System.err.println("\t[a=Boolean]");

		System.err.println("Description:");
		System.err.println("\ta -> Test was successfully executed.");
		System.err.println("\tm=1 -> Connection was NULL.");
		System.err.println("\tm=2 -> Connection was closed.");
		System.err.println("\tm=3 -> Connection was open.");
	}

	@Override
	public void run(String... args) throws Exception {
		if (args.length != 5) {
			help();
			System.exit(1);
		}

		Class.forName("org.postgresql.Driver");
		Assignment2 a2 = new Assignment2();

		int method = Integer.parseInt(args[3]);
		boolean status;

		if (method == 1) {
			a2.connection = null;
			status = a2.disconnectDB();

		} else if (method == 2) {
			a2.connection = DriverManager.getConnection(args[0], args[1], args[2]);
			a2.connection.close();
			status = a2.disconnectDB();

		} else if (method == 3) {
			a2.connection = DriverManager.getConnection(args[0], args[1], args[2]);
			status = a2.disconnectDB();

		} else
			throw new IllegalArgumentException(args[3] + " is not a valid method call.");

		appendFile(Boolean.toString(status), args[4]);
	}
}
