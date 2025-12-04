-- =============================================
-- CSC-584 Phase III: Database Operations
-- MindConnect+ Mental Health Support Application
-- =============================================

-- =============================================
-- SECTION 1: USER REGISTRATION & AUTHENTICATION
-- =============================================

-- SCENARIO 1: New user registers for the application
-- User submits: userName, email, userPassword, privacySetting
-- Result: New user account created with auto-generated userID
-- Operation: INSERT
INSERT INTO AppUser VALUES (6, 'Frank Thompson', 'frank@email.com', 'hash567', 'private');

-- Verification Query
SELECT * FROM AppUser WHERE userID = 6;


-- SCENARIO 2: User login - verify credentials
-- User submits: email, password
-- Result: User details if credentials match
-- Operation: SELECT with WHERE clause
SELECT userID, userName, email, privacySetting 
FROM AppUser 
WHERE email = 'alice@email.com' AND userPassword = 'hash123';


-- SCENARIO 3: Update user privacy settings
-- User submits: userID, new privacySetting
-- Result: Privacy setting updated
-- Operation: UPDATE
UPDATE AppUser 
SET privacySetting = 'friends' 
WHERE userID = 1;

-- Verification
SELECT userID, userName, privacySetting FROM AppUser WHERE userID = 1;


-- =============================================
-- SECTION 2: MOOD TRACKING OPERATIONS
-- =============================================

-- SCENARIO 4: User logs their daily mood
-- User submits: userID, date, moodLevel
-- Result: New mood entry created
-- Operation: INSERT into weak entity
INSERT INTO MoodLog VALUES (1, TO_DATE('2024-01-19', 'YYYY-MM-DD'), 'Happy');

-- Verification
SELECT * FROM MoodLog WHERE userID = 1 ORDER BY logDate DESC;


-- SCENARIO 5: View user's mood history for last 7 days
-- User submits: userID
-- Result: List of mood entries for past week
-- Operation: SELECT with date filtering
SELECT logDate, moodLevel 
FROM MoodLog 
WHERE userID = 1 
  AND logDate >= TO_DATE('2024-01-12', 'YYYY-MM-DD')
ORDER BY logDate DESC;


-- SCENARIO 6: Get mood statistics for a user (COMPLEX QUERY with AGGREGATES)
-- User submits: userID
-- Result: Count of each mood type, most common mood
-- Operation: SELECT with GROUP BY and aggregate functions
SELECT moodLevel, COUNT(*) as frequency
FROM MoodLog
WHERE userID = 1
GROUP BY moodLevel
ORDER BY frequency DESC;


-- SCENARIO 7: Find users with similar mood patterns (COMPLEX NESTED QUERY)
-- User submits: userID, target moodLevel
-- Result: Other users who logged the same mood on same dates
-- Operation: Nested SELECT with correlation
SELECT DISTINCT m2.userID, u.userName
FROM MoodLog m1
JOIN MoodLog m2 ON m1.logDate = m2.logDate AND m1.moodLevel = m2.moodLevel
JOIN AppUser u ON m2.userID = u.userID
WHERE m1.userID = 1 AND m2.userID != 1;


-- =============================================
-- SECTION 3: SUPPORT GROUP OPERATIONS
-- =============================================

-- SCENARIO 8: User joins a support group
-- User submits: userID, groupID
-- Result: User enrolled in support group
-- Operation: INSERT into many-to-many relationship
INSERT INTO UserGroup VALUES (6, 101);

-- Verification
SELECT * FROM UserGroup WHERE userID = 6;


-- SCENARIO 9: View all support groups a user belongs to
-- User submits: userID
-- Result: List of groups with details
-- Operation: SELECT with JOIN
SELECT sg.groupID, sg.groupName, sg.focusArea
FROM SupportGroup sg
JOIN UserGroup ug ON sg.groupID = ug.groupID
WHERE ug.userID = 1;


-- SCENARIO 10: Find all members of a specific support group
-- User submits: groupID
-- Result: List of all users in that group
-- Operation: SELECT with JOIN
SELECT u.userID, u.userName, u.email
FROM AppUser u
JOIN UserGroup ug ON u.userID = ug.userID
WHERE ug.groupID = 101;


