"""
Run the INSERT statements from your original GroupProject SQL script
This uses the exact data from your PDF document
"""

import oracledb

# =============================================
# CONFIGURATION - UPDATE THESE VALUES
# =============================================
USERNAME = ""
PASSWORD = ""
DSN = ""

print("=" * 60)
print("Running Your Original INSERT Statements")
print("=" * 60)

# Connect to database
print("\nConnecting to database...")
try:
    connection = oracledb.connect(user=USERNAME, password=PASSWORD, dsn=DSN)
    print("✅ Connected!")
    cursor = connection.cursor()
except Exception as e:
    print(f"❌ Failed: {e}")
    exit(1)

# Your original INSERT statements from the PDF
sql_statements = """
-- APPUSER DATA
INSERT INTO AppUser VALUES (1, 'Alice Johnson', 'alice@email.com', 'hash123', 'public');
INSERT INTO AppUser VALUES (2, 'Bob Smith', 'bob@email.com', 'hash456', 'private');
INSERT INTO AppUser VALUES (3, 'Carol Davis', 'carol@email.com', 'hash789', 'public');
INSERT INTO AppUser VALUES (4, 'Dave Wilson', 'dave@email.com', 'hash012', 'friends');
INSERT INTO AppUser VALUES (5, 'Eve Martinez', 'eve@email.com', 'hash345', 'public');
INSERT INTO AppUser VALUES (10, 'Dr. Sarah Chen', 'sarah@email.com', 'hash678', 'public');
INSERT INTO AppUser VALUES (11, 'Dr. Michael Brown', 'michael@email.com', 'hash901', 'public');
INSERT INTO AppUser VALUES (12, 'Dr. Emily Taylor', 'emily@email.com', 'hash234', 'public');

-- COUNSELOR DATA
INSERT INTO Counselor VALUES (10, 'Anxiety and Stress', 2018);
INSERT INTO Counselor VALUES (11, 'Depression', 2015);
INSERT INTO Counselor VALUES (12, 'Trauma and PTSD', 2020);

-- MOODLOG DATA
INSERT INTO MoodLog VALUES (1, TO_DATE('2024-01-15', 'YYYY-MM-DD'), 'Happy');
INSERT INTO MoodLog VALUES (1, TO_DATE('2024-01-16', 'YYYY-MM-DD'), 'Anxious');
INSERT INTO MoodLog VALUES (1, TO_DATE('2024-01-17', 'YYYY-MM-DD'), 'Calm');
INSERT INTO MoodLog VALUES (1, TO_DATE('2024-01-18', 'YYYY-MM-DD'), 'Stressed');
INSERT INTO MoodLog VALUES (2, TO_DATE('2024-01-15', 'YYYY-MM-DD'), 'Sad');
INSERT INTO MoodLog VALUES (2, TO_DATE('2024-01-16', 'YYYY-MM-DD'), 'Neutral');
INSERT INTO MoodLog VALUES (2, TO_DATE('2024-01-17', 'YYYY-MM-DD'), 'Happy');
INSERT INTO MoodLog VALUES (3, TO_DATE('2024-01-15', 'YYYY-MM-DD'), 'Anxious');
INSERT INTO MoodLog VALUES (3, TO_DATE('2024-01-16', 'YYYY-MM-DD'), 'Stressed');
INSERT INTO MoodLog VALUES (3, TO_DATE('2024-01-17', 'YYYY-MM-DD'), 'Calm');
INSERT INTO MoodLog VALUES (4, TO_DATE('2024-01-15', 'YYYY-MM-DD'), 'Happy');
INSERT INTO MoodLog VALUES (4, TO_DATE('2024-01-16', 'YYYY-MM-DD'), 'Calm');
INSERT INTO MoodLog VALUES (5, TO_DATE('2024-01-15', 'YYYY-MM-DD'), 'Neutral');
INSERT INTO MoodLog VALUES (5, TO_DATE('2024-01-16', 'YYYY-MM-DD'), 'Happy');
INSERT INTO MoodLog VALUES (5, TO_DATE('2024-01-17', 'YYYY-MM-DD'), 'Anxious');

-- SUPPORT GROUP DATA
INSERT INTO SupportGroup VALUES (101, 'Anxiety Support Circle', 'Anxiety');
INSERT INTO SupportGroup VALUES (102, 'Depression Recovery', 'Depression');
INSERT INTO SupportGroup VALUES (103, 'Stress Management', 'Stress');
INSERT INTO SupportGroup VALUES (104, 'Young Adults Mental Health', 'General');
INSERT INTO SupportGroup VALUES (105, 'PTSD Survivors', 'Trauma');

-- COUNSELING SESSION DATA
INSERT INTO CounselingSession VALUES (201, TO_DATE('2024-02-01', 'YYYY-MM-DD'), 'Managing Anxiety', 'Online', 'Great progress shown', 10, 101);
INSERT INTO CounselingSession VALUES (202, TO_DATE('2024-02-03', 'YYYY-MM-DD'), 'Coping with Depression', 'In-Person', 'Needs more support', 11, 102);
INSERT INTO CounselingSession VALUES (203, TO_DATE('2024-02-05', 'YYYY-MM-DD'), 'Stress Relief Techniques', 'Online', 'Excellent participation', 10, 103);
INSERT INTO CounselingSession VALUES (204, TO_DATE('2024-02-07', 'YYYY-MM-DD'), 'Building Resilience', 'Online', 'Making steady progress', 12, 104);
INSERT INTO CounselingSession VALUES (205, TO_DATE('2024-02-10', 'YYYY-MM-DD'), 'Trauma Processing', 'In-Person', 'Showing improvement', 12, 105);
INSERT INTO CounselingSession VALUES (206, TO_DATE('2024-02-12', 'YYYY-MM-DD'), 'Mindfulness Practice', 'Online', 'Very engaged', 10, 101);

-- LEARNING RESOURCE DATA
INSERT INTO LearningResource VALUES (301, 'Breathing Exercises Guide', 'Article');
INSERT INTO LearningResource VALUES (302, 'Meditation for Beginners', 'Video');
INSERT INTO LearningResource VALUES (303, 'Understanding Depression', 'PDF');
INSERT INTO LearningResource VALUES (304, 'Anxiety Management Workbook', 'PDF');
INSERT INTO LearningResource VALUES (305, 'Sleep Hygiene Tips', 'Article');
INSERT INTO LearningResource VALUES (306, 'Cognitive Behavioral Therapy Basics', 'Video');
INSERT INTO LearningResource VALUES (307, 'Crisis Helpline Numbers', 'Article');
INSERT INTO LearningResource VALUES (308, 'Journaling for Mental Health', 'PDF');

-- USER MATCH DATA
INSERT INTO UserMatch VALUES (1, 2, 85.5);
INSERT INTO UserMatch VALUES (1, 3, 72.0);
INSERT INTO UserMatch VALUES (1, 4, 90.0);
INSERT INTO UserMatch VALUES (2, 3, 65.0);
INSERT INTO UserMatch VALUES (2, 5, 88.0);
INSERT INTO UserMatch VALUES (3, 4, 78.5);
INSERT INTO UserMatch VALUES (4, 5, 82.0);

-- USER GROUP DATA
INSERT INTO UserGroup VALUES (1, 101);
INSERT INTO UserGroup VALUES (1, 103);
INSERT INTO UserGroup VALUES (2, 102);
INSERT INTO UserGroup VALUES (2, 104);
INSERT INTO UserGroup VALUES (3, 101);
INSERT INTO UserGroup VALUES (3, 103);
INSERT INTO UserGroup VALUES (4, 104);
INSERT INTO UserGroup VALUES (5, 101);
INSERT INTO UserGroup VALUES (5, 104);

-- USER SESSION DATA
INSERT INTO UserSession VALUES (1, 201, 5);
INSERT INTO UserSession VALUES (1, 203, 4);
INSERT INTO UserSession VALUES (1, 206, 5);
INSERT INTO UserSession VALUES (2, 202, 4);
INSERT INTO UserSession VALUES (2, 204, 3);
INSERT INTO UserSession VALUES (3, 201, 5);
INSERT INTO UserSession VALUES (3, 203, 4);
INSERT INTO UserSession VALUES (4, 204, 5);
INSERT INTO UserSession VALUES (5, 201, 4);
INSERT INTO UserSession VALUES (5, 204, 5);
INSERT INTO UserSession VALUES (5, 206, 5);

-- GROUP RESOURCE DATA
INSERT INTO GroupResource VALUES (101, 301);
INSERT INTO GroupResource VALUES (101, 302);
INSERT INTO GroupResource VALUES (101, 304);
INSERT INTO GroupResource VALUES (102, 303);
INSERT INTO GroupResource VALUES (102, 306);
INSERT INTO GroupResource VALUES (102, 308);
INSERT INTO GroupResource VALUES (103, 301);
INSERT INTO GroupResource VALUES (103, 305);
INSERT INTO GroupResource VALUES (104, 302);
INSERT INTO GroupResource VALUES (104, 307);
INSERT INTO GroupResource VALUES (105, 306);
INSERT INTO GroupResource VALUES (105, 308);
"""

