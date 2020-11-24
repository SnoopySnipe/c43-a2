package com.kthisiscvpv;

import java.io.File;
import java.io.FileWriter;
import java.io.PrintWriter;

public abstract class RunnableDriver {

	public abstract void help();

	public abstract void run(String... args) throws Exception;

	public void appendFile(String text, String path) {
		try {
			File file = new File(path);
			FileWriter fw = new FileWriter(file, true);
			PrintWriter pw = new PrintWriter(fw);

			pw.println(text);

			pw.close();
			fw.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