-- SCENARIO 11: Find support groups by focus area (search functionality)
-- User submits: focusArea keyword
-- Result: Matching support groups
-- Operation: SELECT with LIKE for partial matching
SELECT groupID, groupName, focusArea
FROM SupportGroup
WHERE UPPER(focusArea) LIKE UPPER('%Anxiety%');


-- SCENARIO 12: Get support group participation statistics (COMPLEX AGGREGATE)
-- User submits: groupID
-- Result: Number of members, average session rating
-- Operation: Complex query with multiple JOINs and aggregates
SELECT 
    sg.groupID,
    sg.groupName,
    COUNT(DISTINCT ug.userID) as member_count,
    COUNT(DISTINCT cs.sessionID) as total_sessions,
    ROUND(AVG(us.rating), 2) as avg_session_rating
FROM SupportGroup sg
LEFT JOIN UserGroup ug ON sg.groupID = ug.groupID
LEFT JOIN CounselingSession cs ON sg.groupID = cs.groupID
LEFT JOIN UserSession us ON cs.sessionID = us.sessionID
WHERE sg.groupID = 101
GROUP BY sg.groupID, sg.groupName;


-- =============================================
-- SECTION 4: COUNSELING SESSION OPERATIONS
-- =============================================

-- SCENARIO 13: Counselor creates a new session
-- User submits: sessionID, date, topic, mode, counselorID, groupID
-- Result: New session scheduled
-- Operation: INSERT
INSERT INTO CounselingSession VALUES (
    207, 
    TO_DATE('2024-02-15', 'YYYY-MM-DD'), 
    'Managing Social Anxiety', 
    'Online', 
    NULL,  -- Progress note added later
    10, 
    101
);

-- Verification
SELECT * FROM CounselingSession WHERE sessionID = 207;


-- SCENARIO 14: User registers for a counseling session
-- User submits: userID, sessionID
-- Result: User enrolled in session (rating added after attendance)
-- Operation: INSERT into many-to-many relationship
INSERT INTO UserSession VALUES (6, 201, NULL);  -- Rating NULL initially


-- SCENARIO 15: View all upcoming sessions for a support group
-- User submits: groupID
-- Result: List of future sessions with counselor info
-- Operation: SELECT with JOIN
SELECT 
    cs.sessionID,
    cs.sessionDate,
    cs.topic,
    cs.sessionMode,
    u.userName as counselor_name,
    c.specialization
FROM CounselingSession cs
JOIN Counselor c ON cs.counselorID = c.userID
JOIN AppUser u ON c.userID = u.userID
WHERE cs.groupID = 101
ORDER BY cs.sessionDate;


-- SCENARIO 16: User rates a session after attending
-- User submits: userID, sessionID, rating
-- Result: Rating recorded
-- Operation: UPDATE
UPDATE UserSession 
SET rating = 5 
WHERE userID = 6 AND sessionID = 201;

-- Verification
SELECT * FROM UserSession WHERE userID = 6 AND sessionID = 201;


-- SCENARIO 17: Counselor adds progress notes after session
-- User submits: sessionID, progressNote
-- Result: Progress note added
-- Operation: UPDATE
UPDATE CounselingSession 
SET progressNote = 'Participants showed great engagement and openness'
WHERE sessionID = 207;


-- SCENARIO 18: View user's session attendance history (COMPLEX JOIN)
-- User submits: userID
-- Result: All sessions attended with ratings and details
-- Operation: Multi-table JOIN
SELECT 
    cs.sessionID,
    cs.sessionDate,
    cs.topic,
    cs.sessionMode,
    sg.groupName,
    u.userName as counselor_name,
    us.rating
FROM UserSession us
JOIN CounselingSession cs ON us.sessionID = cs.sessionID
JOIN SupportGroup sg ON cs.groupID = sg.groupID
JOIN Counselor c ON cs.counselorID = c.userID
JOIN AppUser u ON c.userID = u.userID
WHERE us.userID = 1
ORDER BY cs.sessionDate DESC;


-- =============================================
-- SECTION 5: COUNSELOR-SPECIFIC OPERATIONS
-- =============================================

-- SCENARIO 19: Register a new counselor
-- Admin submits: userID (existing AppUser), specialization, startYear
-- Result: User upgraded to counselor status
-- Operation: INSERT into Counselor subclass
-- First create the base user
INSERT INTO AppUser VALUES (13, 'Dr. James Wilson', 'james@email.com', 'hash999', 'public');
-- Then add counselor-specific info
INSERT INTO Counselor VALUES (13, 'Grief Counseling', 2021);


