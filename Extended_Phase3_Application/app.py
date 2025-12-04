import streamlit as st
import oracledb
import pandas as pd
import streamlit_pandas as sp
from datetime import datetime, date
import config

# =============================================
# DATABASE CONNECTION CONFIGURATION
# =============================================
def get_connection():
    """Create and return Oracle DB connection"""
    try:
        connection = oracledb.connect(
            user=config.ORACLE_USER,
            password=config.ORACLE_PASSWORD,
            dsn=config.ORACLE_DSN
        )
        return connection
    except Exception as e:
        st.error(f"Database connection failed: {e}")
        return None

# =============================================
# PAGE CONFIGURATION
# =============================================
st.set_page_config(
    page_title="MindConnect+ Mental Health App",
    page_icon="🧠",
    layout="wide"
)

# =============================================
# SIDEBAR NAVIGATION
# =============================================
st.sidebar.title("🧠 MindConnect+")
st.sidebar.markdown("---")

menu = st.sidebar.radio(
    "Navigation",
    ["Home", "User Management", "Mood Tracking", "Support Groups", 
     "Counseling Sessions", "Peer Matching", "Resources", "Analytics"]
)

# =============================================
# HOME PAGE
# =============================================
if menu == "Home":
    st.title("🧠 MindConnect+ Mental Health Support Platform")
    st.markdown("### Welcome to your mental wellness companion")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.info("📊 **Track Your Mood**\nLog and monitor your daily emotional wellbeing")
    
    with col2:
        st.info("👥 **Join Support Groups**\nConnect with others who understand")
    
    with col3:
        st.info("💬 **Get Counseling**\nAccess professional support sessions")
    
    st.markdown("---")
    
    # Display platform statistics
    conn = get_connection()
    if conn:
        cursor = conn.cursor()
        
        col1, col2, col3, col4 = st.columns(4)
        
        try:
            # Total Users
            cursor.execute("SELECT COUNT(*) FROM AppUser")
            total_users = cursor.fetchone()[0]
            col1.metric("Total Users", total_users)
            
            # Total Groups
            cursor.execute("SELECT COUNT(*) FROM SupportGroup")
            total_groups = cursor.fetchone()[0]
            col2.metric("Support Groups", total_groups)
            
            # Total Sessions
            cursor.execute("SELECT COUNT(*) FROM CounselingSession")
            total_sessions = cursor.fetchone()[0]
            col3.metric("Counseling Sessions", total_sessions)
            
            # Average Rating
            cursor.execute("SELECT ROUND(AVG(rating), 2) FROM UserSession WHERE rating IS NOT NULL")
            avg_rating = cursor.fetchone()[0]
            col4.metric("Avg Session Rating", f"{avg_rating}/5" if avg_rating else "N/A")
            
        except Exception as e:
            st.error(f"Error fetching statistics: {e}")
        finally:
            cursor.close()
            conn.close()

