# MindConnect+ Quick Reference Guide

## 🚀 Quick Start (5 Minutes)

### 1. Install Packages
```bash
pip install streamlit oracledb pandas
```

### 2. Update Credentials in `app.py`
Find line ~11 and replace:
```python
user="YOUR_USERNAME"      # Your Oracle username
password="YOUR_PASSWORD"  # Your Oracle password
```

### 3. Test Connection
```bash
python test_connection.py
```

### 4. Run App
```bash
streamlit run app.py
```

### 5. Open Browser
Go to: **http://localhost:8501**

---
## 🎯 Common Commands

### Start the App
```bash
streamlit run app.py
```

### Stop the App
Press `Ctrl + C` in terminal

### Run on Different Port
```bash
streamlit run app.py --server.port 8502
```

### Clear Cache
```bash
streamlit cache clear
```

### Install All Dependencies
```bash
pip install -r requirements.txt
```

---

## 🔧 Database Connection String Breakdown

```python
dsn="000.000.00.00:1111/xyz"
     ^^^^^^^^^^^^^  ^^^^  ^^^^
     |              |     |
     Server IP      Port  Service name
```

- **Server IP:** 
- **Port:** (default Oracle port)
- **Service:** (database service name)

---

## 📊 Features Implemented

### 1. User Management
- ✅ Register new users (INSERT)
- ✅ View all users (SELECT)
- ✅ Update privacy settings (UPDATE)

### 2. Mood Tracking
- ✅ Log daily moods (INSERT)
- ✅ View mood history (SELECT with WHERE)
- ✅ Mood statistics (GROUP BY, COUNT)
- ✅ Find similar mood patterns (JOIN)

### 3. Support Groups
- ✅ View all groups (SELECT with aggregates)
- ✅ Join groups (INSERT)
- ✅ View my groups (JOIN)

### 4. Counseling Sessions
- ✅ View all sessions (multi-table JOIN)
- ✅ Register for sessions (INSERT)
- ✅ Rate sessions (UPDATE)

### 5. Peer Matching
- ✅ Find compatible users (self-referential JOIN)
- ✅ View all matches (UNION)

### 6. Resources
- ✅ View all resources (LEFT JOIN)
- ✅ View my resources (complex JOIN)

### 7. Analytics Dashboard
- ✅ Platform statistics (multiple aggregates)
- ✅ Top groups (ORDER BY, LIMIT)
- ✅ Top counselors (nested queries)

---

## 🐛 Troubleshooting Quick Fixes

### Problem: "No module named 'streamlit'"
```bash
pip install streamlit oracledb pandas --upgrade
```

### Problem: "Database connection failed"
1. Check username/password in app.py
2. Test with SQL Developer first
3. Verify VPN connection if remote

### Problem: "Table does not exist"
Run your schema creation SQL script first

### Problem: "Port already in use"
```bash
streamlit run app.py --server.port 8502
```

### Problem: "pip not recognized"
Try: `pip3` or `python -m pip` instead

---



### Technology Stack
**Frontend:** Streamlit 1.28.0  
**Backend:** Python 3.x with oracledb 1.4.2  
**Database:** Oracle Database (oracle.csep.umflint.edu)  
**Data Handling:** Pandas 2.1.3

### Installation Steps Summary
1. Installed Python 3.x from python.org
2. Installed required packages: `pip install streamlit oracledb pandas`
3. Configured database connection with university Oracle credentials
4. Created Streamlit web application with 8 functional pages
5. Implemented all Phase III database operations

### Key Development Steps
1. **Database Connection Module:** Used `oracledb.connect()` for establishing connection
2. **User Interface:** Created multi-page navigation using Streamlit
3. **Forms:** Implemented data entry forms with `st.form()`
4. **Queries:** Executed SQL using cursor.execute() and pandas.read_sql()
5. **Data Display:** Used DataFrames and charts for visualization
6. **Error Handling:** Added try-except blocks for all database operations

### Operations Demonstrated
- **CREATE:** Registration forms (Users, Sessions)
- **READ:** View pages with filtering and sorting
- **UPDATE:** Privacy settings, session ratings, progress notes
- **DELETE:** Group membership removal
- **Complex Queries:** JOINs (3+ tables), Aggregates (COUNT, AVG), Subqueries, Self-joins

---



### Before 
- [ ] Database schema created and populated
- [ ] App runs without errors
- [ ] Browser open to localhost:8501
- [ ] Prepared sample data for demo

### During 
1. Show **Home Page** - Platform statistics
2. **Register a new user** - INSERT operation
3. **Log a mood** - INSERT into weak entity
4. **Join a support group** - Many-to-many relationship
5. **View mood analytics** - GROUP BY query
6. **Find peer matches** - Self-join query
7. **Rate a session** - UPDATE operation
8. **Show analytics dashboard** - Complex nested queries

### Things to Mention
- Easy to use web interface (no command line needed)
- Real-time database operations
- Data validation and error handling
- Responsive design with multiple pages
- Professional visualization with charts

---


## 🔗 Useful Resources

- **Streamlit Docs:** https://docs.streamlit.io
- **oracledb Docs:** https://python-oracledb.readthedocs.io
- **Pandas Docs:** https://pandas.pydata.org/docs/

---

## ⚡ Emergency Fixes

### If app crashes during demo:
```bash
# Restart the app
Ctrl + C
streamlit run app.py
```

### If database disconnects:
- Check your VPN connection
- Restart the app
- Have SQL Developer open as backup

### If specific feature breaks:
- Comment out that section temporarily
- Show it working in SQL Developer instead
- Move to next feature

---










