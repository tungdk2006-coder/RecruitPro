from flask import Blueprint, render_template, session, request, redirect, url_for, flash, jsonify
from models.db import call_procedure_out, query_db, get_db_connection
from utils.decorators import login_required
from datetime import datetime, date

hr_bp = Blueprint('hr', __name__)

# ============================================================
# DASHBOARD
# ============================================================
@hr_bp.route('/dashboard')
@login_required('HR')
def dashboard():
    emp_id = session['employer_id']
    try:
        # --- Thống kê funnel ---
        funnel_data = query_db("""
            SELECT 
                SUM(v.TotalApplied) as Applied,
                SUM(v.Screened) as Screened,
                SUM(v.Interviewed) as Interviewed,
                SUM(v.OfferedCount) as Offered,
                SUM(v.Hired) as Hired
            FROM View_StageConversionRates v
            JOIN JobPositions jp ON v.PositionID = jp.PositionID
            WHERE jp.EmployerID = %s AND jp.IsDeleted = FALSE
        """, (emp_id,), one=True)
        
        # --- Stats cards ---
        stats = {}
        total_open = query_db("SELECT COUNT(*) as count FROM JobPositions WHERE EmployerID = %s AND Status = 'Open' AND IsDeleted = FALSE", (emp_id,), one=True)
        stats['open_positions'] = total_open['count'] if total_open else 0
        
        total_apps = query_db("""
            SELECT COUNT(*) as count FROM Applications a 
            JOIN JobPositions jp ON a.PositionID = jp.PositionID 
            WHERE jp.EmployerID = %s AND a.IsDeleted = FALSE
        """, (emp_id,), one=True)
        stats['total_apps'] = total_apps['count'] if total_apps else 0
        
        total_offers = query_db("""
            SELECT COUNT(*) as count FROM JobOffers jo
            JOIN Applications a ON jo.ApplicationID = a.ApplicationID
            JOIN JobPositions jp ON a.PositionID = jp.PositionID
            WHERE jp.EmployerID = %s
        """, (emp_id,), one=True)
        stats['total_offers'] = total_offers['count'] if total_offers else 0

        # --- Dữ liệu cho Bảng tổng quan hôm nay ---
        today_new_apps = query_db("""
            SELECT a.ApplicationID, c.CandidateID, c.CandidateName, jp.PositionName, a.ApplicationDate
            FROM Applications a
            JOIN Candidates c ON a.CandidateID = c.CandidateID
            JOIN JobPositions jp ON a.PositionID = jp.PositionID
            WHERE jp.EmployerID = %s AND a.IsDeleted = FALSE
              AND DATE(a.ApplicationDate) = CURDATE()
            ORDER BY a.ApplicationDate DESC
            LIMIT 5
        """, (emp_id,))
        
        today_interviews = query_db("""
            SELECT iv.InterviewID, iv.InterviewDate, c.CandidateName, jp.PositionName, iv.InterviewType, iv.Location
            FROM Interviews iv
            JOIN Applications a ON iv.ApplicationID = a.ApplicationID
            JOIN JobPositions jp ON a.PositionID = jp.PositionID
            JOIN Candidates c ON a.CandidateID = c.CandidateID
            WHERE jp.EmployerID = %s AND iv.IsDeleted = FALSE
              AND DATE(iv.InterviewDate) BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 1 DAY)
            ORDER BY iv.InterviewDate ASC
        """, (emp_id,))
        
        expiring_offers = query_db("""
            SELECT jo.OfferID, jo.BasicSalary, jo.ValidUntil, c.CandidateName, jp.PositionName
            FROM JobOffers jo
            JOIN Applications a ON jo.ApplicationID = a.ApplicationID
            JOIN Candidates c ON a.CandidateID = c.CandidateID
            JOIN JobPositions jp ON a.PositionID = jp.PositionID
            WHERE jp.EmployerID = %s AND jo.Status = 'Pending'
              AND jo.ValidUntil BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)
            ORDER BY jo.ValidUntil ASC
        """, (emp_id,))
        
        return render_template('hr/dashboard.html',
                               stats=stats,
                               today_new_apps=today_new_apps,
                               today_interviews=today_interviews,
                               expiring_offers=expiring_offers,
                               current_date=date.today())  
    except Exception as e:
        import traceback
        traceback.print_exc()
        flash("Error loading dashboard", "danger")
        return redirect(url_for('home'))