# =============================================
# USER MANAGEMENT PAGE
# =============================================
elif menu == "User Management":
    st.title("👤 User Management")
    
    tab1, tab2, tab3 = st.tabs(["Register New User", "View Users", "Update Profile"])
    
    # TAB 1: Register New User
    with tab1:
        st.subheader("Create New Account")
        
        with st.form("register_form"):
            col1, col2 = st.columns(2)
            
            with col1:
                user_id = st.number_input("User ID", min_value=1, step=1)
                username = st.text_input("Username")
                email = st.text_input("Email")
            
            with col2:
                password = st.text_input("Password", type="password")
                privacy = st.selectbox("Privacy Setting", ["public", "private", "friends"])
            
            submitted = st.form_submit_button("Register User")
            
            if submitted:
                conn = get_connection()
                if conn:
                    cursor = conn.cursor()
                    try:
                        cursor.execute(
                            "INSERT INTO AppUser VALUES (:1, :2, :3, :4, :5)",
                            (user_id, username, email, password, privacy)
                        )
                        conn.commit()
                        st.success(f"✅ User '{username}' registered successfully!")
                    except Exception as e:
                        st.error(f"Error: {e}")
                    finally:
                        cursor.close()
                        conn.close()
    
    # TAB 2: View Users
    with tab2:
        st.subheader("All Registered Users")
        
        conn = get_connection()
        if conn:
            try:
                df = pd.read_sql("SELECT userID, userName, email, privacySetting FROM AppUser ORDER BY userID", conn)
                st.dataframe(df, use_container_width=True)
            except Exception as e:
                st.error(f"Error: {e}")
            finally:
                conn.close()
    
    # TAB 3: Update Profile
    with tab3:
        st.subheader("Update User Privacy Settings")
        
        conn = get_connection()
        if conn:
            cursor = conn.cursor()
            
            # Get user list
            cursor.execute("SELECT userID, userName FROM AppUser ORDER BY userID")
            users = cursor.fetchall()
            user_options = {f"{u[1]} (ID: {u[0]})": u[0] for u in users}
            
            with st.form("update_form"):
                selected_user = st.selectbox("Select User", list(user_options.keys()))
                new_privacy = st.selectbox("New Privacy Setting", ["public", "private", "friends"])
                
                update_submitted = st.form_submit_button("Update Privacy")
                
                if update_submitted:
                    try:
                        user_id = user_options[selected_user]
                        cursor.execute(
                            "UPDATE AppUser SET privacySetting = :1 WHERE userID = :2",
                            (new_privacy, user_id)
                        )
                        conn.commit()
                        st.success(f"✅ Privacy setting updated to '{new_privacy}'")
                    except Exception as e:
                        st.error(f"Error: {e}")
            
            cursor.close()
            conn.close()

# =============================================
# MOOD TRACKING PAGE
# =============================================
elif menu == "Mood Tracking":
    st.title("📊 Mood Tracking")
    
    tab1, tab2, tab3 = st.tabs(["Log Mood", "View History", "Mood Analytics"])
    
    # TAB 1: Log Mood
    with tab1:
        st.subheader("Log Your Daily Mood")
        
        conn = get_connection()
        if conn:
            cursor = conn.cursor()
            
            # Get user list
            cursor.execute("SELECT userID, userName FROM AppUser ORDER BY userID")
            users = cursor.fetchall()
            user_options = {f"{u[1]} (ID: {u[0]})": u[0] for u in users}
            
            with st.form("mood_form"):
                selected_user = st.selectbox("Select User", list(user_options.keys()))
                mood_date = st.date_input("Date", date.today())
                mood_level = st.select_slider(
                    "How are you feeling?",
                    options=["Sad", "Anxious", "Stressed", "Neutral", "Calm", "Happy"]
                )
                
                mood_submitted = st.form_submit_button("Log Mood")
                
                if mood_submitted:
                    try:
                        user_id = user_options[selected_user]
                        cursor.execute(
                            "INSERT INTO MoodLog VALUES (:1, TO_DATE(:2, 'YYYY-MM-DD'), :3)",
                            (user_id, mood_date.strftime('%Y-%m-%d'), mood_level)
                        )
                        conn.commit()
                        st.success(f"✅ Mood '{mood_level}' logged for {mood_date}")
                    except Exception as e:
                        st.error(f"Error: {e}")
            
            cursor.close()
            conn.close()
    
    # TAB 2: View History
    with tab2:
        st.subheader("Mood History")
        
        conn = get_connection()
        if conn:
            cursor = conn.cursor()
            
            # Get user list
            cursor.execute("SELECT userID, userName FROM AppUser ORDER BY userID")
            users = cursor.fetchall()
            user_options = {f"{u[1]} (ID: {u[0]})": u[0] for u in users}
            
            selected_user = st.selectbox("Select User to View", list(user_options.keys()))
            
            if st.button("Load Mood History"):
                try:
                    user_id = user_options[selected_user]
                    query = """
                        SELECT logDate, moodLevel 
                        FROM MoodLog 
                        WHERE userID = :1 
                        ORDER BY logDate DESC
                    """
                    df = pd.read_sql(query, conn, params=[user_id])
                    
                    if not df.empty:
                        st.dataframe(df, use_container_width=True)
                        
                        # Mood chart
                        st.line_chart(df.set_index('LOGDATE')['MOODLEVEL'].value_counts())
                    else:
                        st.info("No mood logs found for this user.")
                except Exception as e:
                    st.error(f"Error: {e}")
            
            cursor.close()
            conn.close()
    
    # TAB 3: Mood Analytics
    with tab3:
        st.subheader("Mood Statistics")
        
        conn = get_connection()
        if conn:
            cursor = conn.cursor()
            
            # Get user list
            cursor.execute("SELECT userID, userName FROM AppUser ORDER BY userID")
            users = cursor.fetchall()
            user_options = {f"{u[1]} (ID: {u[0]})": u[0] for u in users}
            
            selected_user = st.selectbox("Select User for Analytics", list(user_options.keys()))
            
            if st.button("Generate Analytics"):
                try:
                    user_id = user_options[selected_user]
                    query = """
                        SELECT moodLevel, COUNT(*) as frequency
                        FROM MoodLog
                        WHERE userID = :1
                        GROUP BY moodLevel
                        ORDER BY frequency DESC
                    """
                    df = pd.read_sql(query, conn, params=[user_id])
                    
                    if not df.empty:
                        st.bar_chart(df.set_index('MOODLEVEL'))
                        
                        # Most common mood
                        most_common = df.iloc[0]
                        st.metric("Most Common Mood", most_common['MOODLEVEL'], f"{most_common['FREQUENCY']} times")
                    else:
                        st.info("No mood data available.")
                except Exception as e:
                    st.error(f"Error: {e}")
            
            cursor.close()
            conn.close()

