import os
import random
from datetime import datetime, timedelta, date
from faker import Faker
from dotenv import load_dotenv
import mysql.connector

load_dotenv()

host = os.getenv('DB_HOST', 'localhost')
user = os.getenv('DB_USER', 'root')
password = os.getenv('DB_PASSWORD', '')
database = os.getenv('DB_NAME', 'RecruitmentDB')

fake = Faker('vi_VN')
fake_en = Faker('en_US')

# ------------------------------
# CẤU HÌNH & DỮ LIỆU TĨNH
# ------------------------------
INDUSTRIES = [
    'Information Technology', 'Finance & Banking', 'Healthcare & Medical',
    'Education & Training', 'Manufacturing & Engineering', 'Retail & E-commerce',
    'Marketing & Advertising', 'Real Estate', 'Logistics & Supply Chain',
    'Hospitality & Tourism'
]

SKILLS = [
    'Python', 'Java', 'SQL', 'JavaScript', 'C++', 'C#', 'Ruby', 'PHP',
    'Swift', 'Kotlin', 'HTML/CSS', 'React', 'Angular', 'Vue.js', 'Node.js',
    'Flask', 'Django', 'Spring Boot', 'Docker', 'Kubernetes', 'AWS', 'Azure',
    'Google Cloud', 'Project Management', 'Communication', 'Teamwork', 'Leadership',
    'Data Analysis', 'Machine Learning', 'UI/UX Design', 'Figma', 'Adobe Photoshop',
    'Agile/Scrum', 'Business Analysis', 'Digital Marketing', 'SEO/SEM'
]

JOB_TITLES = [
    "Software Engineer", "Senior Software Engineer", "Frontend Developer",
    "Backend Developer", "Fullstack Developer", "Mobile App Developer",
    "DevOps Engineer", "Cloud Architect", "Data Scientist", "Data Analyst",
    "Data Engineer", "Machine Learning Engineer", "Product Manager",
    "Project Manager", "Scrum Master", "Business Analyst", "QA Engineer",
    "Automation Tester", "UI/UX Designer", "Product Designer",
    "System Administrator", "Database Administrator", "Security Engineer",
    "Network Engineer", "Marketing Manager", "Digital Marketing Specialist",
    "Content Writer", "SEO Specialist", "Sales Executive", "Account Manager",
    "HR Generalist", "Recruitment Specialist", "Financial Analyst",
    "Accountant", "Operations Manager"
]

CITIES = ['Hà Nội', 'Hồ Chí Minh', 'Đà Nẵng', 'Cần Thơ', 'Hải Phòng', 'Bình Dương', 'Remote']

EMPLOYERS_DATA = [
    ('FPT Software', 'contact@fpt.com.vn', '024 7300 5588',
     'Số 17 Phố Duy Tân, Cầu Giấy, Hà Nội', 'Enterprise',
     'FPT Software is a leading Vietnamese IT company, part of FPT Corporation, specializing in software outsourcing, digital transformation, and AI solutions.'),
    ('VNG Corporation', 'contact@vng.com.vn', '028 3911 4747',
     'Lô 14, Đường Số 11, Khu Công Nghệ Cao, Q.9, TP.HCM', 'Enterprise',
     'VNG is a prominent Vietnamese internet company, known for products like Zalo, Zing MP3, and various online games.'),
    ('Shopee', 'contact@shopee.vn', '1900 1221',
     '28 Tầng, Tòa Nhà Saigon Centre 2, 67 Lê Lợi, Q.1, TP.HCM', 'Large',
     'Shopee is the leading e-commerce platform in Southeast Asia and Taiwan, offering a wide range of products with a focus on mobile shopping.'),
    ('Lazada', 'contact@lazada.vn', '1900 6536',
     'Tầng 16, Tòa Nhà Vimedimex, 246 Cống Quỳnh, Q.1, TP.HCM', 'Large',
     'Lazada, part of Alibaba Group, is a major online shopping destination in Southeast Asia, offering electronics, fashion, and more.'),
    ('Grab', 'contact@grab.com', '028 3910 1919',
     'Tầng 6, Tòa Nhà Mapletree Business Centre, 1060 Nguyễn Văn Linh, Q.7, TP.HCM', 'Large',
     'Grab is Southeast Asia\'s leading superapp, providing ride-hailing, food delivery, and digital payment services.'),
    ('Techcombank', 'contact@techcombank.com.vn', '1800 588 822',
     '191 Bà Triệu, Hai Bà Trưng, Hà Nội', 'Enterprise',
     'Techcombank is one of the largest commercial banks in Vietnam, known for its innovative retail and corporate banking services.'),
    ('Viettel Group', 'contact@viettel.com.vn', '1800 8098',
     'Số 1 Trần Hữu Dực, Mỹ Đình 2, Nam Từ Liêm, Hà Nội', 'Enterprise',
     'Viettel Group is a Vietnamese multinational telecommunications company, also involved in digital services and cybersecurity.'),
    ('Vingroup', 'contact@vingroup.net', '1900 2323',
     'Số 7, Đường Bằng Lăng 1, Khu Đô Thị Vinhomes Riverside, Hà Nội', 'Enterprise',
     'Vingroup is Vietnam\'s largest private conglomerate, with businesses in real estate, retail, healthcare, education, and automotive.'),
    ('Masan Group', 'contact@masan.vn', '028 6256 3862',
     'Tầng 40, Tòa Nhà Bitexco Financial Tower, 2 Hải Triều, Q.1, TP.HCM', 'Large',
     'Masan Group is a diversified Vietnamese consumer goods company with a strong presence in food, beverages, and retail.'),
    ('TH True Milk', 'contact@thmilk.vn', '1800 5959',
     'Khu Công Nghiệp Nghĩa Đàn, Nghệ An', 'Medium',
     'TH True Milk is a leading dairy company in Vietnam, famous for its fresh and organic milk products.'),
    ('Vietcombank', 'contact@vietcombank.com.vn', '1900 545413',
     '198 Trần Quang Khải, Hoàn Kiếm, Hà Nội', 'Enterprise',
     'Vietcombank is the largest state-owned commercial bank in Vietnam, providing a wide range of banking and financial services.'),
    ('FPT Telecom', 'contact@fpttelecom.vn', '1900 6600',
     'Số 48-50-52, Đường Lê Văn Tâm, P.Phú Mỹ, Q.7, TP.HCM', 'Enterprise',
     'FPT Telecom, a subsidiary of FPT Corporation, is a major internet and telecommunication service provider in Vietnam.')
]

