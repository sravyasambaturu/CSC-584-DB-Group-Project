-- ==========================================
-- MindConnect+ Database Schema
-- ==========================================

-- Disable substitution to prevent '&' character issues
SET DEFINE OFF;

-- Drop tables in correct dependency order (reverse of creation)
DROP TABLE Feedback CASCADE CONSTRAINTS;
DROP TABLE GroupMembership CASCADE CONSTRAINTS;
DROP TABLE GroupResource CASCADE CONSTRAINTS;
DROP TABLE PeerMatch CASCADE CONSTRAINTS;
DROP TABLE MoodLog CASCADE CONSTRAINTS;
DROP TABLE CounselingSession CASCADE CONSTRAINTS;
DROP TABLE Counselor CASCADE CONSTRAINTS;
DROP TABLE SupportGroup CASCADE CONSTRAINTS;
DROP TABLE "Resource" CASCADE CONSTRAINTS;
DROP TABLE AppUser CASCADE CONSTRAINTS;

-- USER TABLE
CREATE TABLE AppUser (
    UserID NUMBER PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL,
    Email VARCHAR2(100) UNIQUE NOT NULL,
    Password VARCHAR2(255) NOT NULL,
    PrivacySetting VARCHAR2(50) DEFAULT 'Standard'
);

-- COUNSELOR TABLE (Counselor is a specialized User)
CREATE TABLE Counselor (
    CounselorID NUMBER PRIMARY KEY,
    Specialization VARCHAR2(100),
    YearsOfExperience NUMBER CHECK (YearsOfExperience >= 0),
    FOREIGN KEY (CounselorID) REFERENCES AppUser(UserID)
);

-- SUPPORT GROUP TABLE
CREATE TABLE SupportGroup (
    GroupID NUMBER PRIMARY KEY,
    GroupName VARCHAR2(100) NOT NULL,
    FocusArea VARCHAR2(100) NOT NULL
);

-- COUNSELING SESSION TABLE
-- CounselorNotes replaces ProgressNote (multi-valued attribute)
CREATE TABLE CounselingSession (
    SessionID NUMBER PRIMARY KEY,
    SessionDate DATE NOT NULL,
    SessionTime TIMESTAMP NOT NULL,
    PMode VARCHAR2(20) CHECK (PMode IN ('Online', 'In-person')),
    Topic VARCHAR2(200),
    CounselorNotes CLOB,  -- Replaces ProgressNote multi-valued attribute
    GroupID NUMBER NOT NULL,
    CounselorID NUMBER,
    FOREIGN KEY (GroupID) REFERENCES SupportGroup(GroupID),
    FOREIGN KEY (CounselorID) REFERENCES Counselor(CounselorID)
);

-- MOOD LOG TABLE
CREATE TABLE MoodLog (
    UserID NUMBER,
    LogDate DATE,
    MoodLevel VARCHAR2(50) NOT NULL,
    PRIMARY KEY (UserID, LogDate),
    FOREIGN KEY (UserID) REFERENCES AppUser(UserID)
);

-- RESOURCE TABLE
CREATE TABLE "Resource" (
    ResourceID NUMBER PRIMARY KEY,
    Title VARCHAR2(200) NOT NULL,
    Type VARCHAR2(50) NOT NULL
);

-- PEER MATCH TABLE
CREATE TABLE PeerMatch (
    User1ID NUMBER,
    User2ID NUMBER,
    CompatibilityScore NUMBER(3,2) CHECK (CompatibilityScore >= 0 AND CompatibilityScore <= 1),
    PRIMARY KEY (User1ID, User2ID),
    FOREIGN KEY (User1ID) REFERENCES AppUser(UserID),
    FOREIGN KEY (User2ID) REFERENCES AppUser(UserID),
    CHECK (User1ID < User2ID)
);

-- GROUP MEMBERSHIP TABLE
CREATE TABLE GroupMembership (
    UserID NUMBER,
    GroupID NUMBER,
    JoinDate DATE DEFAULT SYSDATE,
    PRIMARY KEY (UserID, GroupID),
    FOREIGN KEY (UserID) REFERENCES AppUser(UserID),
    FOREIGN KEY (GroupID) REFERENCES SupportGroup(GroupID)
);