# =============================================
# SUPPORT GROUPS PAGE
# =============================================
elif menu == "Support Groups":
    st.title("👥 Support Groups")
    
    tab1, tab2, tab3 = st.tabs(["View Groups", "Join Group", "My Groups"])
    
    # TAB 1: View All Groups
    with tab1:
        st.subheader("Available Support Groups")
        
        conn = get_connection()
        if conn:
            try:
                query = """
                    SELECT 
                        sg.groupID,
                        sg.groupName,
                        sg.focusArea,
                        COUNT(ug.userID) as member_count
                    FROM SupportGroup sg
                    LEFT JOIN UserGroup ug ON sg.groupID = ug.groupID
                    GROUP BY sg.groupID, sg.groupName, sg.focusArea
                    ORDER BY member_count DESC
                """
                df = pd.read_sql(query, conn)
                st.dataframe(df, use_container_width=True)
            except Exception as e:
                st.error(f"Error: {e}")
            finally:
                conn.close()
    
    # TAB 2: Join Group
    with tab2:
        st.subheader("Join a Support Group")
        
        conn = get_connection()
        if conn:
            cursor = conn.cursor()
            
            # Get users and groups
            cursor.execute("SELECT userID, userName FROM AppUser ORDER BY userID")
            users = cursor.fetchall()
            user_options = {f"{u[1]} (ID: {u[0]})": u[0] for u in users}
            
            cursor.execute("SELECT groupID, groupName FROM SupportGroup ORDER BY groupID")
            groups = cursor.fetchall()
            group_options = {f"{g[1]} (ID: {g[0]})": g[0] for g in groups}
            
            with st.form("join_group_form"):
                selected_user = st.selectbox("Select User", list(user_options.keys()))
                selected_group = st.selectbox("Select Group", list(group_options.keys()))
                
                join_submitted = st.form_submit_button("Join Group")
                
                if join_submitted:
                    try:
                        user_id = user_options[selected_user]
                        group_id = group_options[selected_group]
                        cursor.execute(
                            "INSERT INTO UserGroup VALUES (:1, :2)",
                            (user_id, group_id)
                        )
                        conn.commit()
                        st.success(f"✅ Successfully joined group!")
                    except Exception as e:
                        st.error(f"Error: {e}")
            
            cursor.close()
            conn.close()
    
    # TAB 3: My Groups
    with tab3:
        st.subheader("My Support Groups")
        
        conn = get_connection()
        if conn:
            cursor = conn.cursor()
            
            # Get user list
            cursor.execute("SELECT userID, userName FROM AppUser ORDER BY userID")
            users = cursor.fetchall()
            user_options = {f"{u[1]} (ID: {u[0]})": u[0] for u in users}
            
            selected_user = st.selectbox("Select User", list(user_options.keys()))
            
            if st.button("View My Groups"):
                try:
                    user_id = user_options[selected_user]
                    query = """
                        SELECT sg.groupID, sg.groupName, sg.focusArea
                        FROM SupportGroup sg
                        JOIN UserGroup ug ON sg.groupID = ug.groupID
                        WHERE ug.userID = :1
                    """
                    df = pd.read_sql(query, conn, params=[user_id])
                    
                    if not df.empty:
                        st.dataframe(df, use_container_width=True)
                    else:
                        st.info("You haven't joined any groups yet.")
                except Exception as e:
                    st.error(f"Error: {e}")
            
            cursor.close()
            conn.close()

