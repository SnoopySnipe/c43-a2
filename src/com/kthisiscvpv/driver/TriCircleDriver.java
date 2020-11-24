package com.kthisiscvpv.driver;

import java.sql.DriverManager;

import com.kthisiscvpv.Assignment2;
import com.kthisiscvpv.RunnableDriver;

public class TriCircleDriver extends RunnableDriver {

	@Override
	public void help() {
		System.err.println("Input:");
		System.err.println("\t[URL] [User] [Password] [Output File]");

		System.err.println("Output:");
		System.err.println("\t[a=Integer]");

		System.err.println("Description:");
		System.err.println("\ta -> Report amount of tri-circles in the database.");
	}

	@Override
	public void run(String... args) throws Exception {
		if (args.length != 4) {
			help();
			System.exit(1);
		}

		Class.forName("org.postgresql.Driver");
		Assignment2 a2 = new Assignment2();
		a2.connection = DriverManager.getConnection(args[0], args[1], args[2]);

		int result = a2.findTriCircle();
		appendFile(Integer.toString(result), args[3]);

		a2.connection.close();
	}
}
