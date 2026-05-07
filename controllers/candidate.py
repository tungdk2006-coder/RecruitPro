from flask import Blueprint, render_template, session, request, redirect, url_for, flash, jsonify
from models.db import call_procedure_out, query_db
from utils.decorators import login_required
import os
from werkzeug.utils import secure_filename
from config import Config

candidate_bp = Blueprint('candidate', __name__)

@candidate_bp.route('/dashboard')
@login_required('Candidate')
def dashboard():
    cid = session['user_id']
    try:
        # 1. Fetch Profile Data
        cand = query_db("SELECT * FROM Candidates WHERE CandidateID = %s", (cid,), one=True)
        completion = 20
        if cand:
            if cand.get('Address'): completion += 15
            if cand.get('PhoneNumber'): completion += 15
            if cand.get('EducationLevel'): completion += 15
            if cand.get('GPA'): completion += 10
            if cand.get('ResumeURL'): completion += 25

        # 2. Application Status counts (realtime)
        stats = query_db("""
            SELECT 
                COUNT(*) AS TotalApplications,
                SUM(CASE WHEN Status = 'Applied' THEN 1 ELSE 0 END) AS Applied,
                SUM(CASE WHEN Status = 'Screening' THEN 1 ELSE 0 END) AS Screening,
                SUM(CASE WHEN Status = 'Interviewing' THEN 1 ELSE 0 END) AS Interviewing,
                SUM(CASE WHEN Status = 'Offered' THEN 1 ELSE 0 END) AS Offered,
                SUM(CASE WHEN Status = 'Accepted' THEN 1 ELSE 0 END) AS Accepted,
                SUM(CASE WHEN Status = 'Rejected' THEN 1 ELSE 0 END) AS Rejected
            FROM Applications
            WHERE CandidateID = %s AND IsDeleted = FALSE
        """, (cid,), one=True)
        # Fallback nếu chưa có application nào
        if not stats:
            stats = {
                'TotalApplications': 0, 'Applied': 0, 'Screening': 0,
                'Interviewing': 0, 'Offered': 0, 'Accepted': 0, 'Rejected': 0
            }

        # 3. Upcoming Interviews (chỉ lấy những cuộc trong tương lai, chưa bị xoá)
        upcoming_interviews = query_db("""
            SELECT iv.InterviewID, iv.InterviewDate, iv.RoundNumber, iv.InterviewType, iv.Location,
                   jp.PositionName, e.EmployerName, ivr.FullName as InterviewerName
            FROM Interviews iv
            JOIN Applications a ON iv.ApplicationID = a.ApplicationID
            JOIN JobPositions jp ON a.PositionID = jp.PositionID
            JOIN Employers e ON jp.EmployerID = e.EmployerID
            LEFT JOIN Interviewers ivr ON iv.InterviewerID = ivr.InterviewerID
            WHERE a.CandidateID = %s AND iv.InterviewDate >= NOW() AND iv.IsDeleted = FALSE
            ORDER BY iv.InterviewDate ASC
        """, (cid,))

        # 4. Pending Offers (realtime)
        pending_offers = query_db("""
            SELECT jo.*, jp.PositionName, e.EmployerName, a.ApplicationID
            FROM JobOffers jo
            JOIN Applications a ON jo.ApplicationID = a.ApplicationID
            JOIN JobPositions jp ON a.PositionID = jp.PositionID
            JOIN Employers e ON jp.EmployerID = e.EmployerID
            WHERE a.CandidateID = %s AND jo.Status = 'Pending'
            ORDER BY jo.ValidUntil ASC
        """, (cid,))

        # 5. Recent Activities (Saved Jobs) - gọi procedure, lấy tối đa 5
        saved, _ = call_procedure_out('sp_GetSavedJobs', (cid,))
        recent_saved = saved[:5] if saved else []

        # Tạo dict status_counts để template dễ render biểu đồ
        status_counts = {
            'Applied': stats['Applied'] or 0,
            'Screening': stats['Screening'] or 0,
            'Interviewing': stats['Interviewing'] or 0,
            'Offered': stats['Offered'] or 0,
            'Accepted': stats['Accepted'] or 0,
            'Rejected': stats['Rejected'] or 0
        }

        return render_template('candidate/dashboard.html',
                               stats=stats,
                               cand=cand,
                               completion=completion,
                               recent_saved=recent_saved,
                               upcoming_interviews=upcoming_interviews,
                               pending_offers=pending_offers,
                               status_counts=status_counts)
    except Exception as e:
        flash(f"Error loading dashboard: {e}", "danger")
        return redirect(url_for('home'))