# =============================================
# COUNSELING SESSIONS PAGE
# =============================================
elif menu == "Counseling Sessions":
    st.title("💬 Counseling Sessions")
    
    tab1, tab2, tab3 = st.tabs(["View Sessions", "Attend Session", "Rate Session"])
    
    # TAB 1: View Sessions
    with tab1:
        st.subheader("All Counseling Sessions")
        
        conn = get_connection()
        if conn:
            try:
                query = """
                    SELECT 
                        cs.sessionID,
                        cs.sessionDate,
                        cs.topic,
                        cs.sessionMode,
                        u.userName as counselor,
                        sg.groupName
                    FROM CounselingSession cs
                    JOIN Counselor c ON cs.counselorID = c.userID
                    JOIN AppUser u ON c.userID = u.userID
                    JOIN SupportGroup sg ON cs.groupID = sg.groupID
                    ORDER BY cs.sessionDate DESC
                """
                df = pd.read_sql(query, conn)
                st.dataframe(df, use_container_width=True)
            except Exception as e:
                st.error(f"Error: {e}")
            finally:
                conn.close()
    
    # TAB 2: Attend Session
    with tab2:
        st.subheader("Register for a Session")
        
        conn = get_connection()
        if conn:
            cursor = conn.cursor()
            
            # Get users and sessions
            cursor.execute("SELECT userID, userName FROM AppUser ORDER BY userID")
            users = cursor.fetchall()
            user_options = {f"{u[1]} (ID: {u[0]})": u[0] for u in users}
            
            cursor.execute("SELECT sessionID, topic FROM CounselingSession ORDER BY sessionID")
            sessions = cursor.fetchall()
            session_options = {f"{s[1]} (ID: {s[0]})": s[0] for s in sessions}
            
            with st.form("attend_session_form"):
                selected_user = st.selectbox("Select User", list(user_options.keys()))
                selected_session = st.selectbox("Select Session", list(session_options.keys()))
                
                attend_submitted = st.form_submit_button("Register for Session")
                
                if attend_submitted:
                    try:
                        user_id = user_options[selected_user]
                        session_id = session_options[selected_session]
                        cursor.execute(
                            "INSERT INTO UserSession (userID, sessionID, rating) VALUES (:1, :2, NULL)",
                            (user_id, session_id)
                        )
                        conn.commit()
                        st.success(f"✅ Registered for session!")
                    except Exception as e:
                        st.error(f"Error: {e}")
            
            cursor.close()
            conn.close()
    
    # TAB 3: Rate Session
    with tab3:
        st.subheader("Rate Your Session")
        
        conn = get_connection()
        if conn:
            cursor = conn.cursor()
            
            # Get users
            cursor.execute("SELECT userID, userName FROM AppUser ORDER BY userID")
            users = cursor.fetchall()
            user_options = {f"{u[1]} (ID: {u[0]})": u[0] for u in users}
            
            selected_user = st.selectbox("Select User", list(user_options.keys()))
            user_id = user_options[selected_user]
            
            # Get sessions attended by this user
            cursor.execute("""
                SELECT cs.sessionID, cs.topic, us.rating
                FROM CounselingSession cs
                JOIN UserSession us ON cs.sessionID = us.sessionID
                WHERE us.userID = :1
            """, [user_id])
            
            sessions = cursor.fetchall()
            
            if sessions:
                session_options = {f"{s[1]} (ID: {s[0]}) - Current: {s[2] if s[2] else 'Not Rated'}": s[0] for s in sessions}
                
                with st.form("rate_session_form"):
                    selected_session = st.selectbox("Select Session to Rate", list(session_options.keys()))
                    rating = st.slider("Rating", 1, 5, 5)
                    
                    rate_submitted = st.form_submit_button("Submit Rating")
                    
                    if rate_submitted:
                        try:
                            session_id = session_options[selected_session]
                            cursor.execute(
                                "UPDATE UserSession SET rating = :1 WHERE userID = :2 AND sessionID = :3",
                                (rating, user_id, session_id)
                            )
                            conn.commit()
                            st.success(f"✅ Session rated {rating}/5!")
                        except Exception as e:
                            st.error(f"Error: {e}")
            else:
                st.info("You haven't attended any sessions yet.")
            
            cursor.close()
            conn.close()