-- SCENARIO 20: View all sessions conducted by a counselor (AGGREGATE)
-- User submits: counselorID
-- Result: Session count and average rating
-- Operation: Complex aggregate query
SELECT 
    c.userID,
    u.userName,
    c.specialization,
    COUNT(cs.sessionID) as total_sessions,
    ROUND(AVG(us.rating), 2) as avg_rating,
    COUNT(DISTINCT cs.groupID) as groups_served
FROM Counselor c
JOIN AppUser u ON c.userID = u.userID
LEFT JOIN CounselingSession cs ON c.userID = cs.counselorID
LEFT JOIN UserSession us ON cs.sessionID = us.sessionID
WHERE c.userID = 10
GROUP BY c.userID, u.userName, c.specialization;


-- SCENARIO 21: Find best-rated counselor by specialization (COMPLEX NESTED)
-- User submits: specialization
-- Result: Top-rated counselor in that area
-- Operation: Nested query with aggregates
SELECT 
    c.userID,
    u.userName,
    c.specialization,
    ROUND(AVG(us.rating), 2) as avg_rating
FROM Counselor c
JOIN AppUser u ON c.userID = u.userID
JOIN CounselingSession cs ON c.userID = cs.counselorID
JOIN UserSession us ON cs.sessionID = us.sessionID
WHERE c.specialization = 'Anxiety and Stress'
GROUP BY c.userID, u.userName, c.specialization
HAVING AVG(us.rating) >= ALL (
    SELECT AVG(us2.rating)
    FROM Counselor c2
    JOIN CounselingSession cs2 ON c2.userID = cs2.counselorID
    JOIN UserSession us2 ON cs2.sessionID = us2.sessionID
    WHERE c2.specialization = 'Anxiety and Stress'
    GROUP BY c2.userID
);


-- =============================================
-- SECTION 6: PEER MATCHING OPERATIONS
-- =============================================

-- SCENARIO 22: Create a compatibility match between users
-- System submits: user1ID, user2ID, compatibilityScore
-- Result: New match created
-- Operation: INSERT (maintain user1ID < user2ID convention)
INSERT INTO UserMatch VALUES (1, 5, 87.5);


-- SCENARIO 23: Find best matches for a user (COMPLEX QUERY)
-- User submits: userID
-- Result: Top compatible users sorted by score
-- Operation: SELECT with UNION to handle both directions of matching
SELECT 
    CASE 
        WHEN um.user1ID = 1 THEN um.user2ID
        ELSE um.user1ID
    END as matched_userID,
    u.userName,
    u.email,
    um.compatibilityScore
FROM UserMatch um
JOIN AppUser u ON (
    CASE 
        WHEN um.user1ID = 1 THEN um.user2ID
        ELSE um.user1ID
    END = u.userID
)
WHERE 1 IN (um.user1ID, um.user2ID)
ORDER BY um.compatibilityScore DESC;


-- SCENARIO 24: Find users with shared group interests for matching
-- User submits: userID
-- Result: Users in same groups (potential matches)
-- Operation: Self-join on UserGroup
SELECT DISTINCT 
    u.userID,
    u.userName,
    COUNT(ug2.groupID) as shared_groups
FROM AppUser u
JOIN UserGroup ug2 ON u.userID = ug2.userID
WHERE ug2.groupID IN (
    SELECT groupID 
    FROM UserGroup 
    WHERE userID = 1
)
AND u.userID != 1
GROUP BY u.userID, u.userName
ORDER BY shared_groups DESC;


-- =============================================
-- SECTION 7: LEARNING RESOURCE OPERATIONS
-- =============================================

-- SCENARIO 25: Add a new learning resource
-- Admin submits: resourceID, title, resourceType
-- Result: New resource available
-- Operation: INSERT
INSERT INTO LearningResource VALUES (309, 'Mindful Eating Guide', 'PDF');


-- SCENARIO 26: Link resource to support group
-- Admin submits: groupID, resourceID
-- Result: Resource available to group members
-- Operation: INSERT into many-to-many relationship
INSERT INTO GroupResource VALUES (101, 309);