# ============================================================
# MANAGE JOBS
# ============================================================
@hr_bp.route('/jobs')
@login_required('HR')
def manage_jobs():
    emp_id = session['employer_id']
    try:
        jobs = query_db("SELECT * FROM JobPositions WHERE EmployerID = %s AND IsDeleted = FALSE ORDER BY PositionID DESC", (emp_id,))
        return render_template('hr/manage_jobs.html', jobs=jobs)
    except Exception as e:
        flash("Error loading jobs", "danger")
        return redirect(url_for('hr.dashboard'))

@hr_bp.route('/jobs/create', methods=['GET', 'POST'])
@login_required('HR')
def create_job():
    emp_id = session['employer_id']
    if request.method == 'POST':
        dept_id = request.form.get('department_id')
        title = request.form.get('position_name')
        job_type = request.form.get('job_type')
        salary_min = request.form.get('salary_min')
        salary_max = request.form.get('salary_max')
        exp = request.form.get('experience_years')
        edu = request.form.get('education_level')
        loc = request.form.get('location')
        openings = request.form.get('openings')
        rounds = request.form.get('max_rounds')
        deadline = request.form.get('deadline')
        status = request.form.get('status')
        
        skill_ids = request.form.getlist('skill_id[]')
        levels = request.form.getlist('required_level[]')
        
        try:
            _, out_args = call_procedure_out('sp_CreateJob', (
                emp_id, dept_id, title, job_type, salary_min, salary_max,
                exp, edu, loc, openings, rounds, deadline, status, ''
            ))
            
            result_val = str(out_args[13])
            if result_val.isdigit():
                new_job_id = int(result_val)
                
                for i in range(len(skill_ids)):
                    sid = skill_ids[i]
                    if sid:
                        level = levels[i] if i < len(levels) else 'Beginner'
                        is_mandatory = 1 if f"mandatory_{sid}" in request.form else 0
                        call_procedure_out('sp_AddJobRequirement', (new_job_id, sid, level, is_mandatory))
                
                flash('Job created successfully!', 'success')
                return redirect(url_for('hr.manage_jobs'))
            else:
                flash(f"Error creating job: {result_val}", "danger")
        except Exception as e:
            flash(f"Database error: {str(e)}", "danger")
    
    # GET request
    departments = query_db("SELECT * FROM Departments WHERE EmployerID = %s", (emp_id,))
    skills = query_db("SELECT * FROM Skills")
    locations = query_db("SELECT DISTINCT Location FROM JobPositions WHERE IsDeleted = FALSE AND Location IS NOT NULL ORDER BY Location")
    return render_template('hr/post_job.html', departments=departments, skills=skills, locations=locations)

@hr_bp.route('/jobs/<int:id>/edit', methods=['GET', 'POST'])
@login_required('HR')
def edit_job(id):
    emp_id = session['employer_id']
    if request.method == 'POST':
        dept_id = request.form.get('department_id')
        title = request.form.get('position_name')
        job_type = request.form.get('job_type')
        salary_min = request.form.get('salary_min')
        salary_max = request.form.get('salary_max')
        exp = request.form.get('experience_years')
        edu = request.form.get('education_level')
        loc = request.form.get('location')
        openings = request.form.get('openings')
        rounds = request.form.get('max_rounds')
        deadline = request.form.get('deadline')
        status = request.form.get('status')
        
        try:
            _, out = call_procedure_out('sp_UpdateJob', (
                id, emp_id, dept_id, title, job_type, salary_min, salary_max,
                exp, edu, loc, openings, rounds, deadline, status, ''
            ))
            flash(out[14], "success" if "success" in out[14].lower() else "danger")
            return redirect(url_for('hr.manage_jobs'))
        except Exception as e:
            flash("Error updating job.", "danger")
            
    job = query_db("SELECT * FROM JobPositions WHERE PositionID = %s AND EmployerID = %s", (id, emp_id), one=True)
    if not job:
        flash("Job not found.", "danger")
        return redirect(url_for('hr.manage_jobs'))
        
    departments = query_db("SELECT * FROM Departments WHERE EmployerID = %s", (emp_id,))
    return render_template('hr/edit_job.html', job=job, departments=departments)

@hr_bp.route('/positions/<int:id>/delete', methods=['POST'])
@login_required('HR')
def delete_position(id):
    emp_id = session['employer_id']
    try:
        job = query_db("SELECT 1 FROM JobPositions WHERE PositionID = %s AND EmployerID = %s", (id, emp_id), one=True)
        if job:
            query_db("UPDATE JobPositions SET IsDeleted = TRUE WHERE PositionID = %s", (id,))
            flash("Position deleted.", "success")
        else:
            flash("Unauthorized.", "danger")
    except:
        flash("Error deleting position.", "danger")
    return redirect(url_for('hr.manage_jobs'))

