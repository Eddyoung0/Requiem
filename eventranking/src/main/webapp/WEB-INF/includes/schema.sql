-- ═══════════════════════════════════════════════════════════════
-- Smart Campus Notice Board — Database Schema
-- Run this file in your MySQL client:
--   mysql -u root -p < schema.sql
-- ═══════════════════════════════════════════════════════════════
CREATE DATABASE IF NOT EXISTS event_ranking_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE event_ranking_db;

-- USERS 
CREATE TABLE IF NOT EXISTS users (
    user_id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'student') NOT NULL DEFAULT 'student',
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    INDEX idx_email (email),
    INDEX idx_role (role)
);

-- ── EVENTS 
CREATE TABLE IF NOT EXISTS events (
    event_id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    event_date DATE NOT NULL,
    location VARCHAR(200),
    contact_email VARCHAR(150),
    created_by INT NOT NULL,
    status ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (event_id),
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_status (status),
    INDEX idx_category (category),
    INDEX idx_date (event_date)
);

-- ── VOTES ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS votes (
    vote_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    event_id INT NOT NULL,
    vote_value TINYINT NOT NULL DEFAULT 1,
    -- 1 = upvote
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (vote_id),
    UNIQUE KEY uq_user_event_vote (user_id, event_id),
    -- one vote per user per event
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE
);

-- ── BOOKMARKS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS bookmarks (
    bookmark_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    event_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (bookmark_id),
    UNIQUE KEY uq_user_event_bm (user_id, event_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE
);

-- ── VIEWS ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS views (
    view_id INT NOT NULL AUTO_INCREMENT,
    user_id INT,
    -- NULL for anonymous visitors
    event_id INT NOT NULL,
    ip_address VARCHAR(45),
    viewed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (view_id),
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    INDEX idx_event_id (event_id),
    INDEX idx_viewed_at (viewed_at)
);

-- ═══════════════════════════════════════════════════════════════
-- RANKING VIEW
-- Returns events with computed ranking score and board position.
-- Score = (votes × 3) + (bookmarks × 2) + views
-- ═══════════════════════════════════════════════════════════════
CREATE
OR REPLACE VIEW v_ranked_events AS
SELECT
    e.event_id,
    e.title,
    e.description,
    e.category,
    e.event_date,
    e.location,
    e.contact_email,
    e.created_by,
    u.name AS created_by_name,
    e.status,
    e.created_at,
    COALESCE(v.vote_count, 0) AS vote_count,
    COALESCE(b.bookmark_count, 0) AS bookmark_count,
    COALESCE(vw.view_count, 0) AS view_count,
    (COALESCE(v.vote_count, 0) * 3) + (COALESCE(b.bookmark_count, 0) * 2) + COALESCE(vw.view_count, 0) AS ranking_score,
    RANK() OVER (
        ORDER BY
            (COALESCE(v.vote_count, 0) * 3) + (COALESCE(b.bookmark_count, 0) * 2) + COALESCE(vw.view_count, 0) DESC
    ) AS board_rank
FROM
    events e
    JOIN users u ON e.created_by = u.user_id
    LEFT JOIN (
        SELECT
            event_id,
            COUNT(*) AS vote_count
        FROM
            votes
        GROUP BY
            event_id
    ) v ON e.event_id = v.event_id
    LEFT JOIN (
        SELECT
            event_id,
            COUNT(*) AS bookmark_count
        FROM
            bookmarks
        GROUP BY
            event_id
    ) b ON e.event_id = b.event_id
    LEFT JOIN (
        SELECT
            event_id,
            COUNT(*) AS view_count
        FROM
            views
        GROUP BY
            event_id
    ) vw ON e.event_id = vw.event_id
WHERE
    e.status = 'approved';

-- ═══════════════════════════════════════════════════════════════
-- SEED DATA — default admin account
-- Password: admin123  (BCrypt hash below)
-- Change the password after first login!
-- ═══════════════════════════════════════════════════════════════
INSERT
    IGNORE INTO users (name, email, password, role, status)
VALUES
    (
        'Admin',
        'admin@campus.edu',
        '$2a$10$EbqHT5KJtWFGLwCqfvbgK.7.sKlVXMl5PK3Vu2HWyHXkXQ4p3lLyW',
        -- admin123
        'admin',
        'active'
    );

-- Sample approved events (for UI preview)
INSERT
    IGNORE INTO users (name, email, password, role, status)
VALUES
    (
        'Demo Student',
        'student@campus.edu',
        '$2a$10$EbqHT5KJtWFGLwCqfvbgK.7.sKlVXMl5PK3Vu2HWyHXkXQ4p3lLyW',
        'student',
        'active'
    );

INSERT
    IGNORE INTO events (
        title,
        description,
        category,
        event_date,
        location,
        created_by,
        status
    )
VALUES
    (
        'Annual Hackathon 2025',
        'A 24-hour coding marathon open to all students. Form teams of 2-4, build innovative solutions, and compete for prizes worth NPR 50,000!',
        'Competition',
        '2025-06-15',
        'Main Auditorium',
        1,
        'approved'
    ),
    (
        'Python for Data Science Workshop',
        'A hands-on 3-day workshop covering Python basics, pandas, matplotlib, and introductory machine learning with scikit-learn.',
        'Workshop',
        '2025-05-28',
        'Computer Lab A, Block B',
        1,
        'approved'
    ),
    (
        'Summer Internship Fair',
        'Meet representatives from 30+ tech and finance companies offering summer internship positions. Bring your CV!',
        'Internship',
        '2025-05-20',
        'Multipurpose Hall',
        2,
        'approved'
    ),
    (
        'Drama Club: Annual Production',
        'The Drama Club presents "Echoes of Tomorrow" — a two-hour original play written and performed entirely by students.',
        'Club Activity',
        '2025-07-01',
        'College Auditorium',
        2,
        'approved'
    ),
    (
        'AI and the Future: Guest Lecture',
        'Distinguished speaker from a top AI research lab will discuss trends in generative AI, ethics, and career paths.',
        'Seminar',
        '2025-05-25',
        'Lecture Hall 3',
        1,
        'approved'
    );

-- ═══════════════════════════════════════════════════════════════
-- CATEGORIES (Phase 3)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS categories (
    category_id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    icon VARCHAR(10) NOT NULL DEFAULT '📌',
    display_order INT NOT NULL DEFAULT 99,
    active TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (category_id)
);

-- Seed default categories matching the original hardcoded list
INSERT
    IGNORE INTO categories (name, icon, display_order)
VALUES
    ('Campus Event', '🎓', 1),
    ('Workshop', '🔧', 2),
    ('Competition', '🏆', 3),
    ('Internship', '💼', 4),
    ('Club Activity', '🎭', 5),
    ('Seminar', '📖', 6),
    ('Other', '📌', 99);

-- ═══════════════════════════════════════════════════════════════
-- REMEMBER ME TOKENS (Phase 3)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS remember_tokens (
    token_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    token VARCHAR(64) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    PRIMARY KEY (token_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_token (token)
);