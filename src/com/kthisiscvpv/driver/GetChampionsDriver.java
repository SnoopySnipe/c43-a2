package com.kthisiscvpv.driver;

import java.sql.DriverManager;

import com.kthisiscvpv.Assignment2;
import com.kthisiscvpv.RunnableDriver;

public class GetChampionsDriver extends RunnableDriver {

	@Override
	public void help() {
		System.err.println("Input:");
		System.err.println("\t[URL] [User] [Password] [pid] [Output File]");

		System.err.println("Output:");
		System.err.println("\t[a=Integer]");

		System.err.println("Description:");
		System.err.println("\ta -> Reported number of champions of given player.");
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

		int pid = Integer.parseInt(args[3]);
		int champions = a2.getChampions(pid);
		appendFile(Integer.toString(champions), args[4]);

		a2.connection.close();
	}
}