# ============================================================
# APPLICATIONS & CANDIDATES
# ============================================================
@hr_bp.route('/applications')
@login_required('HR')
def applications():
    emp_id = session['employer_id']
    search = request.args.get('search', '')
    status = request.args.get('status', '')
    position_id = request.args.get('position_id', '')
    page = request.args.get('page', 1, type=int)
    per_page = 20

    count_query = """
        SELECT COUNT(*) as cnt
        FROM Applications a
        JOIN JobPositions jp ON a.PositionID = jp.PositionID
        JOIN Candidates c ON a.CandidateID = c.CandidateID
        WHERE jp.EmployerID = %s AND a.IsDeleted = FALSE
    """
    params = [emp_id]
    if search:
        count_query += " AND c.CandidateName LIKE %s"
        params.append(f"%{search}%")
    if status:
        count_query += " AND a.Status = %s"
        params.append(status)
    if position_id:
        count_query += " AND a.PositionID = %s"
        params.append(position_id)
    total = query_db(count_query, params, one=True)['cnt']

    data_query = """
        SELECT a.*, c.CandidateName, jp.PositionName, c.ResumeURL, a.ScreeningNote,
               i.InterviewID, i.InterviewDate, i.RoundNumber, i.InterviewType, i.Location as InterviewLocation,
               ivr.InterviewerID as AssignedInterviewerID, ivr.FullName as InterviewerName
        FROM Applications a
        JOIN JobPositions jp ON a.PositionID = jp.PositionID
        JOIN Candidates c ON a.CandidateID = c.CandidateID
        LEFT JOIN Interviews i ON a.ApplicationID = i.ApplicationID AND i.IsDeleted = FALSE
        LEFT JOIN InterviewPanel ip ON i.InterviewID = ip.InterviewID AND ip.Role = 'Lead'
        LEFT JOIN Interviewers ivr ON ip.InterviewerID = ivr.InterviewerID
        WHERE jp.EmployerID = %s AND a.IsDeleted = FALSE
    """
    data_params = [emp_id]
    if search:
        data_query += " AND c.CandidateName LIKE %s"
        data_params.append(f"%{search}%")
    if status:
        data_query += " AND a.Status = %s"
        data_params.append(status)
    if position_id:
        data_query += " AND a.PositionID = %s"
        data_params.append(position_id)
    data_query += " ORDER BY a.ApplicationDate DESC LIMIT %s OFFSET %s"
    apps = query_db(data_query, data_params + [per_page, (page - 1) * per_page])

    interviewers = query_db("SELECT * FROM Interviewers WHERE EmployerID = %s AND IsDeleted = FALSE", (emp_id,))
    open_positions = query_db("SELECT PositionID, PositionName FROM JobPositions WHERE EmployerID = %s AND IsDeleted = FALSE", (emp_id,))

    total_pages = (total + per_page - 1) // per_page

    return render_template('hr/applications.html',
                           applications=apps,
                           interviewers=interviewers,
                           open_positions=open_positions,
                           page=page,
                           total_pages=total_pages)

@hr_bp.route('/applications/<int:id>/status', methods=['POST'])
@login_required('HR')
def update_app_status(id):
    emp_id = session['employer_id']
    new_status = request.form.get('status')
    try:
        _, out = call_procedure_out('sp_UpdateApplicationStatus', (id, emp_id, new_status, ''))
        flash(out[3], "success" if "success" in out[3].lower() else "danger")
    except Exception as e:
        flash("Error updating status.", "danger")
    return redirect(url_for('hr.applications'))

@hr_bp.route('/applications/<int:id>/offer', methods=['POST'])
@login_required('HR')
def create_offer(id):
    emp_id = session['employer_id']
    salary = request.form.get('salary_offered')
    deadline = request.form.get('response_deadline')
    note = request.form.get('offer_details')
    
    try:
        today = date.today().strftime('%Y-%m-%d')
        _, out = call_procedure_out('sp_CreateOffer', (id, emp_id, salary, today, deadline, note, ''))
        flash(out[6], "success" if "success" in out[6].lower() else "danger")
    except Exception as e:
        flash("Error creating offer.", "danger")
    return redirect(url_for('hr.applications'))

