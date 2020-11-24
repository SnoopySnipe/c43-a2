package com.kthisiscvpv;

import java.util.HashMap;
import java.util.Map;

import com.kthisiscvpv.driver.ChangeRecordDriver;
import com.kthisiscvpv.driver.ConnectDriver;
import com.kthisiscvpv.driver.ConstructorDriver;
import com.kthisiscvpv.driver.DeleteMatchDriver;
import com.kthisiscvpv.driver.DisconnectDriver;
import com.kthisiscvpv.driver.GetChampionsDriver;
import com.kthisiscvpv.driver.GetCourtInfoDriver;
import com.kthisiscvpv.driver.InsertDriver;
import com.kthisiscvpv.driver.ListDriver;
import com.kthisiscvpv.driver.TriCircleDriver;
import com.kthisiscvpv.driver.UpdateDriver;

public class App {

	public static String[] subarray(String[] args, int index) {
		int count = Math.max(0, args.length - index);
		String[] arr = new String[count];
		for (int i = 0; i < count; i++)
			arr[i] = args[index + i];
		return arr;
	}

	public static void main(String[] args) throws Exception {
		Map<String, Class<? extends RunnableDriver>> drivers = new HashMap<>();
		drivers.put("constructor", ConstructorDriver.class);
		drivers.put("connect", ConnectDriver.class);
		drivers.put("disconnect", DisconnectDriver.class);
		drivers.put("insert", InsertDriver.class);
		drivers.put("champions", GetChampionsDriver.class);
		drivers.put("courtinfo", GetCourtInfoDriver.class);
		drivers.put("change", ChangeRecordDriver.class);
		drivers.put("delete", DeleteMatchDriver.class);
		drivers.put("list", ListDriver.class);
		drivers.put("tricircle", TriCircleDriver.class);
		drivers.put("update", UpdateDriver.class);

		if (args.length == 0) {
			System.err.println("Input:");
			System.err.println("\t[Driver] [Driver Arguments ...]");
			System.exit(1);
		}

		String driver = args[0].toLowerCase().trim();
		if (!drivers.containsKey(driver)) {
			System.err.println("Invalid driver. Valid drivers are " + drivers.keySet());
			System.exit(1);
		}

		String[] dArgs = subarray(args, 1);
		RunnableDriver rd = drivers.get(driver).getConstructor().newInstance();
		rd.run(dArgs);
	}
}