# =============================================
# PEER MATCHING PAGE
# =============================================
elif menu == "Peer Matching":
    st.title("🤝 Peer Matching")
    
    tab1, tab2 = st.tabs(["Find Matches", "View My Matches"])
    
    # TAB 1: Find Matches
    with tab1:
        st.subheader("Find Compatible Peers")
        
        conn = get_connection()
        if conn:
            cursor = conn.cursor()
            
            # Get user list
            cursor.execute("SELECT userID, userName FROM AppUser ORDER BY userID")
            users = cursor.fetchall()
            user_options = {f"{u[1]} (ID: {u[0]})": u[0] for u in users}
            
            selected_user = st.selectbox("Select User", list(user_options.keys()))
            
            if st.button("Find My Matches"):
                try:
                    user_id = user_options[selected_user]
                    query = """
                        SELECT 
                            CASE 
                                WHEN um.user1ID = :1 THEN um.user2ID
                                ELSE um.user1ID
                            END as matched_userID,
                            u.userName,
                            um.compatibilityScore
                        FROM UserMatch um
                        JOIN AppUser u ON (
                            CASE 
                                WHEN um.user1ID = :1 THEN um.user2ID
                                ELSE um.user1ID
                            END = u.userID
                        )
                        WHERE :1 IN (um.user1ID, um.user2ID)
                        ORDER BY um.compatibilityScore DESC
                    """
                    df = pd.read_sql(query, conn, params=[user_id, user_id, user_id])
                    
                    if not df.empty:
                        st.dataframe(df, use_container_width=True)
                        
                        # Best match
                        best_match = df.iloc[0]
                        st.success(f"🌟 Best Match: {best_match['USERNAME']} ({best_match['COMPATIBILITYSCORE']}% compatible)")
                    else:
                        st.info("No matches found yet.")
                except Exception as e:
                    st.error(f"Error: {e}")
            
            cursor.close()
            conn.close()
    
    # TAB 2: View Matches
    with tab2:
        st.subheader("All Peer Matches")
        
        conn = get_connection()
        if conn:
            try:
                query = """
                    SELECT 
                        u1.userName as user1,
                        u2.userName as user2,
                        um.compatibilityScore
                    FROM UserMatch um
                    JOIN AppUser u1 ON um.user1ID = u1.userID
                    JOIN AppUser u2 ON um.user2ID = u2.userID
                    ORDER BY um.compatibilityScore DESC
                """
                df = pd.read_sql(query, conn)
                st.dataframe(df, use_container_width=True)
            except Exception as e:
                st.error(f"Error: {e}")
            finally:
                conn.close()