@hr_bp.route('/applications/<int:id>/note', methods=['POST'])
@login_required('HR')
def update_note(id):
    emp_id = session['employer_id']
    note = request.form.get('note', '')
    try:
        valid = query_db("""
            SELECT 1 FROM Applications a
            JOIN JobPositions jp ON a.PositionID = jp.PositionID
            WHERE a.ApplicationID = %s AND jp.EmployerID = %s
        """, (id, emp_id), one=True)
        if not valid:
            flash("Unauthorized.", "danger")
        else:
            query_db("UPDATE Applications SET ScreeningNote = %s WHERE ApplicationID = %s", (note, id))
            flash("Note updated.", "success")
    except Exception as e:
        flash("Error updating note.", "danger")
    return redirect(url_for('hr.applications'))

@hr_bp.route('/candidates/<int:id>')
@login_required('HR')
def candidate_detail(id):
    candidate = query_db("SELECT * FROM Candidates WHERE CandidateID = %s", (id,), one=True)
    skills = query_db("""
        SELECT s.SkillName, cs.ProficiencyLevel
        FROM CandidateSkills cs
        JOIN Skills s ON cs.SkillID = s.SkillID
        WHERE cs.CandidateID = %s
    """, (id,))
    return render_template('hr/candidate_detail.html', candidate=candidate, skills=skills)

