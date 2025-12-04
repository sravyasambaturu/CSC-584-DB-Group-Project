-- =============================================
-- MindConnect+ Database Schema
-- =============================================

-- Drop tables in reverse order (to handle foreign key dependencies)
DROP TABLE GroupResource CASCADE CONSTRAINTS;
DROP TABLE UserSession CASCADE CONSTRAINTS;
DROP TABLE UserGroup CASCADE CONSTRAINTS;
DROP TABLE UserMatch CASCADE CONSTRAINTS;
DROP TABLE MoodLog CASCADE CONSTRAINTS;
DROP TABLE Counselor CASCADE CONSTRAINTS;
DROP TABLE CounselingSession CASCADE CONSTRAINTS;
DROP TABLE LearningResource CASCADE CONSTRAINTS;
DROP TABLE SupportGroup CASCADE CONSTRAINTS;
DROP TABLE AppUser CASCADE CONSTRAINTS;

-- =============================================
-- ENTITY TABLES
-- =============================================

-- USER Entity (renamed to AppUser since USER is Oracle reserved word)
CREATE TABLE AppUser (
    userID NUMBER(10) PRIMARY KEY,
    userName VARCHAR2(50),
    email VARCHAR2(100) UNIQUE,
    userPassword VARCHAR2(100),
    privacySetting VARCHAR2(20)
);

-- COUNSELOR Entity (Subclass of AppUser via ISA)
-- Note: Counselor inherits userName from AppUser table through userID
CREATE TABLE Counselor (
    userID NUMBER(10) PRIMARY KEY,
    specialization VARCHAR2(50),
    startYear NUMBER(4),
    CONSTRAINT fk_counselor_user FOREIGN KEY (userID) 
        REFERENCES AppUser(userID) ON DELETE CASCADE
);

-- MOODLOG Entity (Weak Entity - depends on AppUser)
CREATE TABLE MoodLog (
    userID NUMBER(10),
    logDate DATE,
    moodLevel VARCHAR2(20),
    CONSTRAINT pk_moodlog PRIMARY KEY (userID, logDate),
    CONSTRAINT fk_moodlog_user FOREIGN KEY (userID) 
        REFERENCES AppUser(userID) ON DELETE CASCADE
);

-- SUPPORT GROUP Entity
CREATE TABLE SupportGroup (
    groupID NUMBER(10) PRIMARY KEY,
    groupName VARCHAR2(50),
    focusArea VARCHAR2(50)
);

-- SESSION Entity 
CREATE TABLE CounselingSession (
    sessionID NUMBER(10) PRIMARY KEY,
    sessionDate DATE,
    topic VARCHAR2(100),
    sessionMode VARCHAR2(20),
    progressNote VARCHAR2(500),
    counselorID NUMBER(10) NOT NULL,
    groupID NUMBER(10) NOT NULL,
    CONSTRAINT fk_session_counselor FOREIGN KEY (counselorID) 
        REFERENCES Counselor(userID) ON DELETE CASCADE,
    CONSTRAINT fk_session_group FOREIGN KEY (groupID) 
        REFERENCES SupportGroup(groupID) ON DELETE CASCADE
);

-- RESOURCE Entity 
CREATE TABLE LearningResource (
    resourceID NUMBER(10) PRIMARY KEY,
    title VARCHAR2(100),
    resourceType VARCHAR2(30)
);

-- =============================================
-- RELATIONSHIP TABLES
-- =============================================

-- AppUser Matches With AppUser (Many-to-Many Self-Relationship)
CREATE TABLE UserMatch (
    user1ID NUMBER(10),
    user2ID NUMBER(10),
    compatibilityScore NUMBER(5,2),
    CONSTRAINT pk_usermatch PRIMARY KEY (user1ID, user2ID),
    CONSTRAINT fk_match_user1 FOREIGN KEY (user1ID) 
        REFERENCES AppUser(userID) ON DELETE CASCADE,
    CONSTRAINT fk_match_user2 FOREIGN KEY (user2ID) 
        REFERENCES AppUser(userID) ON DELETE CASCADE
);

