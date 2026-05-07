# Recruitment Management System (RecruitPro)

A comprehensive web-based recruitment management system designed to streamline the entire hiring workflow. Built with **Flask**, **MySQL**, and **Bootstrap 5**, the platform serves five distinct user roles – **Candidate**, **HR Manager**, **Interviewer**, **Analyst**, and **Administrator** – each with a dedicated, role‑specific interface.

The system supports the complete recruitment lifecycle: job posting, candidate application, interview scheduling and feedback, final decision, and real‑time notifications, all backed by a robust, highly normalized database with advanced objects like views, stored procedures, triggers, and functions.

---

## System Architecture & Technologies

| Layer             | Technology / Tools                                                                               |
| ----------------- | ------------------------------------------------------------------------------------------------ |
| Backend           | Python 3, Flask (Blueprints, Jinja2), Flask-WTF (CSRF protection), bcrypt                        |
| Database          | MySQL 8 (20+ tables, 12 views, 35+ stored procedures, 15+ triggers, 5 user‑defined functions)    |
| Frontend          | HTML5, CSS3, Bootstrap 5 (responsive), Chart.js (charts), Font Awesome (icons)                   |
| Data Seeding      | Faker (generates realistic Vietnamese sample data)                                                |
| Connection        | mysql-connector-python with connection pooling                                                    |

---

## Key Features (by Role)

### Candidate
- **Job Discovery:** Browse open positions with dynamic filters (keyword, industry, location, salary range).
- **One‑click Apply:** Submit applications with an optional cover letter and CV upload.
- **Application Tracker:** Monitor the status of each application (*Applied → Screening → Interviewing → Offered → Accepted/Rejected*) on a personal dashboard with a doughnut chart.
- **Interview Management:** View upcoming interview details (date, interviewer, location).
- **Offer Management:** Accept or decline job offers directly from the dashboard.
- **Notifications:** Receive real‑time alerts when application status changes (via database triggers).
- **Profile & Skills:** Update personal information, upload a CV, and manage a list of professional skills.
- **Saved Jobs:** Bookmark interesting positions for later.

### HR Manager (per‑company isolation)
- **Job Posting:** Create and edit detailed job listings with required skills, salary ranges, deadlines, and number of openings.
- **Candidate Pipeline:** View all applicants, filter by status/position/keyword, and update statuses (e.g., Screening, Interviewing).
- **Interview Scheduling:** Schedule interviews with date/time, interviewer selection (from own company), round number, and location.
- **Interview Feedback Review:** Access completed interview scores and detailed feedback; make the final hiring decision (Offer / Reject).
- **Recruitment Dashboard:** Visualize the hiring funnel (bar chart), monitor today's new applications, upcoming interviews, and expiring offers.
- **Internal Notes:** Add private notes to candidate applications.

### Interviewer
- **Today’s Dashboard:** See a summary of today’s interviews with quick actions (confirm attendance, start interview, view candidate CV, submit feedback).
- **My Schedule:** Split into “Upcoming” and “Past” tabs with filters. Past interviews display scores and results.
- **Feedback Form:** Provide structured feedback including technical skills, communication, strengths, weaknesses, and an overall score.
- **Notifications:** Be alerted immediately when assigned to a new interview; view details and jump to the highlighted interview in the schedule.

### Analyst
- **System‑wide Dashboard:** Aggregate statistics (total applications, interviews, jobs, offers) with a recruitment funnel and monthly application trend charts.
- **Filter by Company:** Drill down into data for a specific employer.
- **Top Candidates:** View ranked candidates per company based on interview scores.
- **Interviewer Workload:** Monitor each interviewer’s total sessions, average score, and pass/fail counts.

### Administrator
- **Industry Management:** Add or remove industry categories.
- **User Management:** View all users (HR, Interviewer, Candidate, Analyst), lock/unlock accounts, and reset passwords.
- **Audit Logs:** Browse system‑wide application status changes and interview score updates for transparency.
- **Backup & Recovery:** Archive applications data with one click (demo).

---

## Database Design Highlights

- **Normalized Schema:** 20+ tables with appropriate primary/foreign keys, CHECK constraints, and ON DELETE actions.
- **Soft‑Delete:** Most entities use an `IsDeleted` flag, enabling data recovery and preserving referential integrity.
- **Advanced Objects:**
  - **Views:** `View_ApplicationSummary`, `View_TopCandidates`, `View_InterviewerWorkload`, `View_StageConversionRates`, etc.
  - **Stored Procedures:** encapsulate core business logic (e.g., `sp_ScheduleInterview`, `sp_RecordInterviewResult`, `sp_SubmitApplication`).
  - **Triggers:** automatically update application statuses, write audit logs, and push notifications to candidates and interviewers.
  - **Functions:** `fn_GetAge`, `fn_IsEligible`, `fn_AvgInterviewScore`, etc.