# ============================================================
# INTERVIEW SCHEDULING & CALENDAR
# ============================================================
@hr_bp.route('/schedule_interview', methods=['POST'])
@login_required('HR')
def schedule_interview():
    application_id = request.form.get('application_id')
    interviewer_id = request.form.get('interviewer_id')
    interview_date_str = request.form.get('interview_date')
    round_number = request.form.get('round_number')
    interview_type = request.form.get('interview_type')
    location = request.form.get('location')

    if not all([application_id, interviewer_id, interview_date_str, round_number, interview_type, location]):
        flash("All fields are required.", 'danger')
        return redirect(url_for('hr.applications'))

    try:
        dt = datetime.strptime(interview_date_str, '%Y-%m-%dT%H:%M')
        interview_date = dt.strftime('%Y-%m-%d %H:%M:%S')
    except ValueError:
        flash("Invalid date/time format.", 'danger')
        return redirect(url_for('hr.applications'))

    conn = None
    cursor = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        conn.start_transaction()

        cursor.execute("SELECT 1 FROM Applications a JOIN JobPositions jp ON a.PositionID = jp.PositionID WHERE a.ApplicationID = %s AND jp.EmployerID = %s AND a.IsDeleted = FALSE", (application_id, session['employer_id']))
        if cursor.fetchone() is None:
            raise Exception("Application not found or does not belong to your company.")

        cursor.execute("""
            INSERT INTO Interviews (ApplicationID, InterviewerID, InterviewDate, RoundNumber, InterviewType, Location)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (application_id, interviewer_id, interview_date, round_number, interview_type, location))
        new_interview_id = cursor.lastrowid

        cursor.execute("""
            INSERT INTO InterviewPanel (InterviewID, InterviewerID, Role)
            VALUES (%s, %s, 'Lead')
        """, (new_interview_id, interviewer_id))

        cursor.execute("""
            UPDATE Applications SET Status = 'Interviewing' WHERE ApplicationID = %s AND IsDeleted = FALSE
        """, (application_id,))

        conn.commit()
        flash(f"Interview scheduled successfully! ID: {new_interview_id}", 'success')

    except Exception as e:
        if conn:
            conn.rollback()
        import traceback
        traceback.print_exc()
        flash(f"Error scheduling interview: {str(e)}", 'danger')
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

    return redirect(url_for('hr.applications'))

@hr_bp.route('/update_schedule/<int:interview_id>', methods=['POST'])
@login_required('HR')
def update_schedule(interview_id):
    interviewer_id = request.form.get('interviewer_id')
    interview_date_str = request.form.get('interview_date')
    round_number = request.form.get('round_number')
    interview_type = request.form.get('interview_type')
    location = request.form.get('location')
    
    try:
        dt = datetime.strptime(interview_date_str, '%Y-%m-%dT%H:%M')
        interview_date = dt.strftime('%Y-%m-%d %H:%M:%S')
    except ValueError:
        flash("Invalid date/time format.", 'danger')
        return redirect(url_for('hr.applications'))
    
    try:
        query_db("""
            UPDATE Interviews 
            SET InterviewerID = %s, InterviewDate = %s, RoundNumber = %s, InterviewType = %s, Location = %s
            WHERE InterviewID = %s
        """, (interviewer_id, interview_date, round_number, interview_type, location, interview_id))
        
        query_db("DELETE FROM InterviewPanel WHERE InterviewID = %s", (interview_id,))
        query_db("INSERT INTO InterviewPanel (InterviewID, InterviewerID, Role) VALUES (%s, %s, 'Lead')", (interview_id, interviewer_id))
        
        flash("Interview updated successfully.", "success")
    except Exception as e:
        flash("Error updating interview.", "danger")
    
    return redirect(url_for('hr.applications'))

@hr_bp.route('/interviews')
@login_required('HR')
def hr_interviews():
    emp_id = session['employer_id']
    
    # Lấy tham số filter
    month = request.args.get('month', '')
    candidate = request.args.get('candidate', '').strip()
    position = request.args.get('position', '').strip()
    interview_type = request.args.get('type', '')
    page = request.args.get('page', 1, type=int)
    per_page = 15

    base_query = """
        FROM Interviews iv
        JOIN Applications a ON iv.ApplicationID = a.ApplicationID
        JOIN JobPositions jp ON a.PositionID = jp.PositionID
        JOIN Candidates c ON a.CandidateID = c.CandidateID
        LEFT JOIN Interviewers ivr ON iv.InterviewerID = ivr.InterviewerID
        WHERE jp.EmployerID = %s AND iv.IsDeleted = FALSE
    """
    params = [emp_id]

    if month:
        base_query += " AND MONTH(iv.InterviewDate) = %s"
        params.append(int(month))
    if candidate:
        base_query += " AND c.CandidateName LIKE %s"
        params.append(f"%{candidate}%")
    if position:
        base_query += " AND jp.PositionName LIKE %s"
        params.append(f"%{position}%")
    if interview_type:
        base_query += " AND iv.InterviewType = %s"
        params.append(interview_type)

    # Đếm tổng
    total = query_db("SELECT COUNT(*) as cnt " + base_query, params, one=True)['cnt']

    # Lấy dữ liệu, sắp xếp mới nhất → cũ nhất
    data_query = """
        SELECT iv.InterviewID, iv.InterviewDate, iv.RoundNumber, iv.InterviewType,
               iv.Location, c.CandidateName, jp.PositionName, ivr.FullName as InterviewerName
    """ + base_query + " ORDER BY iv.InterviewDate DESC LIMIT %s OFFSET %s"
    interviews = query_db(data_query, params + [per_page, (page - 1) * per_page])

    total_pages = (total + per_page - 1) // per_page

    months = list(range(1, 13))
    interview_types = ['Phone', 'Online', 'In-person', 'Technical', 'HR']

    return render_template('hr/interviews.html',
                           interviews=interviews,
                           months=months,
                           interview_types=interview_types,
                           page=page,
                           total_pages=total_pages,
                           current_month=month,
                           current_candidate=candidate,
                           current_position=position,
                           current_type=interview_type)

@hr_bp.route('/review-interviews')
@login_required('HR')
def review_interviews():
    emp_id = session['employer_id']
    page = request.args.get('page', 1, type=int)
    per_page = 10  # số dòng mỗi trang

    # Đếm tổng số cuộc phỏng vấn hoàn thành
    total = query_db("""
        SELECT COUNT(*) as cnt
        FROM Interviews i
        JOIN Applications a ON i.ApplicationID = a.ApplicationID
        JOIN JobPositions jp ON a.PositionID = jp.PositionID
        WHERE jp.EmployerID = %s 
          AND i.IsDeleted = FALSE
          AND i.Score IS NOT NULL 
          AND i.Note IS NOT NULL
    """, (emp_id,), one=True)['cnt']

    total_pages = (total + per_page - 1) // per_page

    # Lấy dữ liệu cho trang hiện tại
    completed_interviews = query_db("""
        SELECT 
            i.InterviewID, i.InterviewDate, i.RoundNumber, i.Result, i.Score, i.Note,
            c.CandidateName, jp.PositionName, a.ApplicationID, a.Status AS AppStatus,
            ivr.FullName as InterviewerName
        FROM Interviews i
        JOIN Applications a ON i.ApplicationID = a.ApplicationID
        JOIN JobPositions jp ON a.PositionID = jp.PositionID
        JOIN Candidates c ON a.CandidateID = c.CandidateID
        LEFT JOIN Interviewers ivr ON i.InterviewerID = ivr.InterviewerID
        WHERE jp.EmployerID = %s 
          AND i.IsDeleted = FALSE
          AND i.Score IS NOT NULL 
          AND i.Note IS NOT NULL
        ORDER BY i.InterviewDate DESC
        LIMIT %s OFFSET %s
    """, (emp_id, per_page, (page - 1) * per_page))

    return render_template('hr/review_interviews.html',
                           interviews=completed_interviews,
                           page=page,
                           total_pages=total_pages)

@hr_bp.route('/make-decision/<int:application_id>', methods=['POST'])
@login_required('HR')
def make_decision(application_id):
    emp_id = session['employer_id']
    decision = request.form.get('decision')
    
    if decision not in ('offer', 'reject'):
        flash("Invalid decision.", "danger")
        return redirect(url_for('hr.review_interviews'))
    
    new_status = 'Offered' if decision == 'offer' else 'Rejected'
    conn = None
    cursor = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT 1 FROM Applications a
            JOIN JobPositions jp ON a.PositionID = jp.PositionID
            WHERE a.ApplicationID = %s AND jp.EmployerID = %s
        """, (application_id, emp_id))
        if not cursor.fetchone():
            flash("Unauthorized.", "danger")
        else:
            cursor.execute("UPDATE Applications SET Status = %s WHERE ApplicationID = %s", (new_status, application_id))
            
            if decision == 'offer':
                cursor.execute("""
                    SELECT jp.SalaryMin, jp.SalaryMax 
                    FROM Applications a
                    JOIN JobPositions jp ON a.PositionID = jp.PositionID
                    WHERE a.ApplicationID = %s
                """, (application_id,))
                sal = cursor.fetchone()
                if sal:
                    basic_salary = (sal[0] + sal[1]) / 2 if sal[0] and sal[1] else 10000000
                else:
                    basic_salary = 10000000
                cursor.execute("""
                    INSERT INTO JobOffers (ApplicationID, BasicSalary, OfferDate, ValidUntil, Status, Note)
                    VALUES (%s, %s, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'Pending', 'We are pleased to offer you this position.')
                """, (application_id, basic_salary))
            
            conn.commit()
            flash(f"Application status updated to {new_status}.", "success")
    except Exception as e:
        if conn:
            conn.rollback()
        flash("Error making decision.", "danger")
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
    
    return redirect(url_for('hr.review_interviews'))

