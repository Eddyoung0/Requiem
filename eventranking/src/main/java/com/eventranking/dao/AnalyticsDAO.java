package com.eventranking.dao;

import com.eventranking.util.DBConnection;
import java.sql.*;
import java.util.*;

/**
 * Provides aggregated analytics data for the admin dashboard charts.
 * All methods return simple structures (List/Map) that JSP can render
 * and the analytics.jsp can turn into Chart.js datasets.
 */
public class AnalyticsDAO {

    /**
     * Daily event engagement for the last N days.
     * Returns list of maps: {date, votes, bookmarks, views}
     */
    public List<Map<String, Object>> getDailyEngagement(int days) throws SQLException {
        String sql = """
            SELECT DATE(v.created_at)  AS day,
                   COUNT(*)            AS votes
            FROM votes v
            WHERE v.created_at >= CURDATE() - INTERVAL ? DAY
            GROUP BY DATE(v.created_at)
            ORDER BY day ASC
            """;

        // Collect votes per day
        Map<String, Map<String, Object>> dayMap = new LinkedHashMap<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String d = rs.getString("day");
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("date",      d);
                    row.put("votes",     rs.getInt("votes"));
                    row.put("bookmarks", 0);
                    row.put("views",     0);
                    dayMap.put(d, row);
                }
            }
        }

        // Merge bookmarks
        String sqlBm = """
            SELECT DATE(created_at) AS day, COUNT(*) AS cnt
            FROM bookmarks
            WHERE created_at >= CURDATE() - INTERVAL ? DAY
            GROUP BY DATE(created_at)
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sqlBm)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String d = rs.getString("day");
                    dayMap.computeIfAbsent(d, k -> {
                        Map<String, Object> r = new LinkedHashMap<>();
                        r.put("date", k); r.put("votes", 0); r.put("bookmarks", 0); r.put("views", 0);
                        return r;
                    }).put("bookmarks", rs.getInt("cnt"));
                }
            }
        }

        // Merge views
        String sqlVw = """
            SELECT DATE(viewed_at) AS day, COUNT(*) AS cnt
            FROM views
            WHERE viewed_at >= CURDATE() - INTERVAL ? DAY
            GROUP BY DATE(viewed_at)
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sqlVw)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String d = rs.getString("day");
                    dayMap.computeIfAbsent(d, k -> {
                        Map<String, Object> r = new LinkedHashMap<>();
                        r.put("date", k); r.put("votes", 0); r.put("bookmarks", 0); r.put("views", 0);
                        return r;
                    }).put("views", rs.getInt("cnt"));
                }
            }
        }

        // Sort by date and return
        List<Map<String, Object>> result = new ArrayList<>(dayMap.values());
        result.sort(Comparator.comparing(m -> m.get("date").toString()));
        return result;
    }

    /**
     * Event count by category (approved events only).
     * Returns list of maps: {category, count}
     */
    public List<Map<String, Object>> getEventsByCategory() throws SQLException {
        String sql = """
            SELECT category, COUNT(*) AS cnt
            FROM events WHERE status='approved'
            GROUP BY category ORDER BY cnt DESC
            """;
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             Statement  st  = con.createStatement();
             ResultSet  rs  = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("category", rs.getString("category"));
                row.put("count",    rs.getInt("cnt"));
                list.add(row);
            }
        }
        return list;
    }

    /**
     * New user registrations per day for the last N days.
     * Returns list of maps: {date, count}
     */
    public List<Map<String, Object>> getDailyRegistrations(int days) throws SQLException {
        String sql = """
            SELECT DATE(created_at) AS day, COUNT(*) AS cnt
            FROM users
            WHERE created_at >= CURDATE() - INTERVAL ? DAY
            GROUP BY DATE(created_at) ORDER BY day ASC
            """;
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("date",  rs.getString("day"));
                    row.put("count", rs.getInt("cnt"));
                    list.add(row);
                }
            }
        }
        return list;
    }

    /**
     * Top N most active users by total engagement (votes cast).
     * Returns list of maps: {name, votes}
     */
    public List<Map<String, Object>> getTopActiveUsers(int limit) throws SQLException {
        String sql = """
            SELECT u.name, COUNT(v.vote_id) AS vote_count
            FROM users u
            LEFT JOIN votes v ON u.user_id = v.user_id
            GROUP BY u.user_id, u.name
            ORDER BY vote_count DESC
            LIMIT ?
            """;
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("name",  rs.getString("name"));
                    row.put("votes", rs.getInt("vote_count"));
                    list.add(row);
                }
            }
        }
        return list;
    }

    /**
     * Summary totals for the analytics page header.
     */
    public Map<String, Integer> getSummaryTotals() throws SQLException {
        Map<String, Integer> totals = new LinkedHashMap<>();
        String[][] queries = {
            {"totalEvents",    "SELECT COUNT(*) FROM events WHERE status='approved'"},
            {"totalUsers",     "SELECT COUNT(*) FROM users"},
            {"totalVotes",     "SELECT COUNT(*) FROM votes"},
            {"totalBookmarks", "SELECT COUNT(*) FROM bookmarks"},
            {"totalViews",     "SELECT COUNT(*) FROM views"},
        };
        try (Connection con = DBConnection.getConnection()) {
            for (String[] q : queries) {
                try (Statement st = con.createStatement();
                     ResultSet rs = st.executeQuery(q[1])) {
                    totals.put(q[0], rs.next() ? rs.getInt(1) : 0);
                }
            }
        }
        return totals;
    }
}

