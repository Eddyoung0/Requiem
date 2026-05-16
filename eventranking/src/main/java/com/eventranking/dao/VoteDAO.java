package com.eventranking.dao;

import com.eventranking.util.DBConnection;
import java.sql.*;

/**
 * DAO for votes table.
 * One vote per user per event (enforced by unique key).
 */
public class VoteDAO {

    /** Returns true if the user has already voted for this event. */
    public boolean hasVoted(int userId, int eventId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM votes WHERE user_id=? AND event_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    /**
     * Record a vote. Returns the updated vote count for the event,
     * or -1 if the user already voted.
     */
    public int addVote(int userId, int eventId) throws SQLException {
        if (hasVoted(userId, eventId)) return -1;

        String insert = "INSERT INTO votes (user_id, event_id, vote_value) VALUES (?,?,1)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(insert)) {
            ps.setInt(1, userId);
            ps.setInt(2, eventId);
            ps.executeUpdate();
        }
        return countVotes(eventId);
    }

    /** Total votes for one event. */
    public int countVotes(int eventId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM votes WHERE event_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /** Total votes cast by a specific user. */
    public int countVotesByUser(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM votes WHERE user_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}