# ============================================================
# SOFT DELETE
# ============================================================
@hr_bp.route('/job/<int:job_id>/delete', methods=['POST'])
@login_required('HR')
def delete_job(job_id):
    try:
        _, out = call_procedure_out('sp_SoftDeletePosition', (job_id, ''))
        flash(out[1] if len(out) > 1 else 'Job deleted.', 'success')
    except Exception as e:
        flash(f'Error: {str(e)}', 'danger')
    return redirect(url_for('hr.manage_jobs'))

@hr_bp.route('/candidate/<int:candidate_id>/delete', methods=['POST'])
@login_required('HR')
def delete_candidate(candidate_id):
    try:
        _, out = call_procedure_out('sp_SoftDeleteCandidate', (candidate_id, ''))
        flash(out[1] if len(out) > 1 else 'Candidate deleted.', 'success')
    except Exception as e:
        flash(f'Error: {str(e)}', 'danger')
    return redirect(url_for('hr.applications'))

# ============================================================
# REPORTS (Single endpoint, no duplicates)
# ============================================================
@hr_bp.route('/reports')
@login_required('HR')
def reports():
    """Hiển thị trang báo cáo với 2 tab"""
    return render_template('hr/reports.html')

@hr_bp.route('/api/interviewer-stats')
@login_required('HR')
def interviewer_stats():
    emp_id = session['employer_id']
    period = request.args.get('period', 'this_month')
    
    month = request.args.get('month', type=int) or datetime.now().month
    year = request.args.get('year', type=int) or datetime.now().year
    
    if period == 'all':
        rows = query_db("""
            SELECT 
                ivr.InterviewerID,
                ivr.FullName,
                COUNT(iv.InterviewID) AS TotalInterviews,
                ROUND(AVG(iv.Score), 1) AS AvgScore,
                SUM(CASE WHEN iv.Result = 'Pass' THEN 1 ELSE 0 END) AS Passes,
                SUM(CASE WHEN iv.Result = 'Fail' THEN 1 ELSE 0 END) AS Fails
            FROM Interviewers ivr
            JOIN Interviews iv ON ivr.InterviewerID = iv.InterviewerID 
                AND iv.IsDeleted = FALSE
            JOIN Applications a ON iv.ApplicationID = a.ApplicationID
            JOIN JobPositions jp ON a.PositionID = jp.PositionID
            WHERE jp.EmployerID = %s AND ivr.EmployerID = %s
            GROUP BY ivr.InterviewerID, ivr.FullName
            ORDER BY TotalInterviews DESC
        """, (emp_id, emp_id))
    else:
        rows = query_db("""
            SELECT 
                ivr.InterviewerID,
                ivr.FullName,
                COUNT(iv.InterviewID) AS TotalInterviews,
                ROUND(AVG(iv.Score), 1) AS AvgScore,
                SUM(CASE WHEN iv.Result = 'Pass' THEN 1 ELSE 0 END) AS Passes,
                SUM(CASE WHEN iv.Result = 'Fail' THEN 1 ELSE 0 END) AS Fails
            FROM Interviewers ivr
            JOIN Interviews iv ON ivr.InterviewerID = iv.InterviewerID 
                AND iv.IsDeleted = FALSE
                AND MONTH(iv.InterviewDate) = %s
                AND YEAR(iv.InterviewDate) = %s
            JOIN Applications a ON iv.ApplicationID = a.ApplicationID
            JOIN JobPositions jp ON a.PositionID = jp.PositionID
            WHERE jp.EmployerID = %s AND ivr.EmployerID = %s
            GROUP BY ivr.InterviewerID, ivr.FullName
            ORDER BY TotalInterviews DESC
        """, (month, year, emp_id, emp_id))
    
    return jsonify(rows)