-- AppUser Joins SUPPORT GROUP (Many-to-Many)
CREATE TABLE UserGroup (
    userID NUMBER(10),
    groupID NUMBER(10),
    CONSTRAINT pk_usergroup PRIMARY KEY (userID, groupID),
    CONSTRAINT fk_usergroup_user FOREIGN KEY (userID) 
        REFERENCES AppUser(userID) ON DELETE CASCADE,
    CONSTRAINT fk_usergroup_group FOREIGN KEY (groupID) 
        REFERENCES SupportGroup(groupID) ON DELETE CASCADE
);

-- AppUser Attends SESSION (Many-to-Many with Rating attribute)
CREATE TABLE UserSession (
    userID NUMBER(10),
    sessionID NUMBER(10),
    rating NUMBER(1),
    CONSTRAINT pk_usersession PRIMARY KEY (userID, sessionID),
    CONSTRAINT fk_usersession_user FOREIGN KEY (userID) 
        REFERENCES AppUser(userID) ON DELETE CASCADE,
    CONSTRAINT fk_usersession_session FOREIGN KEY (sessionID) 
        REFERENCES CounselingSession(sessionID) ON DELETE CASCADE
);

-- SUPPORT GROUP References RESOURCE (Many-to-Many)
CREATE TABLE GroupResource (
    groupID NUMBER(10),
    resourceID NUMBER(10),
    CONSTRAINT pk_groupresource PRIMARY KEY (groupID, resourceID),
    CONSTRAINT fk_groupres_group FOREIGN KEY (groupID) 
        REFERENCES SupportGroup(groupID) ON DELETE CASCADE,
    CONSTRAINT fk_groupres_resource FOREIGN KEY (resourceID) 
        REFERENCES LearningResource(resourceID) ON DELETE CASCADE
);


-- =============================================
-- MindConnect+ Sample Data
-- =============================================

-- =============================================
-- APPUSER DATA
-- =============================================

INSERT INTO AppUser VALUES (1, 'Alice Johnson', 'alice@email.com', 'hash123', 'public');
INSERT INTO AppUser VALUES (2, 'Bob Smith', 'bob@email.com', 'hash456', 'private');
INSERT INTO AppUser VALUES (3, 'Carol Davis', 'carol@email.com', 'hash789', 'public');
INSERT INTO AppUser VALUES (4, 'Dave Wilson', 'dave@email.com', 'hash012', 'friends');
INSERT INTO AppUser VALUES (5, 'Eve Martinez', 'eve@email.com', 'hash345', 'public');
INSERT INTO AppUser VALUES (10, 'Dr. Sarah Chen', 'sarah@email.com', 'hash678', 'public');
INSERT INTO AppUser VALUES (11, 'Dr. Michael Brown', 'michael@email.com', 'hash901', 'public');
INSERT INTO AppUser VALUES (12, 'Dr. Emily Taylor', 'emily@email.com', 'hash234', 'public');

-- =============================================
-- COUNSELOR DATA (Subclass of AppUser)
-- =============================================

INSERT INTO Counselor VALUES (10, 'Anxiety and Stress', 2018);
INSERT INTO Counselor VALUES (11, 'Depression', 2015);
INSERT INTO Counselor VALUES (12, 'Trauma and PTSD', 2020);

-- =============================================
-- MOODLOG DATA (Weak Entity)
-- =============================================

-- Alice's mood logs
INSERT INTO MoodLog VALUES (1, TO_DATE('2024-01-15', 'YYYY-MM-DD'), 'Happy');
INSERT INTO MoodLog VALUES (1, TO_DATE('2024-01-16', 'YYYY-MM-DD'), 'Anxious');
INSERT INTO MoodLog VALUES (1, TO_DATE('2024-01-17', 'YYYY-MM-DD'), 'Calm');
INSERT INTO MoodLog VALUES (1, TO_DATE('2024-01-18', 'YYYY-MM-DD'), 'Stressed');

-- Bob's mood logs
INSERT INTO MoodLog VALUES (2, TO_DATE('2024-01-15', 'YYYY-MM-DD'), 'Sad');
INSERT INTO MoodLog VALUES (2, TO_DATE('2024-01-16', 'YYYY-MM-DD'), 'Neutral');
INSERT INTO MoodLog VALUES (2, TO_DATE('2024-01-17', 'YYYY-MM-DD'), 'Happy');