- **Multi‑tenancy:** HR and Interviewer data are isolated per employer, mimicking a SaaS recruitment platform.
- **Security:** Passwords hashed with bcrypt, CSRF protection on all forms, role‑based access control via Flask session + decorators.

---

## Project Structure

```text
RecruitPro/
├── app.py                     # Flask entry point, blueprint registration
├── config.py                  # Application configuration
├── requirements.txt           # Python dependencies
├── .env.example               # Environment variables template
├── models/
│   └── db.py                  # Database connection pool & query helpers
├── controllers/               # Route blueprints (auth, candidate, hr, interviewer, analyst, admin)
├── templates/                 # Jinja2 templates (organized by role)
│   ├── base.html              # Main layout with navbar, toast, footer
│   ├── candidate/             # Dashboard, search, applications, profile, etc.
│   ├── hr/                    # Dashboard, jobs, candidates, schedule, review, reports
│   ├── interviewer/           # Dashboard, schedule, notifications
│   ├── analyst/               # Dashboard, top candidates, interviewer workload
│   └── admin/                 # Dashboard, industries, users, logs, backup
├── static/
│   └── css/style.css          # Custom styles
├── utils/
│   ├── decorators.py          # @login_required(role) decorator
│   └── helpers.py             # Password hashing, etc.
└── database/
    ├── 01_schema.sql          # Full database structure (tables, views, triggers)
    ├── 02_procedures.sql      # All stored procedures and functions
    └── seed_full_demo_data.py # Script to populate the database with realistic sample data


Getting Started (Local Installation)
Prerequisites
Python 3.8+

MySQL Server 8.0+

MySQL Workbench (optional, for SQL execution)

1. Clone the repository
bash
git clone https://github.com/tungdk2006-coder/RecruitPro.git
cd RecruitPro

2. Install Python dependencies
bash
pip install -r requirements.txt

3. Set up the database
Open MySQL Workbench (or any MySQL client).

Execute the schema file to create the database, tables, views, and triggers:
File → Run SQL Script → select database/01_schema.sql

Execute the procedures file to create stored procedures and functions:
File → Run SQL Script → select database/02_procedures.sql

Important: If you already have a database named recruitmentdb, the script will drop and recreate it. Adjust if needed.

4. (Optional) Generate sample data
This script will populate the database with 200 candidates, 12 real Vietnamese employers, 48 jobs, and realistic workflows including applications, interviews, offers, and notifications.

bash
python database/seed_full_demo_data.py
After execution, you can log in with the demo accounts below.

5. Configure environment variables
Rename .env.example to .env and fill in your MySQL credentials and a secret key:

DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=RecruitmentDB
SECRET_KEY=your_secret_key
WTF_CSRF_SECRET_KEY=your_csrf_key

6. Launch the application
bash
python app.py
Open your browser and navigate to http://127.0.0.1:5000.

6.1. Demo Accounts (after running seed script)
Default password for all accounts: hashed_demo_password_123

Role	Email / Pattern	Example
Candidate:	cand1@example.com … cand200@example.com, cand1@example.com
HR Manager:	hr_1@demo.com … hr_12@demo.com, hr_1@demo.com
Interviewer:	 intv_1_1@demo.com, intv_1_2@demo.com, ... , intv_12_4@demo.com
Analyst:	analyst@demo.com	
Admin:	admin@demo.com	
Check the Interviewers table for exact interviewer emails.

6.2. Results & Achievements
Fully functional recruitment lifecycle covering 5 distinct user perspectives.

Robust, scalable database design suitable for multi‑company environments.

Intuitive, responsive UI with dynamic charts and real‑time notifications.

Secure authentication and role‑based data isolation.

Comprehensive documentation and ready‑to‑run scripts.

6.3. Future Improvements
Integration with external job boards (LinkedIn, Indeed).

Email notifications for real‑world communication.

Candidate ranking and CV parsing.

Mobile application.

7Author
Name: Nguyễn Trùng Tùng

Student ID: 11245950

Course: Database Management Systems – Project 06

Instructor: Thầy Trần Quốc Hùng

Institution: National Economics University (NEU), College of Technology

8. License
This project is submitted as a university assignment. Feel free to use it for educational purposes.