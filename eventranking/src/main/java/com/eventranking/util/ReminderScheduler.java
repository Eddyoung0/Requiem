package com.eventranking.util;

import com.eventranking.dao.BookmarkDAO;
import com.eventranking.dao.EventDAO;
import com.eventranking.dao.UserDAO;
import com.eventranking.model.Event;
import com.eventranking.model.User;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.sql.*;
import java.time.LocalDate;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Background scheduler that runs once per day.
 * Sends reminder emails to users who bookmarked events happening tomorrow.
 *
 * Registered as a ServletContextListener so it starts with the app
 * and shuts down cleanly when Tomcat stops.
 */
@WebListener
public class ReminderScheduler implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor();

        // Run at startup then every 24 hours
        scheduler.scheduleAtFixedRate(this::sendTomorrowReminders,
                0, 24, TimeUnit.HOURS);

        System.out.println("[ReminderScheduler] Started — daily reminder job scheduled.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) scheduler.shutdownNow();
        System.out.println("[ReminderScheduler] Stopped.");
    }

    // ── Job ──────────────────────────────────────────────────

    private void sendTomorrowReminders() {
        System.out.println("[ReminderScheduler] Running reminder check for "
                + LocalDate.now().plusDays(1));
        try {
            String sql = """
                SELECT DISTINCT u.user_id, u.name, u.email,
                       e.event_id, e.title, e.event_date, e.location
                FROM bookmarks bm
                JOIN users  u ON bm.user_id  = u.user_id
                JOIN events e ON bm.event_id = e.event_id
                WHERE e.status    = 'approved'
                  AND e.event_date = CURDATE() + INTERVAL 1 DAY
                  AND u.status    = 'active'
                """;

            String appUrl = "http://localhost:8080/EventRankingSystem";

            try (Connection con = DBConnection.getConnection();
                 Statement  st  = con.createStatement();
                 ResultSet  rs  = st.executeQuery(sql)) {

                int count = 0;
                while (rs.next()) {
                    String userName  = rs.getString("name");
                    String userEmail = rs.getString("email");
                    String title     = rs.getString("title");
                    String date      = rs.getDate("event_date").toString();
                    String location  = rs.getString("location");
                    int    eventId   = rs.getInt("event_id");

                    EmailService.sendEventReminderEmail(
                            userEmail, userName, title, date, location,
                            appUrl + "/event?id=" + eventId);
                    count++;
                }
                System.out.println("[ReminderScheduler] Sent " + count + " reminder(s).");
            }

        } catch (Exception e) {
            System.err.println("[ReminderScheduler] Error: " + e.getMessage());
        }
    }
}

