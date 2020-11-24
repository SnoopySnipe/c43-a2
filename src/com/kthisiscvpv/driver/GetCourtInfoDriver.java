package com.kthisiscvpv.driver;

import java.sql.DriverManager;

import com.kthisiscvpv.Assignment2;
import com.kthisiscvpv.RunnableDriver;

public class GetCourtInfoDriver extends RunnableDriver {

	@Override
	public void help() {
		System.err.println("Input:");
		System.err.println("\t[URL] [User] [Password] [courtid] [Output File]");

		System.err.println("Output:");
		System.err.println("\t[a=String]");

		System.err.println("Description:");
		System.err.println("\ta -> Reported information on given court.");
	}

	@Override
	public void run(String... args) throws Exception {
		if (args.length != 5) {
			help();
			System.exit(1);
		}

		Class.forName("org.postgresql.Driver");
		Assignment2 a2 = new Assignment2();
		a2.connection = DriverManager.getConnection(args[0], args[1], args[2]);

		int courtid = Integer.parseInt(args[3]);
		String courtinfo = a2.getCourtInfo(courtid).trim();
		appendFile(courtinfo, args[4]);

		a2.connection.close();
	}
}
