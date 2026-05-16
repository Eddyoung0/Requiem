package com.eventranking.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // Connection settings
    private static final String URL = "jdbc:mysql://localhost:3306/event_ranking_db"
            + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USERNAME = "root"; // MySQL username
    private static final String PASSWORD = "1234"; // MySQL password


    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC driver not found", e);
        }
    }

    /**
     * Returns a new database connection.
     * Caller is responsible for closing it (use try-with-resources).
     */

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }

    private DBConnection() {
    } // utility class — no instances
}
