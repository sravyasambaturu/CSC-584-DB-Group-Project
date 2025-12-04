"""
MindConnect+ Database Connection Test
This script tests your Oracle database connection before running the full app
"""

import oracledb
import config

# =============================================
# CONFIGURATION - UPDATE THESE VALUES
# =============================================
USERNAME =config.ORACLE_USER      # Replace with your Oracle username
PASSWORD =config.ORACLE_PASSWORD      # Replace with your Oracle password
DSN =config.ORACLE_DSN  # Your professor's Oracle server

print("=" * 60)
print("MindConnect+ Database Connection Test")
print("=" * 60)

# Test 1: Connection
print("\n[Test 1] Testing database connection...")
try:
    connection = oracledb.connect(
        user=USERNAME,
        password=PASSWORD,
        dsn=DSN
    )
    print("✅ SUCCESS: Connected to Oracle Database!")
    print(f"   Database version: {connection.version}")
except Exception as e:
    print(f"❌ FAILED: Could not connect to database")
    print(f"   Error: {e}")
    print("\n⚠️  Please check:")
    print("   1. Your username and password are correct")
    print("   2. You are connected to university network/VPN")
    print("   3. The Oracle server is accessible")
    exit(1)

# Test 2: Check if tables exist
print("\n[Test 2] Checking if MindConnect+ tables exist...")
cursor = connection.cursor()

tables_to_check = [
    'APPUSER',
    'COUNSELOR', 
    'MOODLOG',
    'SUPPORTGROUP',
    'COUNSELINGSESSION',
    'LEARNINGRESOURCE',
    'USERMATCH',
    'USERGROUP',
    'USERSESSION',
    'GROUPRESOURCE'
]

missing_tables = []

for table in tables_to_check:
    try:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        print(f"   ✅ {table}: {count} rows")
    except Exception as e:
        print(f"   ❌ {table}: NOT FOUND")
        missing_tables.append(table)

if missing_tables:
    print(f"\n⚠️  WARNING: {len(missing_tables)} tables are missing:")
    for table in missing_tables:
        print(f"   - {table}")
    print("\n   You need to run your database creation script first!")
else:
    print("\n✅ All required tables exist!")

# Test 3: Sample Query
print("\n[Test 3] Testing sample query...")
try:
    cursor.execute("SELECT userName, email FROM AppUser WHERE ROWNUM <= 3")
    users = cursor.fetchall()
    
    if users:
        print("   ✅ Sample users found:")
        for user in users:
            print(f"      - {user[0]} ({user[1]})")
    else:
        print("   ⚠️  No users found in database")
        print("      You may need to run your INSERT statements")
except Exception as e:
    print(f"   ❌ Query failed: {e}")

# Test 4: Check complex query (with JOIN)
print("\n[Test 4] Testing complex query with JOIN...")
try:
    cursor.execute("""
        SELECT 
            u.userName,
            sg.groupName
        FROM AppUser u
        JOIN UserGroup ug ON u.userID = ug.userID
        JOIN SupportGroup sg ON ug.groupID = sg.groupID
        WHERE ROWNUM <= 3
    """)
    results = cursor.fetchall()
    
    if results:
        print("   ✅ JOIN query successful:")
        for result in results:
            print(f"      - {result[0]} is in {result[1]}")
    else:
        print("   ⚠️  No group memberships found")
except Exception as e:
    print(f"   ❌ JOIN query failed: {e}")

# Cleanup
cursor.close()
connection.close()

# Final Summary
print("\n" + "=" * 60)
print("CONNECTION TEST COMPLETE")
print("=" * 60)

if not missing_tables:
    print("✅ All tests passed! You're ready to run the Streamlit app.")
    print("\nNext step: Run this command:")
    print("   streamlit run app.py")
else:
    print("⚠️  Some issues found. Please fix them before running the app.")
    print("\nSteps to fix:")
    print("1. Connect to Oracle using SQL Developer or SQL*Plus")
    print("2. Run your database creation script (CREATE TABLE statements)")
    print("3. Run your data insertion script (INSERT statements)")
    print("4. Run this test again")

print("=" * 60)

#---------------------------------------



cursor = connection.cursor()

# Check if data exists
cursor.execute("SELECT COUNT(*) FROM AppUser")
count = cursor.fetchone()[0]
print(f"Users in database: {count}")

cursor.execute("SELECT userName FROM AppUser WHERE ROWNUM <= 3")
for row in cursor:
    print(f"  - {row[0]}")

cursor.close()
connection.close()