-- SCENARIO 27: View all resources for user's support groups
-- User submits: userID
-- Result: All resources from groups they belong to
-- Operation: Complex JOIN through multiple tables
SELECT DISTINCT
    lr.resourceID,
    lr.title,
    lr.resourceType,
    sg.groupName
FROM LearningResource lr
JOIN GroupResource gr ON lr.resourceID = gr.resourceID
JOIN SupportGroup sg ON gr.groupID = sg.groupID
JOIN UserGroup ug ON sg.groupID = ug.groupID
WHERE ug.userID = 1
ORDER BY sg.groupName, lr.title;


-- SCENARIO 28: Find most utilized resources (by group count)
-- Admin queries: resource usage statistics
-- Result: Resources ranked by number of groups using them
-- Operation: Aggregate with GROUP BY
SELECT 
    lr.resourceID,
    lr.title,
    lr.resourceType,
    COUNT(gr.groupID) as group_count
FROM LearningResource lr
LEFT JOIN GroupResource gr ON lr.resourceID = gr.resourceID
GROUP BY lr.resourceID, lr.title, lr.resourceType
ORDER BY group_count DESC;


-- =============================================
-- SECTION 8: COMPREHENSIVE DASHBOARD QUERIES
-- =============================================

-- SCENARIO 29: User's complete mental health dashboard (VERY COMPLEX)
-- User submits: userID
-- Result: Comprehensive overview of user's activity
-- Operation: Multiple subqueries and aggregates
SELECT 
    u.userName,
    u.email,
    (SELECT COUNT(*) FROM MoodLog WHERE userID = 1) as total_mood_logs,
    (SELECT moodLevel FROM MoodLog WHERE userID = 1 ORDER BY logDate DESC FETCH FIRST 1 ROW ONLY) as latest_mood,
    (SELECT COUNT(*) FROM UserGroup WHERE userID = 1) as groups_joined,
    (SELECT COUNT(*) FROM UserSession WHERE userID = 1) as sessions_attended,
    (SELECT ROUND(AVG(rating), 2) FROM UserSession WHERE userID = 1 AND rating IS NOT NULL) as avg_session_rating,
    (SELECT COUNT(*) FROM UserMatch WHERE 1 IN (user1ID, user2ID)) as total_matches
FROM AppUser u
WHERE u.userID = 1;


-- SCENARIO 30: Admin analytics - Platform usage statistics (COMPLEX)
-- Admin queries: Overall platform health metrics
-- Result: Key performance indicators
-- Operation: Multiple aggregates and subqueries
SELECT 
    (SELECT COUNT(*) FROM AppUser) as total_users,
    (SELECT COUNT(*) FROM Counselor) as total_counselors,
    (SELECT COUNT(*) FROM SupportGroup) as total_groups,
    (SELECT COUNT(*) FROM CounselingSession) as total_sessions,
    (SELECT ROUND(AVG(rating), 2) FROM UserSession WHERE rating IS NOT NULL) as platform_avg_rating,
    (SELECT COUNT(*) FROM MoodLog) as total_mood_logs,
    (SELECT COUNT(*) FROM UserMatch) as total_matches,
    (SELECT COUNT(*) FROM LearningResource) as total_resources
FROM DUAL;


-- SCENARIO 31: Find users who may need intervention (mental health check)
-- Counselor submits: mood pattern criteria
-- Result: Users with concerning mood patterns
-- Operation: Complex nested query with aggregates
SELECT 
    u.userID,
    u.userName,
    u.email,
    COUNT(CASE WHEN ml.moodLevel IN ('Anxious', 'Stressed', 'Sad') THEN 1 END) as negative_mood_count,
    COUNT(*) as total_logs,
    ROUND(COUNT(CASE WHEN ml.moodLevel IN ('Anxious', 'Stressed', 'Sad') THEN 1 END) * 100.0 / COUNT(*), 2) as negative_percentage
FROM AppUser u
JOIN MoodLog ml ON u.userID = ml.userID
WHERE ml.logDate >= TO_DATE('2024-01-15', 'YYYY-MM-DD')
GROUP BY u.userID, u.userName, u.email
HAVING COUNT(CASE WHEN ml.moodLevel IN ('Anxious', 'Stressed', 'Sad') THEN 1 END) > 2
ORDER BY negative_percentage DESC;