@candidate_bp.route('/jobs')
@login_required('Candidate')
def search_jobs():
    keyword = request.args.get('keyword')
    industry = request.args.get('industry')
    job_type = request.args.get('job_type')
    location = request.args.get('location')
    salary = request.args.get('salary')

    employer_id = request.args.get('employer_id')
    if employer_id:
        emp = query_db("SELECT EmployerName FROM Employers WHERE EmployerID = %s", (employer_id,), one=True)
        if emp:
            keyword = emp['EmployerName']

    keyword = keyword if keyword else None
    industry = industry if industry else None
    job_type = job_type if job_type else None
    location = location if location else None

    min_salary = None
    max_salary = None
    if salary == 'under_5':
        min_salary, max_salary = 0, 5000000
    elif salary == '5_10':
        min_salary, max_salary = 5000000, 10000000
    elif salary == '10_20':
        min_salary, max_salary = 10000000, 20000000
    elif salary == 'over_20':
        min_salary, max_salary = 20000000, 999999999

    try:
        results, _ = call_procedure_out('sp_SearchJobs',
                                        (keyword, industry, job_type, location, min_salary, max_salary))
        industries = query_db("SELECT IndustryName FROM Industries")
        locations_list = query_db(
            "SELECT DISTINCT Location FROM JobPositions WHERE IsDeleted = FALSE AND Status = 'Open' AND Location IS NOT NULL ORDER BY Location")
        cid = session['user_id']
        saved_jobs = [row['PositionID'] for row in
                      query_db("SELECT PositionID FROM SavedJobs WHERE CandidateID = %s", (cid,))]
        cand = query_db("SELECT CandidateName, Email, ResumeURL FROM Candidates WHERE CandidateID = %s", (cid,), one=True)

        page = request.args.get('page', 1, type=int)
        per_page = 10
        total = len(results)
        total_pages = (total + per_page - 1) // per_page
        paginated_jobs = results[(page - 1) * per_page: page * per_page]

        return render_template('candidate/search_jobs.html', jobs=paginated_jobs,
                               industries=industries, locations=locations_list,
                               saved_jobs=saved_jobs, cand=cand,
                               page=page, total_pages=total_pages, total_jobs=total)
    except Exception as e:
        flash(f"Error searching jobs: {e}", "danger")
        return redirect(url_for('candidate.dashboard'))

@candidate_bp.route('/job/<int:id>')
@login_required('Candidate')
def job_detail(id):
    try:
        job = query_db("""
            SELECT jp.*, e.EmployerName, e.CompanyDescription, ind.IndustryName
            FROM JobPositions jp
            JOIN Employers e ON jp.EmployerID = e.EmployerID AND e.IsDeleted = FALSE
            LEFT JOIN Industries ind ON e.IndustryID = ind.IndustryID AND ind.IsDeleted = FALSE
            WHERE jp.PositionID = %s AND jp.IsDeleted = FALSE
        """, (id,), one=True)
        if not job:
            flash("Job not found.", "danger")
            return redirect(url_for('candidate.search_jobs'))

        cid = session['user_id']
        saved = query_db("SELECT 1 FROM SavedJobs WHERE CandidateID = %s AND PositionID = %s", (cid, id), one=True)
        applied = query_db("SELECT 1 FROM Applications WHERE CandidateID = %s AND PositionID = %s", (cid, id), one=True)

        reqs = query_db("""
            SELECT s.SkillName, jr.RequiredLevel, jr.IsMandatory 
            FROM JobRequirements jr
            JOIN Skills s ON jr.SkillID = s.SkillID
            WHERE jr.PositionID = %s
        """, (id,))
        cand = query_db("SELECT CandidateName, Email, ResumeURL FROM Candidates WHERE CandidateID = %s", (cid,), one=True)

        return render_template('candidate/job_detail.html', job=job, is_saved=bool(saved),
                               has_applied=bool(applied), reqs=reqs, cand=cand)
    except Exception as e:
        import traceback
        traceback.print_exc()
        flash(f"Error loading job details: {str(e)}", "danger")
        return redirect(url_for('candidate.search_jobs'))

@candidate_bp.route('/job/<int:id>/apply', methods=['POST'])
@login_required('Candidate')
def apply_job(id):
    cid = session['user_id']
    cover_letter = request.form.get('cover_letter', None)
    cv_option = request.form.get('cv_option', 'existing')
    try:
        if cv_option == 'new':
            cv_file = request.files.get('cv_file')
            if cv_file and cv_file.filename != '':
                filename = secure_filename(f"cv_{cid}_{cv_file.filename}")
                filepath = os.path.join(Config.UPLOAD_FOLDER, filename)
                cv_file.save(filepath)
                query_db("UPDATE Candidates SET ResumeURL = %s WHERE CandidateID = %s", (filepath, cid))

        _, out_args = call_procedure_out('sp_CandidateApply', (cid, id, cover_letter, ''))
        result_msg = out_args[3] if len(out_args) > 3 else "Unknown error"
        if result_msg and 'success' in result_msg.lower():
            flash("Application submitted successfully!", "success")
        else:
            flash(f"Failed: {result_msg}", "danger")
    except Exception as e:
        flash(f"Error applying to job: {str(e)}", "danger")
    return redirect(request.referrer or url_for('candidate.job_detail', id=id))

