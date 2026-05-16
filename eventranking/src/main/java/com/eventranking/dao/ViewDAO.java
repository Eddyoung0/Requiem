package com.eventranking.dao;

import com.eventranking.util.DBConnection;
import java.sql.*;

/**
 * DAO for the views table.
 * Records a view each time a user opens an event details page.
 * Views contribute ×1 to the ranking score.
 */
public class ViewDAO {

    /**
     * Record a view for an event.
     * Prevents duplicate views from the same user within 1 hour.
     *
     * @param userId    0 = anonymous visitor
     * @param eventId   the event being viewed
     * @param ipAddress client IP (used for anonymous dedup)
     */
    public void recordView(int userId, int eventId, String ipAddress) throws SQLException {
        // Deduplication: skip if same user viewed this event in the last 60 minutes
        if (userId > 0 && recentlyViewed(userId, eventId)) return;

        String sql = "INSERT INTO views (user_id, event_id, ip_address) VALUES (?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (userId > 0) ps.setInt(1, userId); else ps.setNull(1, Types.INTEGER);
            ps.setInt(2, eventId);
            ps.setString(3, ipAddress);
            ps.executeUpdate();
        }
    }

    private boolean recentlyViewed(int userId, int eventId) throws SQLException {
        String sql = """
            SELECT COUNT(*) FROM views
            WHERE user_id=? AND event_id=?
              AND viewed_at > NOW() - INTERVAL 60 MINUTE
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId); ps.setInt(2, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public int countViews(int eventId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM views WHERE event_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /** Total views on all events created by a given user. */
    public int totalViewsOnUserEvents(int userId) throws SQLException {
        String sql = """
            SELECT COUNT(*) FROM views v
            JOIN events e ON v.event_id = e.event_id
            WHERE e.created_by = ?
            """;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}