-- =============================================
-- SECTION 9: DELETE OPERATIONS
-- =============================================

-- SCENARIO 32: User wants to delete their account
-- User submits: userID
-- Result: User and all related data removed (CASCADE)
-- Operation: DELETE with cascade effect
-- DELETE FROM AppUser WHERE userID = 6;
-- (Commented out - destructive operation)


-- SCENARIO 33: Remove a user from a support group
-- User submits: userID, groupID
-- Result: User removed from group
-- Operation: DELETE from relationship table
DELETE FROM UserGroup WHERE userID = 6 AND groupID = 101;


-- SCENARIO 34: Cancel a scheduled session
-- Counselor submits: sessionID
-- Result: Session and all registrations removed
-- Operation: DELETE with cascade
-- DELETE FROM CounselingSession WHERE sessionID = 207;
-- (Commented out - would cascade to UserSession)


-- =============================================
-- SECTION 10: ADVANCED ANALYTICAL QUERIES
-- =============================================

-- SCENARIO 35: Group activity comparison (for recommendations)
-- User queries: Which groups are most active?
-- Result: Groups ranked by activity level
-- Operation: Complex multi-metric analysis
SELECT 
    sg.groupID,
    sg.groupName,
    sg.focusArea,
    COUNT(DISTINCT ug.userID) as member_count,
    COUNT(DISTINCT cs.sessionID) as session_count,
    COUNT(DISTINCT gr.resourceID) as resource_count,
    ROUND(AVG(us.rating), 2) as avg_rating,
    (COUNT(DISTINCT ug.userID) + COUNT(DISTINCT cs.sessionID) * 2 + COUNT(DISTINCT gr.resourceID)) as activity_score
FROM SupportGroup sg
LEFT JOIN UserGroup ug ON sg.groupID = ug.groupID
LEFT JOIN CounselingSession cs ON sg.groupID = cs.groupID
LEFT JOIN UserSession us ON cs.sessionID = us.sessionID
LEFT JOIN GroupResource gr ON sg.groupID = gr.groupID
GROUP BY sg.groupID, sg.groupName, sg.focusArea
ORDER BY activity_score DESC;


-- SCENARIO 36: Counselor workload analysis
-- Admin queries: Counselor session distribution
-- Result: Identify overloaded or underutilized counselors
-- Operation: Aggregate with having clause
SELECT 
    c.userID,
    u.userName,
    c.specialization,
    c.startYear,
    COUNT(cs.sessionID) as sessions_conducted,
    COUNT(DISTINCT cs.groupID) as groups_served,
    ROUND(AVG(us.rating), 2) as avg_rating
FROM Counselor c
JOIN AppUser u ON c.userID = u.userID
LEFT JOIN CounselingSession cs ON c.userID = cs.counselorID
LEFT JOIN UserSession us ON cs.sessionID = us.sessionID
GROUP BY c.userID, u.userName, c.specialization, c.startYear
ORDER BY sessions_conducted DESC;


-- SCENARIO 37: User engagement score (gamification feature)
-- User submits: userID
-- Result: Engagement metrics and score
-- Operation: Multi-faceted calculation
SELECT 
    u.userID,
    u.userName,
    (SELECT COUNT(*) FROM MoodLog WHERE userID = u.userID) * 10 as mood_points,
    (SELECT COUNT(*) FROM UserSession WHERE userID = u.userID) * 20 as session_points,
    (SELECT COUNT(*) FROM UserGroup WHERE userID = u.userID) * 15 as group_points,
    (SELECT COALESCE(SUM(rating), 0) FROM UserSession WHERE userID = u.userID) * 5 as rating_points,
    (
        (SELECT COUNT(*) FROM MoodLog WHERE userID = u.userID) * 10 +
        (SELECT COUNT(*) FROM UserSession WHERE userID = u.userID) * 20 +
        (SELECT COUNT(*) FROM UserGroup WHERE userID = u.userID) * 15 +
        (SELECT COALESCE(SUM(rating), 0) FROM UserSession WHERE userID = u.userID) * 5
    ) as total_engagement_score
FROM AppUser u
WHERE u.userID = 1;


-- =============================================
-- END OF PHASE III OPERATIONS
-- =============================================

COMMIT;