TOTAL_CANDIDATES = 200
PAST_INTERVIEWS = 10
TODAY_INTERVIEWS = 6
FUTURE_INTERVIEWS = 8   # Tổng 24 / interviewer

# ------------------------------
# KẾT NỐI DB & TIỆN ÍCH
# ------------------------------
def connect_db():
    print(f"Connecting to {host}/{database}...")
    try:
        conn = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=database,
            autocommit=False
        )
        return conn
    except Exception as e:
        print(f"Connection failed: {e}")
        exit(1)

def truncate_tables(cursor):
    print("Deleting old data safely...")
    tables = [
        'InterviewLog', 'ApplicationStatusLog', 'InterviewPanel', 'JobOffers',
        'Interviews', 'Applications', 'JobRequirements', 'CandidateSkills',
        'SavedJobs', 'CandidateNotifications', 'InterviewerNotifications',
        'JobPositions', 'CandidateAccounts', 'Candidates', 'Interviewer_Accounts',
        'Interviewers', 'HR_Accounts', 'Admin_Accounts', 'Analyst_Accounts',
        'Skills', 'Departments', 'Employers', 'Industries'
    ]
    cursor.execute("SET FOREIGN_KEY_CHECKS = 0;")
    for table in tables:
        try:
            cursor.execute(f"DELETE FROM {table};")
            cursor.execute(f"ALTER TABLE {table} AUTO_INCREMENT = 1;")
        except Exception:
            pass
    cursor.execute("SET FOREIGN_KEY_CHECKS = 1;")
    print("Old data deleted.")