@candidate_bp.route('/companies')
@login_required('Candidate')
def companies():
    try:
        employers = query_db("""
            SELECT e.EmployerID, e.EmployerName, e.CompanyDescription, e.LogoURL,
                   (SELECT COUNT(*) FROM JobPositions jp 
                    WHERE jp.EmployerID = e.EmployerID 
                      AND jp.Status = 'Open' 
                      AND jp.IsDeleted = FALSE) as OpenJobs
            FROM Employers e
            WHERE e.IsDeleted = FALSE
            ORDER BY OpenJobs DESC, e.EmployerName ASC
        """)
        return render_template('candidate/companies.html', companies=employers)
    except Exception as e:
        import traceback
        traceback.print_exc()
        flash(f"Error loading companies: {str(e)}", "danger")
        return redirect(url_for('candidate.dashboard'))

@candidate_bp.route('/applications')
@login_required('Candidate')
def my_applications():
    cid = session['user_id']
    try:
        results, _ = call_procedure_out('sp_GetMyApplications', (cid,))
        job_title = request.args.get('job_title', '').strip()
        company = request.args.get('company', '').strip()
        date_applied = request.args.get('date', '').strip()
        status = request.args.get('status', '').strip()

        filtered = []
        for app in results:
            if job_title and job_title.lower() not in app.get('PositionName', '').lower():
                continue
            if company and company.lower() not in app.get('EmployerName', '').lower():
                continue
            if date_applied:
                app_date = app.get('ApplicationDate')
                if app_date:
                    app_date_str = app_date.strftime('%Y-%m-%d') if hasattr(app_date, 'strftime') else str(app_date)[:10]
                else:
                    app_date_str = ''
                if app_date_str != date_applied:
                    continue
            if status and app.get('Status', '') != status:
                continue
            filtered.append(app)

        page = request.args.get('page', 1, type=int)
        per_page = 10
        total = len(filtered)
        total_pages = (total + per_page - 1) // per_page
        paginated_apps = filtered[(page - 1) * per_page: page * per_page]

        return render_template('candidate/applications.html',
                               applications=paginated_apps,
                               page=page,
                               total_pages=total_pages,
                               job_title=job_title,
                               company=company,
                               date=date_applied,
                               status=status)
    except Exception as e:
        import traceback
        traceback.print_exc()
        flash(f"Error loading applications: {str(e)}", "danger")
        return redirect(url_for('candidate.dashboard'))

@candidate_bp.route('/saved-jobs')
@login_required('Candidate')
def saved_jobs():
    cid = session['user_id']
    try:
        results, _ = call_procedure_out('sp_GetSavedJobs', (cid,))
        return render_template('candidate/saved_jobs.html', jobs=results)
    except Exception as e:
        flash("Error loading saved jobs.", "danger")
        return redirect(url_for('candidate.dashboard'))

@candidate_bp.route('/job/<int:id>/save', methods=['POST'])
@login_required('Candidate')
def save_job(id):
    cid = session['user_id']
    try:
        _, out_args = call_procedure_out('sp_SaveJob', (cid, id, ''))
        flash(out_args[2], "success" if "success" in out_args[2].lower() else "info")
    except Exception as e:
        flash("Error saving job.", "danger")
    return redirect(request.referrer or url_for('candidate.search_jobs'))

@candidate_bp.route('/job/<int:id>/unsave', methods=['POST'])
@login_required('Candidate')
def unsave_job(id):
    cid = session['user_id']
    try:
        _, out_args = call_procedure_out('sp_UnsaveJob', (cid, id, ''))
        flash(out_args[2], "success" if "success" in out_args[2].lower() else "info")
    except Exception as e:
        flash("Error removing saved job.", "danger")
    return redirect(request.referrer or url_for('candidate.saved_jobs'))

@candidate_bp.route('/notifications')
@login_required('Candidate')
def notifications():
    cid = session['user_id']
    try:
        results, _ = call_procedure_out('sp_GetMyNotifications', (cid,))
        return render_template('candidate/notifications.html', notifications=results)
    except Exception as e:
        import traceback
        traceback.print_exc()
        flash(f"Error loading notifications: {str(e)}", "danger")
        return redirect(url_for('candidate.dashboard'))

@candidate_bp.route('/notifications/read', methods=['POST'])
@login_required('Candidate')
def mark_notification_read():
    notif_id = request.form.get('notif_id')
    try:
        call_procedure_out('sp_MarkNotificationRead', (notif_id, ''))
    except Exception as e:
        pass
    return redirect(url_for('candidate.notifications'))