-- Carol's mood logs
INSERT INTO MoodLog VALUES (3, TO_DATE('2024-01-15', 'YYYY-MM-DD'), 'Anxious');
INSERT INTO MoodLog VALUES (3, TO_DATE('2024-01-16', 'YYYY-MM-DD'), 'Stressed');
INSERT INTO MoodLog VALUES (3, TO_DATE('2024-01-17', 'YYYY-MM-DD'), 'Calm');

-- Dave's mood logs
INSERT INTO MoodLog VALUES (4, TO_DATE('2024-01-15', 'YYYY-MM-DD'), 'Happy');
INSERT INTO MoodLog VALUES (4, TO_DATE('2024-01-16', 'YYYY-MM-DD'), 'Calm');

-- Eve's mood logs
INSERT INTO MoodLog VALUES (5, TO_DATE('2024-01-15', 'YYYY-MM-DD'), 'Neutral');
INSERT INTO MoodLog VALUES (5, TO_DATE('2024-01-16', 'YYYY-MM-DD'), 'Happy');
INSERT INTO MoodLog VALUES (5, TO_DATE('2024-01-17', 'YYYY-MM-DD'), 'Anxious');

-- =============================================
-- SUPPORT GROUP DATA
-- =============================================

INSERT INTO SupportGroup VALUES (101, 'Anxiety Support Circle', 'Anxiety');
INSERT INTO SupportGroup VALUES (102, 'Depression Recovery', 'Depression');
INSERT INTO SupportGroup VALUES (103, 'Stress Management', 'Stress');
INSERT INTO SupportGroup VALUES (104, 'Young Adults Mental Health', 'General');
INSERT INTO SupportGroup VALUES (105, 'PTSD Survivors', 'Trauma');

-- =============================================
-- COUNSELING SESSION DATA
-- =============================================

INSERT INTO CounselingSession VALUES (201, TO_DATE('2024-02-01', 'YYYY-MM-DD'), 'Managing Anxiety', 'Online', 'Great progress shown', 10, 101);
INSERT INTO CounselingSession VALUES (202, TO_DATE('2024-02-03', 'YYYY-MM-DD'), 'Coping with Depression', 'In-Person', 'Needs more support', 11, 102);
INSERT INTO CounselingSession VALUES (203, TO_DATE('2024-02-05', 'YYYY-MM-DD'), 'Stress Relief Techniques', 'Online', 'Excellent participation', 10, 103);
INSERT INTO CounselingSession VALUES (204, TO_DATE('2024-02-07', 'YYYY-MM-DD'), 'Building Resilience', 'Online', 'Making steady progress', 12, 104);
INSERT INTO CounselingSession VALUES (205, TO_DATE('2024-02-10', 'YYYY-MM-DD'), 'Trauma Processing', 'In-Person', 'Showing improvement', 12, 105);
INSERT INTO CounselingSession VALUES (206, TO_DATE('2024-02-12', 'YYYY-MM-DD'), 'Mindfulness Practice', 'Online', 'Very engaged', 10, 101);

-- =============================================
-- LEARNING RESOURCE DATA
-- =============================================

INSERT INTO LearningResource VALUES (301, 'Breathing Exercises Guide', 'Article');
INSERT INTO LearningResource VALUES (302, 'Meditation for Beginners', 'Video');
INSERT INTO LearningResource VALUES (303, 'Understanding Depression', 'PDF');
INSERT INTO LearningResource VALUES (304, 'Anxiety Management Workbook', 'PDF');
INSERT INTO LearningResource VALUES (305, 'Sleep Hygiene Tips', 'Article');
INSERT INTO LearningResource VALUES (306, 'Cognitive Behavioral Therapy Basics', 'Video');
INSERT INTO LearningResource VALUES (307, 'Crisis Helpline Numbers', 'Article');
INSERT INTO LearningResource VALUES (308, 'Journaling for Mental Health', 'PDF');

-- =============================================
-- RELATIONSHIP DATA
-- =============================================

-- APPUSER MATCHES WITH APPUSER (Compatibility Matching)
-- Storing only one direction (user1ID < user2ID)
INSERT INTO UserMatch VALUES (1, 2, 85.5);  -- Alice matches Bob
INSERT INTO UserMatch VALUES (1, 3, 72.0);  -- Alice matches Carol
INSERT INTO UserMatch VALUES (1, 4, 90.0);  -- Alice matches Dave (best match)
INSERT INTO UserMatch VALUES (2, 3, 65.0);  -- Bob matches Carol
INSERT INTO UserMatch VALUES (2, 5, 88.0);  -- Bob matches Eve
INSERT INTO UserMatch VALUES (3, 4, 78.5);  -- Carol matches Dave
INSERT INTO UserMatch VALUES (4, 5, 82.0);  -- Dave matches Eve