-- FEEDBACK TABLE
CREATE TABLE Feedback (
    UserID NUMBER,
    SessionID NUMBER,
    Rating NUMBER CHECK (Rating >= 1 AND Rating <= 5),
    Comments CLOB,
    PRIMARY KEY (UserID, SessionID),
    FOREIGN KEY (UserID) REFERENCES AppUser(UserID),
    FOREIGN KEY (SessionID) REFERENCES CounselingSession(SessionID)
);

-- GROUP RESOURCE TABLE
CREATE TABLE GroupResource (
    GroupID NUMBER,
    ResourceID NUMBER,
    PRIMARY KEY (GroupID, ResourceID),
    FOREIGN KEY (GroupID) REFERENCES SupportGroup(GroupID),
    FOREIGN KEY (ResourceID) REFERENCES "Resource"(ResourceID)
);

-- ==========================================
-- MindConnect+ Test Data Insertion
-- ==========================================

-- USERS (including counselors)
INSERT INTO AppUser VALUES (1, 'Sofia Martinez', 'sofia.m@email.com', 'pass123', 'Anonymous');
INSERT INTO AppUser VALUES (2, 'Alex Chen', 'alex.c@email.com', 'secure456', 'Standard');
INSERT INTO AppUser VALUES (3, 'Maya Johnson', 'maya.j@email.com', 'mypass789', 'Standard');
INSERT INTO AppUser VALUES (4, 'James Wilson', 'james.w@email.com', 'pass2024', 'Anonymous');
INSERT INTO AppUser VALUES (5, 'Emma Davis', 'emma.d@email.com', 'emma567', 'Standard');

-- Counselor Users
INSERT INTO AppUser VALUES (101, 'Dr. Sarah Patel', 'sarah.patel@clinic.com', 'counselor101', 'Standard');
INSERT INTO AppUser VALUES (102, 'Dr. Michael Ross', 'michael.ross@clinic.com', 'counselor102', 'Standard');
INSERT INTO AppUser VALUES (103, 'Dr. Lisa Wong', 'lisa.wong@clinic.com', 'counselor103', 'Standard');

-- COUNSELORS (references AppUser)
INSERT INTO Counselor VALUES (101, 'Anxiety Disorders', 8);
INSERT INTO Counselor VALUES (102, 'Depression and Mood', 12);
INSERT INTO Counselor VALUES (103, 'Stress Management', 5);

-- SUPPORT GROUPS
INSERT INTO SupportGroup VALUES (201, 'Anxiety Support Group', 'Anxiety Management');
INSERT INTO SupportGroup VALUES (202, 'Depression Recovery', 'Depression Support');
INSERT INTO SupportGroup VALUES (203, 'Work-Life Balance', 'Stress and Burnout');

-- RESOURCES
INSERT INTO "Resource" VALUES (301, 'Breathing Exercises Guide', 'Article');
INSERT INTO "Resource" VALUES (302, 'Cognitive Behavioral Therapy Workbook', 'PDF');
INSERT INTO "Resource" VALUES (303, 'Meditation for Beginners', 'Video');
INSERT INTO "Resource" VALUES (304, 'Sleep Hygiene Tips', 'Article');
INSERT INTO "Resource" VALUES (305, 'Mindfulness Techniques', 'Video');