@hr_bp.route('/api/job-stats')
@login_required('HR')
def job_stats():
    emp_id = session['employer_id']
    period = request.args.get('period', 'this_month')
    month = request.args.get('month', type=int) or datetime.now().month
    year = request.args.get('year', type=int) or datetime.now().year
    
    if period == 'all':
        rows = query_db("""
            SELECT 
                jp.PositionID,
                jp.PositionName,
                COUNT(a.ApplicationID) AS TotalApplications,
                SUM(CASE WHEN a.Status = 'Accepted' THEN 1 ELSE 0 END) AS Hired,
                ROUND(
                    SUM(CASE WHEN a.Status = 'Accepted' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.ApplicationID), 
                    1
                ) AS ConversionRate,
                ROUND(AVG(CASE WHEN a.Status = 'Accepted' AND jo.OfferDate >= a.ApplicationDate 
                               THEN DATEDIFF(jo.OfferDate, a.ApplicationDate) END), 1) AS AvgTimeToHire
            FROM JobPositions jp
            LEFT JOIN Applications a ON jp.PositionID = a.PositionID 
                AND a.IsDeleted = FALSE
            LEFT JOIN JobOffers jo ON a.ApplicationID = jo.ApplicationID
            WHERE jp.EmployerID = %s AND jp.IsDeleted = FALSE
            GROUP BY jp.PositionID, jp.PositionName
            HAVING TotalApplications > 0
            ORDER BY TotalApplications DESC
        """, (emp_id,))
    else:
        rows = query_db("""
            SELECT 
                jp.PositionID,
                jp.PositionName,
                COUNT(a.ApplicationID) AS TotalApplications,
                SUM(CASE WHEN a.Status = 'Accepted' THEN 1 ELSE 0 END) AS Hired,
                ROUND(
                    SUM(CASE WHEN a.Status = 'Accepted' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.ApplicationID), 
                    1
                ) AS ConversionRate,
                ROUND(AVG(CASE WHEN a.Status = 'Accepted' AND jo.OfferDate >= a.ApplicationDate 
                               THEN DATEDIFF(jo.OfferDate, a.ApplicationDate) END), 1) AS AvgTimeToHire
            FROM JobPositions jp
            LEFT JOIN Applications a ON jp.PositionID = a.PositionID 
                AND a.IsDeleted = FALSE
                AND MONTH(a.ApplicationDate) = %s
                AND YEAR(a.ApplicationDate) = %s
            LEFT JOIN JobOffers jo ON a.ApplicationID = jo.ApplicationID
            WHERE jp.EmployerID = %s AND jp.IsDeleted = FALSE
            GROUP BY jp.PositionID, jp.PositionName
            HAVING TotalApplications > 0
            ORDER BY TotalApplications DESC
        """, (month, year, emp_id))
    
    return jsonify(rows)

