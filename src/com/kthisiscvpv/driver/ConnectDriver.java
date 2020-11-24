package com.kthisiscvpv.driver;

import com.kthisiscvpv.Assignment2;
import com.kthisiscvpv.RunnableDriver;

public class ConnectDriver extends RunnableDriver {

	@Override
	public void help() {
		System.err.println("Input:");
		System.err.println("\t[URL] [User] [Password] [Output File]");

		System.err.println("Output:");
		System.err.println("\t[a=Boolean]");

		System.err.println("Description:");
		System.err.println("\ta -> Test was successfully executed.");
	}

	@Override
	public void run(String... args) throws Exception {
		if (args.length != 4) {
			help();
			System.exit(1);
		}

		Class.forName("org.postgresql.Driver");
		Assignment2 a2 = new Assignment2();

		boolean status = a2.connectDB(args[0], args[1], args[2]);
		appendFile(Boolean.toString(status), args[3]);

		if (a2.connection != null && !a2.connection.isClosed())
			a2.connection.close();
	}
}
