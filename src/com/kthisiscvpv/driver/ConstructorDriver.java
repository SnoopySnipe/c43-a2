package com.kthisiscvpv.driver;

import java.sql.DriverManager;

import com.kthisiscvpv.Assignment2;
import com.kthisiscvpv.RunnableDriver;

public class ConstructorDriver extends RunnableDriver {

	@Override
	public void help() {
		System.err.println("Input:");
		System.err.println("\t[URL] [User] [Password] [Output File]");

		System.err.println("Output:");
		System.err.println("\t[a=Boolean]");

		System.err.println("Description:");
		System.err.println("\ta -> Driver was successfully injected.");
	}

	@Override
	public void run(String... args) throws Exception {
		if (args.length != 4) {
			help();
			System.exit(1);
		}

		Assignment2 a2 = new Assignment2();
		a2.connection = DriverManager.getConnection(args[0], args[1], args[2]);
		a2.connection.close();

		appendFile("true", args[3]);
	}
}