@hr_bp.route('/api/monthly-trends')
@login_required('HR')
def monthly_trends():
    emp_id = session['employer_id']
    year = 2026
    months = list(range(1, 7))
    
    try:
        rows = query_db("""
            SELECT MONTH(a.ApplicationDate) as Month,
                   COUNT(*) as Applications,
                   SUM(CASE WHEN a.Status = 'Accepted' THEN 1 ELSE 0 END) as Hired
            FROM Applications a
            JOIN JobPositions jp ON a.PositionID = jp.PositionID
            WHERE jp.EmployerID = %s
              AND YEAR(a.ApplicationDate) = %s
              AND a.IsDeleted = FALSE
            GROUP BY MONTH(a.ApplicationDate)
        """, (emp_id, year))
        
        data_map = {row['Month']: (row['Applications'], row['Hired']) for row in rows}
        labels = [datetime(2026, m, 1).strftime('%B') for m in months]
        applications = [data_map.get(m, (0, 0))[0] for m in months]
        hired = [data_map.get(m, (0, 0))[1] for m in months]
        
        return jsonify({
            'labels': labels,
            'applications': applications,
            'hired': hired
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ============================================================
# MISC
# ============================================================
@hr_bp.route('/skills', methods=['GET', 'POST'])
@login_required('HR')
def skills():
    if request.method == 'POST':
        name = request.form.get('skill_name')
        try:
            query_db("INSERT INTO Skills (SkillName) VALUES (%s)", (name,))
            flash("Skill added.", "success")
        except:
            flash("Error adding skill. May already exist.", "danger")
        return redirect(url_for('hr.skills'))
        
    skills = query_db("SELECT * FROM Skills")
    return render_template('hr/skills.html', skills=skills)

@hr_bp.route('/departments')
@login_required('HR')
def departments_api():
    emp_id = session['employer_id']
    depts = query_db("SELECT DepartmentID, DepartmentName FROM Departments WHERE EmployerID = %s", (emp_id,))
    return jsonify(depts)

@hr_bp.route('/api/overview-stats')
@login_required('HR')
def overview_stats():
    emp_id = session['employer_id']
    try:
        # Tổng applications
        total_apps = query_db("""
            SELECT COUNT(*) as cnt FROM Applications a
            JOIN JobPositions jp ON a.PositionID = jp.PositionID
            WHERE jp.EmployerID = %s AND a.IsDeleted = FALSE
        """, (emp_id,), one=True)['cnt']
        # Tổng offers (đã tạo)
        total_offers = query_db("""
            SELECT COUNT(*) as cnt FROM JobOffers jo
            JOIN Applications a ON jo.ApplicationID = a.ApplicationID
            JOIN JobPositions jp ON a.PositionID = jp.PositionID
            WHERE jp.EmployerID = %s
        """, (emp_id,), one=True)['cnt']
        # Offer Accepted Rate ( số offer được chấp nhận / tổng offer )
        accepted_offers = query_db("""
            SELECT COUNT(*) as cnt FROM JobOffers jo
            JOIN Applications a ON jo.ApplicationID = a.ApplicationID
            JOIN JobPositions jp ON a.PositionID = jp.PositionID
            WHERE jp.EmployerID = %s AND jo.Status = 'Accepted'
        """, (emp_id,), one=True)['cnt']
        offer_accept_rate = (accepted_offers / total_offers * 100) if total_offers > 0 else 0
        # Conversion Rate (hired / total apps)
        hired = query_db("""
            SELECT COUNT(*) as cnt FROM Applications a
            JOIN JobPositions jp ON a.PositionID = jp.PositionID
            WHERE jp.EmployerID = %s AND a.Status = 'Accepted'
        """, (emp_id,), one=True)['cnt']
        conversion_rate = (hired / total_apps * 100) if total_apps > 0 else 0
        return jsonify({
            'total_apps': total_apps,
            'total_offers': total_offers,
            'offer_accept_rate': round(offer_accept_rate, 1),
            'conversion_rate': round(conversion_rate, 1)
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@hr_bp.route('/api/funnel-data')
@login_required('HR')
def funnel_data():
    emp_id = session['employer_id']
    try:
        data = query_db("""
            SELECT 
                SUM(v.TotalApplied) as Applied,
                SUM(v.Screened) as Screened,
                SUM(v.Interviewed) as Interviewed,
                SUM(v.OfferedCount) as Offered,
                SUM(v.Hired) as Hired
            FROM View_StageConversionRates v
            JOIN JobPositions jp ON v.PositionID = jp.PositionID
            WHERE jp.EmployerID = %s AND jp.IsDeleted = FALSE
        """, (emp_id,), one=True)
        return jsonify(data)
    except Exception as e:
        return jsonify({'error': str(e)}), 500  