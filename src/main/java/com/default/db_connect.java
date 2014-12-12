package com.default;

import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


public class db_connect{
	public static Connection getConnection() throws URISyntaxException, SQLException {
		
		String username = "";
		String password = "";
		String dbUrl = "";
		URI dbUri = null;
		
		if(System.getenv("DATABASE_URL") != null){
			dbUri = new URI(System.getenv("DATABASE_URL"));
		}else{
			dbUri = new URI("");
		}

		username = dbUri.getUserInfo().split(":")[0];
		password = dbUri.getUserInfo().split(":")[1];
		
		dbUrl = "jdbc:postgresql://" + dbUri.getHost() + dbUri.getPath() + (System.getenv("DATABASE_URL") != null ? "" : "?ssl=true&sslfactory=org.postgresql.ssl.NonValidatingFactory");

		
		return DriverManager.getConnection(dbUrl, username, password);
	}
}