-- APPUSER JOINS SUPPORT GROUP
INSERT INTO UserGroup VALUES (1, 101);  -- Alice joins Anxiety Support
INSERT INTO UserGroup VALUES (1, 103);  -- Alice joins Stress Management
INSERT INTO UserGroup VALUES (2, 102);  -- Bob joins Depression Recovery
INSERT INTO UserGroup VALUES (2, 104);  -- Bob joins Young Adults
INSERT INTO UserGroup VALUES (3, 101);  -- Carol joins Anxiety Support
INSERT INTO UserGroup VALUES (3, 103);  -- Carol joins Stress Management
INSERT INTO UserGroup VALUES (4, 104);  -- Dave joins Young Adults
INSERT INTO UserGroup VALUES (5, 101);  -- Eve joins Anxiety Support
INSERT INTO UserGroup VALUES (5, 104);  -- Eve joins Young Adults

-- APPUSER ATTENDS SESSION (with Rating)
INSERT INTO UserSession VALUES (1, 201, 5);  -- Alice attended session 201, rated 5/5
INSERT INTO UserSession VALUES (1, 203, 4);  -- Alice attended session 203, rated 4/5
INSERT INTO UserSession VALUES (1, 206, 5);  -- Alice attended session 206, rated 5/5
INSERT INTO UserSession VALUES (2, 202, 4);  -- Bob attended session 202, rated 4/5
INSERT INTO UserSession VALUES (2, 204, 3);  -- Bob attended session 204, rated 3/5
INSERT INTO UserSession VALUES (3, 201, 5);  -- Carol attended session 201, rated 5/5
INSERT INTO UserSession VALUES (3, 203, 4);  -- Carol attended session 203, rated 4/5
INSERT INTO UserSession VALUES (4, 204, 5);  -- Dave attended session 204, rated 5/5
INSERT INTO UserSession VALUES (5, 201, 4);  -- Eve attended session 201, rated 4/5
INSERT INTO UserSession VALUES (5, 204, 5);  -- Eve attended session 204, rated 5/5
INSERT INTO UserSession VALUES (5, 206, 5);  -- Eve attended session 206, rated 5/5

-- SUPPORT GROUP REFERENCES RESOURCE
INSERT INTO GroupResource VALUES (101, 301);  -- Anxiety group uses Breathing Exercises
INSERT INTO GroupResource VALUES (101, 302);  -- Anxiety group uses Meditation video
INSERT INTO GroupResource VALUES (101, 304);  -- Anxiety group uses Anxiety Workbook
INSERT INTO GroupResource VALUES (102, 303);  -- Depression group uses Understanding Depression
INSERT INTO GroupResource VALUES (102, 306);  -- Depression group uses CBT Basics
INSERT INTO GroupResource VALUES (102, 308);  -- Depression group uses Journaling PDF
INSERT INTO GroupResource VALUES (103, 301);  -- Stress group uses Breathing Exercises
INSERT INTO GroupResource VALUES (103, 305);  -- Stress group uses Sleep Hygiene
INSERT INTO GroupResource VALUES (104, 302);  -- Young Adults group uses Meditation
INSERT INTO GroupResource VALUES (104, 307);  -- Young Adults group uses Crisis Helpline
INSERT INTO GroupResource VALUES (105, 306);  -- PTSD group uses CBT Basics
INSERT INTO GroupResource VALUES (105, 308);  -- PTSD group uses Journaling

COMMIT;

-- =============================================
-- VERIFICATION QUERIES
-- =============================================

-- Uncomment to verify data insertion:

 SELECT * FROM AppUser;
 SELECT * FROM Counselor;
 SELECT * FROM MoodLog;
 SELECT * FROM SupportGroup;
 SELECT * FROM CounselingSession;
 SELECT * FROM LearningResource;
 SELECT * FROM UserMatch;
 SELECT * FROM UserGroup;
 SELECT * FROM UserSession;
 SELECT * FROM GroupResource;