-- COUNSELING SESSIONS (with CounselorNotes column)
INSERT INTO CounselingSession VALUES (401, TO_DATE('2024-10-15', 'YYYY-MM-DD'), TO_TIMESTAMP('2024-10-15 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Online', 'Managing Daily Anxiety', 'Sofia showed improvement in identifying anxiety triggers. Recommended continued breathing exercises.', 201, 101);
INSERT INTO CounselingSession VALUES (402, TO_DATE('2024-10-20', 'YYYY-MM-DD'), TO_TIMESTAMP('2024-10-20 15:30:00', 'YYYY-MM-DD HH24:MI:SS'), 'In-person', 'Coping with Depression', 'Group discussed common depression symptoms. Maya actively participated and shared personal strategies.', 202, 102);
INSERT INTO CounselingSession VALUES (403, TO_DATE('2024-10-25', 'YYYY-MM-DD'), TO_TIMESTAMP('2024-10-25 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Online', 'Workplace Stress', 'Addressed burnout prevention techniques. James expressed concerns about work boundaries.', 203, 103);
INSERT INTO CounselingSession VALUES (404, TO_DATE('2024-11-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2024-11-01 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Online', 'Building Resilience', 'Follow-up session focused on resilience-building. Sofia demonstrated progress in anxiety management.', 201, 101);

-- MOOD LOGS
INSERT INTO MoodLog VALUES (1, TO_DATE('2024-10-10', 'YYYY-MM-DD'), 'Anxious');
INSERT INTO MoodLog VALUES (1, TO_DATE('2024-10-11', 'YYYY-MM-DD'), 'Calm');
INSERT INTO MoodLog VALUES (1, TO_DATE('2024-10-12', 'YYYY-MM-DD'), 'Stressed');
INSERT INTO MoodLog VALUES (1, TO_DATE('2024-10-15', 'YYYY-MM-DD'), 'Hopeful');
INSERT INTO MoodLog VALUES (2, TO_DATE('2024-10-10', 'YYYY-MM-DD'), 'Calm');
INSERT INTO MoodLog VALUES (2, TO_DATE('2024-10-12', 'YYYY-MM-DD'), 'Anxious');
INSERT INTO MoodLog VALUES (3, TO_DATE('2024-10-18', 'YYYY-MM-DD'), 'Sad');
INSERT INTO MoodLog VALUES (3, TO_DATE('2024-10-20', 'YYYY-MM-DD'), 'Better');
INSERT INTO MoodLog VALUES (4, TO_DATE('2024-10-24', 'YYYY-MM-DD'), 'Overwhelmed');
INSERT INTO MoodLog VALUES (5, TO_DATE('2024-10-25', 'YYYY-MM-DD'), 'Calm');

-- PEER MATCHES
INSERT INTO PeerMatch VALUES (1, 2, 0.85);
INSERT INTO PeerMatch VALUES (1, 4, 0.68);
INSERT INTO PeerMatch VALUES (3, 5, 0.72);

-- GROUP MEMBERSHIPS
INSERT INTO GroupMembership VALUES (1, 201, TO_DATE('2024-10-05', 'YYYY-MM-DD'));
INSERT INTO GroupMembership VALUES (2, 201, TO_DATE('2024-10-08', 'YYYY-MM-DD'));
INSERT INTO GroupMembership VALUES (3, 202, TO_DATE('2024-10-12', 'YYYY-MM-DD'));
INSERT INTO GroupMembership VALUES (4, 203, TO_DATE('2024-10-20', 'YYYY-MM-DD'));
INSERT INTO GroupMembership VALUES (5, 203, TO_DATE('2024-10-22', 'YYYY-MM-DD'));
INSERT INTO GroupMembership VALUES (1, 203, TO_DATE('2024-10-28', 'YYYY-MM-DD'));

-- FEEDBACK
INSERT INTO Feedback VALUES (1, 401, 5, 'Very helpful session! Dr. Patel was great.');
INSERT INTO Feedback VALUES (2, 401, 4, 'Good discussion about anxiety management.');
INSERT INTO Feedback VALUES (3, 402, 5, 'Felt understood and supported.');
INSERT INTO Feedback VALUES (4, 403, 3, 'Useful but wanted more practical tips.');
INSERT INTO Feedback VALUES (1, 404, 5, 'Excellent follow-up session.');

-- GROUP RESOURCES
INSERT INTO GroupResource VALUES (201, 301);
INSERT INTO GroupResource VALUES (201, 303);
INSERT INTO GroupResource VALUES (202, 302);
INSERT INTO GroupResource VALUES (202, 304);
INSERT INTO GroupResource VALUES (203, 304);
INSERT INTO GroupResource VALUES (203, 305);

-- Re-enable substitution
SET DEFINE ON;

-- ==========================================
-- Verify Table Data Counts
-- ==========================================

SELECT 'AppUser' AS Table_Name, COUNT(*) AS Row_Count FROM AppUser
UNION ALL
SELECT 'Counselor', COUNT(*) FROM Counselor
UNION ALL
SELECT 'SupportGroup', COUNT(*) FROM SupportGroup
UNION ALL
SELECT 'CounselingSession', COUNT(*) FROM CounselingSession
UNION ALL
SELECT 'MoodLog', COUNT(*) FROM MoodLog
UNION ALL
SELECT 'Resource', COUNT(*) FROM "Resource"
UNION ALL
SELECT 'PeerMatch', COUNT(*) FROM PeerMatch
UNION ALL
SELECT 'GroupMembership', COUNT(*) FROM GroupMembership
UNION ALL
SELECT 'Feedback', COUNT(*) FROM Feedback
UNION ALL
SELECT 'GroupResource', COUNT(*) FROM GroupResource;