# Execute each statement
print("\nExecuting INSERT statements...")
statements = [s.strip() for s in sql_statements.split(';') if s.strip() and s.strip().startswith('INSERT')]

success_count = 0
error_count = 0

for i, stmt in enumerate(statements, 1):
    try:
        cursor.execute(stmt)
        success_count += 1
        if i % 10 == 0:
            print(f"   Processed {i}/{len(statements)} statements...")
    except Exception as e:
        error_count += 1
        if "unique constraint" not in str(e).lower():
            print(f"   ⚠️  Statement {i}: {str(e)[:50]}...")

print(f"\n✅ Successfully executed: {success_count} statements")
if error_count > 0:
    print(f"⚠️  Warnings/Duplicates: {error_count} statements")

# Commit
print("\nCommitting changes...")
try:
    connection.commit()
    print("✅ All changes committed!")
except Exception as e:
    print(f"❌ Commit failed: {e}")
    connection.rollback()

# Verify
print("\n" + "=" * 60)
print("Verification - Row Counts:")
print("=" * 60)

tables = [
    'AppUser', 'Counselor', 'MoodLog', 'SupportGroup',
    'CounselingSession', 'LearningResource', 'UserMatch',
    'UserGroup', 'UserSession', 'GroupResource'
]

for table in tables:
    try:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        print(f"{table:20} : {count:3} rows")
    except Exception as e:
        print(f"{table:20} : ERROR")

cursor.close()
connection.close()

print("\n" + "=" * 60)
print("✅ COMPLETE! Your database is now populated.")
print("=" * 60)
print("\nNext: Run your Streamlit app")
print("   streamlit run app.py")
print("=" * 60)