# ------------------------------
# CÁC HÀM SEED CHÍNH
# ------------------------------
def seed_base_data(cursor):
    print("Seeding Industries & Skills...")
    for ind in INDUSTRIES:
        cursor.execute("INSERT INTO Industries (IndustryName) VALUES (%s)", (ind,))
    for skill in SKILLS:
        cursor.execute("INSERT INTO Skills (SkillName, Category) VALUES (%s, %s)", (skill, 'General'))

    cursor.execute("SELECT IndustryID FROM Industries")
    ind_ids = [row['IndustryID'] for row in cursor.fetchall()]

    cursor.execute("""
        SELECT COUNT(*) as count 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = %s AND TABLE_NAME = 'Employers' AND COLUMN_NAME = 'CompanyDescription'
    """, (database,))
    if cursor.fetchone()['count'] == 0:
        cursor.execute("ALTER TABLE Employers ADD COLUMN CompanyDescription TEXT;")

    hashed_pw = 'hashed_demo_password_123'
    employer_ids = []

    print("Seeding Employers, Departments & HR...")
    for (name, email, phone, addr, size, desc) in EMPLOYERS_DATA:
        industry_id = random.choice(ind_ids)
        cursor.execute("""
            INSERT INTO Employers (EmployerName, IndustryID, Email, PhoneNumber, Address, CompanySize, CompanyDescription)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (name, industry_id, email, phone, addr, size, desc))
        emp_id = cursor.lastrowid
        employer_ids.append(emp_id)

        hr_email = f"hr_{emp_id}@demo.com"
        cursor.execute("INSERT INTO HR_Accounts (EmployerID, Email, PasswordHash, IsActive) VALUES (%s,%s,%s,TRUE)",
                       (emp_id, hr_email, hashed_pw))

        dept_names = random.sample(['Engineering','Marketing','Sales','HR','Finance','Operations','Product'],
                                   random.randint(1,3))
        for d in dept_names:
            cursor.execute("INSERT INTO Departments (EmployerID, DepartmentName) VALUES (%s, %s)", (emp_id, d))

    print("Seeding Interviewers (1 per job, fixed emails)...")
    for emp_id in employer_ids:
        for i in range(1, 5):  # 4 interviewer
            fullname = fake.name()
            email = f"intv_{emp_id}_{i}@demo.com"
            cursor.execute("INSERT INTO Interviewers (EmployerID, FullName, Email) VALUES (%s, %s, %s)",
                           (emp_id, fullname, email))
            int_id = cursor.lastrowid
            cursor.execute("INSERT INTO Interviewer_Accounts (InterviewerID, PasswordHash, IsActive) VALUES (%s,%s,TRUE)",
                           (int_id, hashed_pw))

    # Admin & Analyst
    cursor.execute("INSERT INTO Admin_Accounts (Email, PasswordHash, IsActive) VALUES ('admin@demo.com',%s,TRUE)", (hashed_pw,))
    cursor.execute("INSERT INTO Analyst_Accounts (Email, PasswordHash, IsActive) VALUES ('analyst@demo.com',%s,TRUE)", (hashed_pw,))

    print(f"-> Created {len(INDUSTRIES)} Industries, {len(SKILLS)} Skills, "
          f"{len(employer_ids)} Employers, 48 Interviewers.")

def seed_candidates(cursor):
    print(f"Seeding {TOTAL_CANDIDATES} Candidates...")
    hashed_pw = 'hashed_demo_password_123'
    cursor.execute("SELECT SkillID FROM Skills")
    skill_ids = [row['SkillID'] for row in cursor.fetchall()]

    for i in range(1, TOTAL_CANDIDATES + 1):
        gender = random.choice(['Male','Female','Other'])
        name = fake.name_male() if gender == 'Male' else (fake.name_female() if gender == 'Female' else fake.name())
        dob = fake.date_of_birth(minimum_age=18, maximum_age=45)
        email = f"cand{i}@example.com"
        phone = f"0{random.randint(100000000, 999999999)}"
        addr = f"{fake.street_address()}, {random.choice(CITIES)}"
        edu = random.choice(['High School','Associate','Bachelor','Master','PhD'])
        gpa = round(random.uniform(2.0,4.0), 2)
        exp = random.randint(0,10)
        resume = f"resume_{i}.pdf" if random.random() > 0.3 else None

        cursor.execute("""
            INSERT INTO Candidates (CandidateName, Gender, DateOfBirth, Email, PhoneNumber, Address, EducationLevel, GPA, YearsOfExperience, ResumeURL)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """, (name, gender, dob, email, phone, addr, edu, gpa, exp, resume))
        cid = cursor.lastrowid
        cursor.execute("INSERT INTO CandidateAccounts (CandidateID, Email, PasswordHash, IsActive) VALUES (%s,%s,%s,TRUE)",
                       (cid, email, hashed_pw))

        # Skills
        for sid in random.sample(skill_ids, random.randint(1,5)):
            prof = random.choice(['Beginner','Intermediate','Advanced'])
            yrs = round(random.uniform(0.5,8.0), 1)
            cursor.execute("INSERT INTO CandidateSkills (CandidateID, SkillID, ProficiencyLevel, YearsUsed) VALUES (%s,%s,%s,%s)",
                           (cid, sid, prof, yrs))
    print(f"-> Created {TOTAL_CANDIDATES} Candidates.")

def seed_jobs(cursor):
    print("Seeding 48 Jobs (deadline all in July 2026)...")
    cursor.execute("SELECT EmployerID FROM Employers")
    employer_ids = [row['EmployerID'] for row in cursor.fetchall()]
    cursor.execute("SELECT DepartmentID, EmployerID FROM Departments")
    all_depts = cursor.fetchall()
    cursor.execute("SELECT SkillID FROM Skills")
    skill_ids = [row['SkillID'] for row in cursor.fetchall()]

    for emp_id in employer_ids:
        emp_depts = [d for d in all_depts if d['EmployerID'] == emp_id]
        dept_id = random.choice(emp_depts)['DepartmentID'] if emp_depts else None

        for _ in range(4):
            title = random.choice(JOB_TITLES)
            desc = fake_en.text(max_nb_chars=800)
            job_type = random.choice(['Full-time','Part-time','Contract','Internship','Remote'])
            loc = random.choice(CITIES)
            min_sal = random.randint(5,25) * 1_000_000
            max_sal = min_sal + random.randint(2,15) * 1_000_000
            exp = random.randint(0,7)
            edu = random.choice(['High School','Associate','Bachelor','Master','PhD',None])
            openings = random.randint(1,5)
            max_rounds = random.randint(1,3)
            # DEADLINE: ngẫu nhiên trong tháng 7/2026
            deadline = date(2026, 7, random.randint(1, 31))
            status = random.choices(['Open','Draft','Closed'], weights=[80,10,10])[0]

            cursor.execute("""
                INSERT INTO JobPositions (EmployerID, DepartmentID, PositionName, JobDescription, JobType,
                                          Location, SalaryMin, SalaryMax, ExperienceYears, EducationLevel,
                                          Openings, MaxRounds, Deadline, Status)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
            """, (emp_id, dept_id, title, desc, job_type, loc, min_sal, max_sal, exp, edu,
                  openings, max_rounds, deadline, status))
            jid = cursor.lastrowid

            # Requirements
            for sid in random.sample(skill_ids, random.randint(1,4)):
                prof = random.choice(['Beginner','Intermediate','Advanced'])
                mandatory = random.choice([True,False])
                cursor.execute("INSERT INTO JobRequirements (PositionID, SkillID, RequiredLevel, IsMandatory) VALUES (%s,%s,%s,%s)",
                               (jid, sid, prof, mandatory))
    print("-> 48 jobs created with July 2026 deadlines.")

def create_interviews(cursor, past, today, future, interviewer_job_map):
    print(f"Creating interviews: {past} past, {today} today, {future} future per interviewer...")
    for intv_id, assigned_jobs in interviewer_job_map.items():
        pos_id = assigned_jobs[0]  # mỗi interviewer chỉ có 1 job
        cursor.execute("""
            SELECT a.ApplicationID
            FROM Applications a
            WHERE a.Status = 'Interviewing'
              AND a.PositionID = %s
              AND NOT EXISTS (SELECT 1 FROM Interviews WHERE ApplicationID = a.ApplicationID)
        """, (pos_id,))
        app_ids = [row['ApplicationID'] for row in cursor.fetchall()]
        total_needed = past + today + future
        if len(app_ids) < total_needed:
            print(f"   [!] Interviewer {intv_id} (job {pos_id}) only has {len(app_ids)} apps.")
            if not app_ids:
                continue
            chosen = random.sample(app_ids, len(app_ids))
        else:
            chosen = random.sample(app_ids, total_needed)

        for i, app_id in enumerate(chosen):
            if i < past:
                start_date = datetime(2026, 3, 1)
                end_date = datetime.now() - timedelta(days=1)
                if end_date < start_date:
                    end_date = start_date
                dt = start_date + timedelta(days=random.randint(0, (end_date - start_date).days))
                dt = dt.replace(hour=random.randint(8,18), minute=random.choice([0,15,30,45]))
            elif i < past + today:
                dt = datetime.now().replace(hour=random.randint(8,18),
                                            minute=random.choice([0,15,30,45]),
                                            second=0, microsecond=0)
            else:
                if i - past - today < 2:
                    dt = datetime.now().replace(hour=random.randint(8,18),
                                                minute=random.choice([0,15,30,45]),
                                                second=0, microsecond=0) + timedelta(days=1)
                else:
                    dt = datetime.now() + timedelta(days=random.randint(2,14),
                                                    hours=random.randint(8,17),
                                                    minutes=random.choice([0,15,30,45]))
            cursor.execute("""
                INSERT INTO Interviews (ApplicationID, InterviewerID, RoundNumber, InterviewDate, InterviewType, Location, Result, Score, IsDeleted)
                VALUES (%s,%s,1,%s,%s,'Online','Pending',NULL,FALSE)
            """, (app_id, intv_id, dt, random.choice(['Technical','HR','Online'])))

    # Cập nhật score, result, note cho past
    cursor.execute("UPDATE Interviews SET Score = FLOOR(10 + RAND() * 91) WHERE InterviewDate < NOW() AND IsDeleted = FALSE")
    cursor.execute("""
        UPDATE Interviews
        SET Result = CASE WHEN Score >= 80 THEN 'Pass' WHEN Score >= 50 THEN 'Pending' ELSE 'Fail' END
        WHERE InterviewDate < NOW() AND IsDeleted = FALSE
    """)
    cursor.execute("""
        UPDATE Interviews
        SET Note = CONCAT(
            'Technical Skills: ', FLOOR(4+RAND()*7), '/10\n',
            'Communication: ', FLOOR(4+RAND()*7), '/10\n',
            'Strengths: ', ELT(FLOOR(1+RAND()*3), 'Good technical background', 'Strong communication', 'Creative problem-solving'), '\n',
            'Weaknesses: ', ELT(FLOOR(1+RAND()*3), 'Needs more experience', 'Weak in time management', 'Needs improvement in teamwork')
        )
        WHERE InterviewDate < NOW() AND Score IS NOT NULL AND IsDeleted = FALSE
    """)
    cursor.execute("UPDATE Interviews SET Result = 'Pending', Score = NULL WHERE InterviewDate >= NOW() AND IsDeleted = FALSE")
    print("-> Interview scores, results, and notes updated.")

def seed_applications_and_workflow(cursor, conn):
    print("Seeding Applications & Workflows...")
    cursor.execute("SELECT CandidateID FROM Candidates")
    cand_ids = [row['CandidateID'] for row in cursor.fetchall()]
    cursor.execute("SELECT PositionID, EmployerID FROM JobPositions WHERE Status = 'Open'")
    jobs = cursor.fetchall()

    # Nhóm job theo employer
    jobs_by_emp = {}
    for job in jobs:
        jobs_by_emp.setdefault(job['EmployerID'], []).append(job['PositionID'])

    # 1. Tạo applications (mỗi candidate 1 job/công ty)
    app_count = 0
    for cid in cand_ids:
        for emp_id, pos_ids in jobs_by_emp.items():
            chosen_pos = random.choice(pos_ids)
            app_date = datetime(2026, random.randint(3, 5), random.randint(1, 28))
            cover = fake_en.paragraph(nb_sentences=3)
            cursor.execute("""
                INSERT IGNORE INTO Applications (CandidateID, PositionID, ApplicationDate, Status, CoverLetter)
                VALUES (%s,%s,%s,'Applied',%s)
            """, (cid, chosen_pos, app_date, cover))
            if cursor.rowcount > 0:
                app_count += 1
    conn.commit()
    print(f"-> Inserted {app_count} applications.")

    # 2. Chuyển trạng thái hàng loạt
    cursor.execute("SELECT ApplicationID FROM Applications")
    all_apps = [row['ApplicationID'] for row in cursor.fetchall()]
    # Screening 90%
    screening = random.sample(all_apps, int(len(all_apps) * 0.9))
    for app_id in screening:
        cursor.execute("UPDATE Applications SET Status = 'Screening' WHERE ApplicationID = %s", (app_id,))
    conn.commit()
    # Interviewing 90% của Screening
    interviewing = random.sample(screening, int(len(screening) * 0.9))
    for app_id in interviewing:
        cursor.execute("UPDATE Applications SET Status = 'Interviewing' WHERE ApplicationID = %s", (app_id,))
    conn.commit()
    # Rejected ~5% những app còn lại ở Applied/Screening
    cursor.execute("SELECT ApplicationID FROM Applications WHERE Status IN ('Applied','Screening')")
    rejected_pool = [row['ApplicationID'] for row in cursor.fetchall()]
    if rejected_pool:
        rejected = random.sample(rejected_pool, min(int(len(all_apps)*0.05), len(rejected_pool)))
        for app_id in rejected:
            cursor.execute("UPDATE Applications SET Status = 'Rejected' WHERE ApplicationID = %s", (app_id,))
        conn.commit()
        print(f"-> Rejected {len(rejected)} (early stage).")

    # 3. ScreeningNote
    some_apps = random.sample(all_apps, min(30, len(all_apps)))
    notes_pool = [
        "Ứng viên có kinh nghiệm phù hợp, cần phỏng vấn thêm.",
        "CV ấn tượng, kỹ năng tốt.",
        "Cần kiểm tra lại bằng cấp.",
        "Chưa có nhiều kinh nghiệm nhưng có tiềm năng.",
        "Ứng viên nhiệt tình, giao tiếp tốt."
    ]
    for app_id in random.sample(some_apps, 20):
        cursor.execute("UPDATE Applications SET ScreeningNote = %s WHERE ApplicationID = %s",
                       (random.choice(notes_pool), app_id))
    conn.commit()

    # 4. Gán interviewer – job và tạo phỏng vấn
    cursor.execute("""
        SELECT i.InterviewerID, i.EmployerID, jp.PositionID
        FROM Interviewers i
        JOIN (
            SELECT PositionID, EmployerID,
                   ROW_NUMBER() OVER (PARTITION BY EmployerID ORDER BY PositionID) AS rn
            FROM JobPositions
        ) jp ON i.EmployerID = jp.EmployerID
        JOIN (
            SELECT InterviewerID, EmployerID,
                   ROW_NUMBER() OVER (PARTITION BY EmployerID ORDER BY InterviewerID) AS rn
            FROM Interviewers
        ) i2 ON i.InterviewerID = i2.InterviewerID AND jp.rn = i2.rn
    """)
    interviewer_job_map = {}
    for row in cursor.fetchall():
        interviewer_job_map[row['InterviewerID']] = [row['PositionID']]

    create_interviews(cursor, PAST_INTERVIEWS, TODAY_INTERVIEWS, FUTURE_INTERVIEWS, interviewer_job_map)
    conn.commit()

    # 5. Xử lý kết quả phỏng vấn
    print("Processing interview results...")
    # Pass -> Offered
    cursor.execute("""
        SELECT a.ApplicationID
        FROM Applications a
        JOIN Interviews i ON a.ApplicationID = i.ApplicationID
        WHERE i.Result = 'Pass' AND i.IsDeleted = FALSE
          AND a.Status = 'Interviewing'
    """)
    passed_apps = [row['ApplicationID'] for row in cursor.fetchall()]
    if passed_apps:
        offer_from_pass = random.sample(passed_apps, int(len(passed_apps) * 0.7))
        for app_id in offer_from_pass:
            cursor.execute("UPDATE Applications SET Status = 'Offered' WHERE ApplicationID = %s", (app_id,))
        conn.commit()
        print(f"  -> Offered {len(offer_from_pass)} applications (from Pass).")

    # Fail -> Rejected
    cursor.execute("""
        SELECT a.ApplicationID
        FROM Applications a
        JOIN Interviews i ON a.ApplicationID = i.ApplicationID
        WHERE i.Result = 'Fail' AND i.IsDeleted = FALSE
          AND a.Status = 'Interviewing'
    """)
    failed_apps = [row['ApplicationID'] for row in cursor.fetchall()]
    if failed_apps:
        reject_from_fail = random.sample(failed_apps, int(len(failed_apps) * 0.8))
        for app_id in reject_from_fail:
            cursor.execute("UPDATE Applications SET Status = 'Rejected' WHERE ApplicationID = %s", (app_id,))
        conn.commit()
        print(f"  -> Rejected {len(reject_from_fail)} applications (from Fail).")

    # Thêm Rejected từ nhóm chưa phỏng vấn
    cursor.execute("SELECT ApplicationID FROM Applications WHERE Status IN ('Applied','Screening')")
    add_reject = [row['ApplicationID'] for row in cursor.fetchall()]
    if add_reject:
        extra_reject = random.sample(add_reject, min(len(add_reject), int(len(all_apps) * 0.1)))
        for app_id in extra_reject:
            cursor.execute("UPDATE Applications SET Status = 'Rejected' WHERE ApplicationID = %s", (app_id,))
        conn.commit()
        print(f"  -> Added {len(extra_reject)} more Rejected (non-interview).")

    # 6. InterviewPanel & Notifications
    cursor.execute("SELECT InterviewID, InterviewerID FROM Interviews WHERE InterviewID NOT IN (SELECT InterviewID FROM InterviewPanel)")
    for iv in cursor.fetchall():
        cursor.execute("INSERT INTO InterviewPanel (InterviewID, InterviewerID, Role) VALUES (%s,%s,'Lead')",
                       (iv['InterviewID'], iv['InterviewerID']))
    conn.commit()

    cursor.execute("DELETE FROM InterviewerNotifications")
    cursor.execute("""
        INSERT INTO InterviewerNotifications (InterviewerID, Message, RelatedID)
        SELECT ip.InterviewerID,
               CONCAT('Phỏng vấn ', c.CandidateName, ' cho vị trí ', p.PositionName, ' vào lúc ', DATE_FORMAT(i.InterviewDate, '%H:%i %d/%m/%Y')),
               i.InterviewID
        FROM InterviewPanel ip
        JOIN Interviews i ON ip.InterviewID = i.InterviewID AND i.InterviewDate >= NOW() AND i.IsDeleted = FALSE
        JOIN Applications a ON i.ApplicationID = a.ApplicationID
        JOIN Candidates c ON a.CandidateID = c.CandidateID
        JOIN JobPositions p ON a.PositionID = p.PositionID
    """)
    conn.commit()
    print("-> Created interviewer notifications.")

    # 7. Đảm bảo 20 candidate đầu có đủ 6 trạng thái
    for cid in range(1, 21):
        statuses_needed = ['Applied','Screening','Interviewing','Offered','Accepted','Rejected']
        cursor.execute("SELECT ApplicationID, Status FROM Applications WHERE CandidateID = %s", (cid,))
        apps = cursor.fetchall()
        existing = {row['Status'] for row in apps}
        for st in statuses_needed:
            if st not in existing:
                cursor.execute("""
                    SELECT PositionID FROM JobPositions WHERE Status='Open' 
                    AND PositionID NOT IN (SELECT PositionID FROM Applications WHERE CandidateID = %s)
                    LIMIT 1
                """, (cid,))
                job = cursor.fetchone()
                if job:
                    app_date = datetime(2026, random.randint(3, 5), random.randint(1, 28))
                    cover = fake_en.paragraph(nb_sentences=3)
                    cursor.execute("""
                        INSERT INTO Applications (CandidateID, PositionID, ApplicationDate, Status, CoverLetter)
                        VALUES (%s,%s,%s,%s,%s)
                    """, (cid, job['PositionID'], app_date, st, cover))
                    existing.add(st)
                else:
                    if apps:
                        app_to_update = random.choice(apps)
                        cursor.execute("UPDATE Applications SET Status = %s WHERE ApplicationID = %s",
                                       (st, app_to_update['ApplicationID']))
                        existing.add(st)
        conn.commit()
    print("-> Candidates 1-20 have all 6 statuses.")

    # 8. Tăng cường thêm Offered (optional)
    cursor.execute("SELECT ApplicationID FROM Applications WHERE Status = 'Interviewing'")
    interviewing_ids = [row['ApplicationID'] for row in cursor.fetchall()]
    if interviewing_ids:
        to_offer = random.sample(interviewing_ids, min(60, len(interviewing_ids)))
        for app_id in to_offer:
            cursor.execute("UPDATE Applications SET Status = 'Offered' WHERE ApplicationID = %s", (app_id,))
        conn.commit()
        print(f"-> Additional {len(to_offer)} applications moved to Offered.")

    # 9. 20 applications hôm nay
    cursor.execute("SELECT ApplicationID FROM Applications WHERE IsDeleted = FALSE ORDER BY RAND() LIMIT 20")
    for app_id in [row['ApplicationID'] for row in cursor.fetchall()]:
        cursor.execute("UPDATE Applications SET ApplicationDate = CURDATE() WHERE ApplicationID = %s", (app_id,))
    conn.commit()

    # 10. Tạo JobOffers
    cursor.execute("SELECT ApplicationID, PositionID FROM Applications WHERE Status = 'Offered'")
    offered_apps = cursor.fetchall()
    offer_count = 0
    for app in offered_apps:
        cursor.execute("SELECT SalaryMin, SalaryMax FROM JobPositions WHERE PositionID = %s", (app['PositionID'],))
        sal = cursor.fetchone()
        if sal:
            basic = float(sal['SalaryMin']) + (float(sal['SalaryMax']) - float(sal['SalaryMin'])) * random.random()
            offer_date = datetime.now() - timedelta(days=random.randint(0,5))
            cursor.execute("""
                INSERT INTO JobOffers (ApplicationID, BasicSalary, OfferDate, ValidUntil, Status)
                VALUES (%s,%s,%s,%s,'Pending')
            """, (app['ApplicationID'], basic, offer_date, offer_date + timedelta(days=7)))
            offer_count += 1
    conn.commit()
    print(f"-> Created {offer_count} Job Offers.")

    # 11. Candidate Responses (Accept / Decline)
    print("Simulating candidate responses...")
    # Lấy tất cả các offer Pending kèm ApplicationID
    cursor.execute("""
        SELECT jo.OfferID, jo.ApplicationID, a.Status
        FROM JobOffers jo
        JOIN Applications a ON jo.ApplicationID = a.ApplicationID
        WHERE jo.Status = 'Pending' AND a.Status = 'Offered'
    """)
    pending_offers = cursor.fetchall()
    if pending_offers:
        accept = random.sample(pending_offers, int(len(pending_offers) * 0.6))
        for off in accept:
            cursor.execute("UPDATE JobOffers SET Status = 'Accepted' WHERE OfferID = %s", (off['OfferID'],))
            cursor.execute("UPDATE Applications SET Status = 'Accepted' WHERE ApplicationID = %s", (off['ApplicationID'],))
        conn.commit()
        print(f"  -> Accepted: {len(accept)}")

        # Decline: chọn từ số Pending còn lại
        remaining_pending = [off for off in pending_offers if off not in accept]
        if remaining_pending:
            decline = random.sample(remaining_pending, int(len(remaining_pending) * 0.5))
            for off in decline:
                cursor.execute("UPDATE JobOffers SET Status = 'Declined' WHERE OfferID = %s", (off['OfferID'],))
                cursor.execute("UPDATE Applications SET Status = 'Withdrawn' WHERE ApplicationID = %s", (off['ApplicationID'],))
            conn.commit()
            print(f"  -> Declined: {len(decline)}")

    # 12. Đảm bảo mỗi candidate có ít nhất 1 offer
    print("Ensuring every candidate has at least one offer...")
    cursor.execute("""
        SELECT c.CandidateID FROM Candidates c
        WHERE c.CandidateID NOT IN (
            SELECT DISTINCT a.CandidateID FROM Applications a
            JOIN JobOffers jo ON a.ApplicationID = jo.ApplicationID
        )
    """)
    missing = cursor.fetchall()
    for cand in missing:
        cid = cand['CandidateID']
        cursor.execute("""
            SELECT a.ApplicationID, a.PositionID FROM Applications a
            LEFT JOIN JobOffers jo ON a.ApplicationID = jo.ApplicationID
            WHERE a.CandidateID = %s AND jo.OfferID IS NULL
            LIMIT 1
        """, (cid,))
        app = cursor.fetchone()
        if not app:
            cursor.execute("SELECT PositionID FROM JobPositions WHERE Status='Open' LIMIT 1")
            job = cursor.fetchone()
            if job:
                cursor.execute("""
                    INSERT INTO Applications (CandidateID, PositionID, ApplicationDate, Status, CoverLetter)
                    VALUES (%s,%s,%s,'Offered','Auto-generated offer')
                """, (cid, job['PositionID'], datetime.now() - timedelta(days=7)))
                app_id = cursor.lastrowid
                pos_id = job['PositionID']
        else:
            app_id = app['ApplicationID']
            pos_id = app['PositionID']
            cursor.execute("UPDATE Applications SET Status = 'Offered' WHERE ApplicationID = %s", (app_id,))
        cursor.execute("SELECT SalaryMin, SalaryMax FROM JobPositions WHERE PositionID = %s", (pos_id,))
        sal = cursor.fetchone()
        if sal:
            basic = float(sal['SalaryMin']) + (float(sal['SalaryMax']) - float(sal['SalaryMin'])) * random.random()
            cursor.execute("""
                INSERT INTO JobOffers (ApplicationID, BasicSalary, OfferDate, ValidUntil, Status)
                VALUES (%s,%s,%s,%s,'Pending')
            """, (app_id, basic, datetime.now() - timedelta(days=random.randint(0,5)), datetime.now() + timedelta(days=7)))
    conn.commit()
    print("-> All candidates have at least one offer.")

    # 13. Saved Jobs
    save_count = 0
    for cid in cand_ids:
        for _ in range(random.randint(0,5)):
            job = random.choice(jobs)
            try:
                cursor.execute("INSERT IGNORE INTO SavedJobs (CandidateID, PositionID) VALUES (%s,%s)",
                               (cid, job['PositionID']))
                save_count += cursor.rowcount
            except Exception:
                pass
    conn.commit()
    print(f"-> Created {save_count} Saved Jobs.")


# ------------------------------
# MAIN
# ------------------------------
def main():
    conn = connect_db()
    cursor = conn.cursor(dictionary=True)
    try:
        truncate_tables(cursor)
        conn.commit()
        seed_base_data(cursor)
        seed_candidates(cursor)
        seed_jobs(cursor)
        conn.commit()
        seed_applications_and_workflow(cursor, conn)
        print("\n=========================================")
        print("SUCCESS: Database seeded successfully!")
        print("=========================================")
        print("Login credentials (password: 'hashed_demo_password_123'):")
        print(f"- Candidates : cand1@example.com ... cand{TOTAL_CANDIDATES}@example.com")
        print("- HR Managers: hr_1@demo.com ... hr_12@demo.com")
        print("- Admin      : admin@demo.com")
        print("- Analyst    : analyst@demo.com")
        print("- Interviewers (one per job, fixed):")
        for emp_id in range(1, 13):
            for i in range(1, 5):
                print(f"    Company {emp_id} Job {i}: intv_{emp_id}_{i}@demo.com")
        print(f"- Each interviewer: {PAST_INTERVIEWS} past, {TODAY_INTERVIEWS} today, {FUTURE_INTERVIEWS} future")
    except Exception as e:
        conn.rollback()
        import traceback
        traceback.print_exc()
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    main()