@candidate_bp.route('/profile', methods=['GET', 'POST'])
@login_required('Candidate')
def profile():
    cid = session['user_id']
    if request.method == 'POST':
        phone = request.form.get('phone')
        address = request.form.get('address')
        edu = request.form.get('education')
        gpa = request.form.get('gpa')
        exp = request.form.get('exp')

        cv_file = request.files.get('cv_file')
        resume_url = request.form.get('current_resume', '')

        if cv_file and cv_file.filename != '':
            filename = secure_filename(f"cv_{cid}_{cv_file.filename}")
            filepath = os.path.join(Config.UPLOAD_FOLDER, filename)
            cv_file.save(filepath)
            resume_url = filepath

        try:
            _, out_args = call_procedure_out('sp_CandidateUpdateProfile',
                                             (cid, phone, address, edu, gpa, exp, resume_url, ''))
            flash(out_args[7] if len(out_args) > 7 else "Profile updated.", "success")
        except Exception as e:
            flash("Error updating profile.", "danger")
        return redirect(url_for('candidate.profile'))

    try:
        candidate = query_db("SELECT * FROM Candidates WHERE CandidateID = %s", (cid,), one=True)
        my_skills = query_db("""
            SELECT cs.SkillID, s.SkillName, cs.ProficiencyLevel, cs.YearsUsed
            FROM CandidateSkills cs
            JOIN Skills s ON cs.SkillID = s.SkillID
            WHERE cs.CandidateID = %s
        """, (cid,))
        all_skills = query_db("SELECT SkillID, SkillName FROM Skills ORDER BY SkillName")
        return render_template('candidate/profile.html', candidate=candidate,
                               my_skills=my_skills, all_skills=all_skills)
    except Exception as e:
        flash("Error loading profile.", "danger")
        return redirect(url_for('candidate.dashboard'))

@candidate_bp.route('/profile/skills', methods=['POST'])
@login_required('Candidate')
def add_skill():
    cid = session['user_id']
    skill_id = request.form.get('skill_id')
    proficiency = request.form.get('proficiency')
    years = request.form.get('years_used')
    try:
        _, out_args = call_procedure_out('sp_AddCandidateSkill', (cid, skill_id, proficiency, years, ''))
        flash("Skill updated successfully.", "success")
    except Exception as e:
        flash(f"Error updating skill: {str(e)}", "danger")
    return redirect(url_for('candidate.profile'))

@candidate_bp.route('/interviews')
@login_required('Candidate')
def interviews():
    cid = session['user_id']
    try:
        results, _ = call_procedure_out('sp_GetMyInterviews', (cid,))
        return render_template('candidate/interviews.html', interviews=results)
    except Exception as e:
        flash("Error loading interviews.", "danger")
        return redirect(url_for('candidate.dashboard'))

@candidate_bp.route('/offers')
@login_required('Candidate')
def offers():
    cid = session['user_id']
    try:
        offers = query_db("""
            SELECT jo.*, jp.PositionName, e.EmployerName, a.ApplicationID
            FROM JobOffers jo
            JOIN Applications a ON jo.ApplicationID = a.ApplicationID
            JOIN JobPositions jp ON a.PositionID = jp.PositionID
            JOIN Employers e ON jp.EmployerID = e.EmployerID
            WHERE a.CandidateID = %s
        """, (cid,))
        return render_template('candidate/offers.html', offers=offers)
    except Exception as e:
        flash("Error loading offers.", "danger")
        return redirect(url_for('candidate.dashboard'))

@candidate_bp.route('/offer/<int:application_id>/accept', methods=['POST'])
@login_required('Candidate')
def accept_offer(application_id):
    try:
        _, out_args = call_procedure_out('sp_AcceptOffer', (application_id, ''))
        flash(out_args[1], "success" if "success" in out_args[1].lower() else "danger")
    except Exception as e:
        flash("Error accepting offer.", "danger")
    return redirect(url_for('candidate.offers'))

@candidate_bp.route('/offer/<int:application_id>/decline', methods=['POST'])
@login_required('Candidate')
def decline_offer(application_id):
    cid = session['user_id']
    try:
        _, out_args = call_procedure_out('sp_DeclineOffer', (application_id, cid, ''))
        flash(out_args[2], "success" if "success" in out_args[2].lower() else "danger")
    except Exception as e:
        flash("Error declining offer.", "danger")
    return redirect(url_for('candidate.offers'))

@candidate_bp.route('/api/job-titles')
def api_job_titles():
    try:
        titles = query_db("SELECT DISTINCT PositionName FROM JobPositions WHERE IsDeleted = FALSE ORDER BY PositionName")
        return jsonify([t['PositionName'] for t in titles])
    except Exception:
        return jsonify([])