# =============================================
# RESOURCES PAGE
# =============================================
elif menu == "Resources":
    st.title("📚 Learning Resources")
    
    tab1, tab2 = st.tabs(["View Resources", "My Resources"])
    
    # TAB 1: View All Resources
    with tab1:
        st.subheader("Available Learning Resources")
        
        conn = get_connection()
        if conn:
            try:
                query = """
                    SELECT 
                        lr.resourceID,
                        lr.title,
                        lr.resourceType,
                        COUNT(gr.groupID) as used_by_groups
                    FROM LearningResource lr
                    LEFT JOIN GroupResource gr ON lr.resourceID = gr.resourceID
                    GROUP BY lr.resourceID, lr.title, lr.resourceType
                    ORDER BY used_by_groups DESC
                """
                df = pd.read_sql(query, conn)
                st.dataframe(df, use_container_width=True)
            except Exception as e:
                st.error(f"Error: {e}")
            finally:
                conn.close()
    
    # TAB 2: My Resources
    with tab2:
        st.subheader("Resources from My Groups")
        
        conn = get_connection()
        if conn:
            cursor = conn.cursor()
            
            # Get user list
            cursor.execute("SELECT userID, userName FROM AppUser ORDER BY userID")
            users = cursor.fetchall()
            user_options = {f"{u[1]} (ID: {u[0]})": u[0] for u in users}
            
            selected_user = st.selectbox("Select User", list(user_options.keys()))
            
            if st.button("Load My Resources"):
                try:
                    user_id = user_options[selected_user]
                    query = """
                        SELECT DISTINCT
                            lr.resourceID,
                            lr.title,
                            lr.resourceType,
                            sg.groupName
                        FROM LearningResource lr
                        JOIN GroupResource gr ON lr.resourceID = gr.resourceID
                        JOIN SupportGroup sg ON gr.groupID = sg.groupID
                        JOIN UserGroup ug ON sg.groupID = ug.groupID
                        WHERE ug.userID = :1
                        ORDER BY sg.groupName, lr.title
                    """
                    df = pd.read_sql(query, conn, params=[user_id])
                    
                    if not df.empty:
                        st.dataframe(df, use_container_width=True)
                    else:
                        st.info("Join a support group to access resources.")
                except Exception as e:
                    st.error(f"Error: {e}")
            
            cursor.close()
            conn.close()

# =============================================
# ANALYTICS PAGE
# =============================================
elif menu == "Analytics":
    st.title("📈 Platform Analytics")
    
    conn = get_connection()
    if conn:
        cursor = conn.cursor()
        
        # Platform Statistics
        st.subheader("Platform Overview")
        col1, col2, col3, col4 = st.columns(4)
        
        try:
            # Total Users
            cursor.execute("SELECT COUNT(*) FROM AppUser")
            col1.metric("Total Users", cursor.fetchone()[0])
            
            # Total Counselors
            cursor.execute("SELECT COUNT(*) FROM Counselor")
            col2.metric("Counselors", cursor.fetchone()[0])
            
            # Total Mood Logs
            cursor.execute("SELECT COUNT(*) FROM MoodLog")
            col3.metric("Mood Logs", cursor.fetchone()[0])
            
            # Avg Rating
            cursor.execute("SELECT ROUND(AVG(rating), 2) FROM UserSession WHERE rating IS NOT NULL")
            avg = cursor.fetchone()[0]
            col4.metric("Avg Rating", f"{avg}/5" if avg else "N/A")
            
        except Exception as e:
            st.error(f"Error: {e}")
        
        st.markdown("---")
        
        # Most Active Groups
        st.subheader("Most Active Support Groups")
        try:
            query = """
                SELECT 
                    sg.groupName,
                    sg.focusArea,
                    COUNT(DISTINCT ug.userID) as members,
                    COUNT(DISTINCT cs.sessionID) as sessions
                FROM SupportGroup sg
                LEFT JOIN UserGroup ug ON sg.groupID = ug.groupID
                LEFT JOIN CounselingSession cs ON sg.groupID = cs.groupID
                GROUP BY sg.groupName, sg.focusArea
                ORDER BY members DESC
                FETCH FIRST 5 ROWS ONLY
            """
            df = pd.read_sql(query, conn)
            st.dataframe(df, use_container_width=True)
        except Exception as e:
            st.error(f"Error: {e}")
        
        st.markdown("---")
        
        # Top Counselors
        st.subheader("Top Rated Counselors")
        try:
            query = """
                SELECT 
                    u.userName,
                    c.specialization,
                    COUNT(cs.sessionID) as sessions,
                    ROUND(AVG(us.rating), 2) as avg_rating
                FROM Counselor c
                JOIN AppUser u ON c.userID = u.userID
                LEFT JOIN CounselingSession cs ON c.userID = cs.counselorID
                LEFT JOIN UserSession us ON cs.sessionID = us.sessionID
                GROUP BY u.userName, c.specialization
                ORDER BY avg_rating DESC
                FETCH FIRST 5 ROWS ONLY
            """
            df = pd.read_sql(query, conn)
            st.dataframe(df, use_container_width=True)
        except Exception as e:
            st.error(f"Error: {e}")
        
        cursor.close()
        conn.close()

# =============================================
# FOOTER
# =============================================
st.sidebar.markdown("---")
st.sidebar.info("**MindConnect+**\nMental Health Support Platform\nCSC-584 Database Project")