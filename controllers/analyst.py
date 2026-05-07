from flask import Blueprint, render_template, session, request, redirect, url_for, flash
from models.db import query_db
from utils.decorators import login_required

analyst_bp = Blueprint('analyst', __name__)

# ==========================================
# ROUTE: ANALYST DASHBOARD
# ==========================================
@analyst_bp.route('/dashboard')
@login_required('Analyst')
def dashboard():
    try:
        # Lấy tham số lọc công ty
        employer_id = request.args.get('employer_id', '')
        
        # Danh sách employers cho dropdown
        employers = query_db("""
            SELECT EmployerID, EmployerName 
            FROM Employers 
            WHERE IsDeleted = FALSE 
            ORDER BY EmployerName
        """)
        
        # Xây dựng điều kiện WHERE cho các truy vấn
        app_where = "WHERE a.IsDeleted = FALSE"
        job_where = "WHERE IsDeleted = FALSE"
        offer_where = ""
        interview_where = "WHERE i.IsDeleted = FALSE"
        
        params = []
        if employer_id:
            app_where += " AND jp.EmployerID = %s"
            job_where += " AND EmployerID = %s"
            offer_where = "JOIN Applications a ON jo.ApplicationID = a.ApplicationID JOIN JobPositions jp ON a.PositionID = jp.PositionID WHERE jp.EmployerID = %s"
            interview_where += " AND a.PositionID IN (SELECT PositionID FROM JobPositions WHERE EmployerID = %s)"
            params = [employer_id]

        # Quick Stats
        total_apps = query_db(f"SELECT COUNT(*) as cnt FROM Applications a JOIN JobPositions jp ON a.PositionID = jp.PositionID {app_where}", tuple(params), one=True)['cnt']
        total_jobs = query_db(f"SELECT COUNT(*) as cnt FROM JobPositions {job_where}", tuple(params), one=True)['cnt']
        total_interviews = query_db(f"SELECT COUNT(*) as cnt FROM Interviews i JOIN Applications a ON i.ApplicationID = a.ApplicationID JOIN JobPositions jp ON a.PositionID = jp.PositionID {interview_where}", tuple(params), one=True)['cnt']
        total_offers = query_db(f"SELECT COUNT(*) as cnt FROM JobOffers jo {offer_where}", tuple(params), one=True)['cnt'] if employer_id else query_db("SELECT COUNT(*) as cnt FROM JobOffers", one=True)['cnt']

        # Status Summary
        status_summary = query_db(f"SELECT a.Status, COUNT(*) as Count FROM Applications a JOIN JobPositions jp ON a.PositionID = jp.PositionID {app_where} GROUP BY a.Status ORDER BY a.Status", tuple(params))

        # Employer Stats (chỉ hiển thị khi không lọc, hoặc hiển thị 1 dòng nếu đang lọc)
        if employer_id:
            employer_stats = query_db(f"SELECT e.EmployerName, COUNT(DISTINCT p.PositionID) as TotalJobs, COUNT(DISTINCT a.ApplicationID) as TotalApps FROM Employers e LEFT JOIN JobPositions p ON e.EmployerID = p.EmployerID AND p.IsDeleted = FALSE LEFT JOIN Applications a ON p.PositionID = a.PositionID AND a.IsDeleted = FALSE WHERE e.EmployerID = %s GROUP BY e.EmployerID, e.EmployerName", (employer_id,))
        else:
            employer_stats = query_db("""
                SELECT e.EmployerName, 
                       COUNT(DISTINCT p.PositionID) as TotalJobs,
                       COUNT(DISTINCT a.ApplicationID) as TotalApps
                FROM Employers e
                LEFT JOIN JobPositions p ON e.EmployerID = p.EmployerID AND p.IsDeleted = FALSE
                LEFT JOIN Applications a ON p.PositionID = a.PositionID AND a.IsDeleted = FALSE
                WHERE e.IsDeleted = FALSE
                GROUP BY e.EmployerID, e.EmployerName
                ORDER BY TotalApps DESC
            """)

        # Funnel data (toàn hệ thống hoặc theo công ty)
        if employer_id:
            funnel_data = query_db("""
                SELECT 
                    SUM(TotalApplied) as Applied,
                    SUM(Screened) as Screened,
                    SUM(Interviewed) as Interviewed,
                    SUM(OfferedCount) as Offered,
                    SUM(Hired) as Hired
                FROM View_StageConversionRates
                WHERE PositionID IN (SELECT PositionID FROM JobPositions WHERE EmployerID = %s)
            """, (employer_id,), one=True)
        else:
            funnel_data = query_db("""
                SELECT 
                    SUM(TotalApplied) as Applied,
                    SUM(Screened) as Screened,
                    SUM(Interviewed) as Interviewed,
                    SUM(OfferedCount) as Offered,
                    SUM(Hired) as Hired
                FROM View_StageConversionRates
            """, one=True)

        return render_template('analyst/dashboard.html',
                               total_apps=total_apps,
                               total_interviews=total_interviews,
                               total_jobs=total_jobs,
                               total_offers=total_offers,
                               status_summary=status_summary,
                               employer_stats=employer_stats,
                               funnel=funnel_data,
                               employers=employers,
                               selected_employer=employer_id)
    except Exception as e:
        flash(f"Error loading analyst dashboard: {e}", "danger")
        return redirect(url_for('home'))

# API cho biểu đồ xu hướng (có hỗ trợ lọc công ty)
@analyst_bp.route('/api/monthly-trends')
@login_required('Analyst')
def api_monthly_trends():
    from flask import jsonify
    employer_id = request.args.get('employer_id', '')
    if employer_id:
        trends = query_db("""
            SELECT DATE_FORMAT(a.ApplicationDate, '%Y-%m') as Month, COUNT(*) as Count
            FROM Applications a
            JOIN JobPositions jp ON a.PositionID = jp.PositionID
            WHERE a.IsDeleted = FALSE AND jp.EmployerID = %s
            GROUP BY Month
            ORDER BY Month ASC
        """, (employer_id,))
    else:
        trends = query_db("""
            SELECT DATE_FORMAT(ApplicationDate, '%Y-%m') as Month, COUNT(*) as Count
            FROM Applications
            WHERE IsDeleted = FALSE
            GROUP BY Month
            ORDER BY Month ASC
        """)
    return jsonify(trends)

# ==========================================
# ROUTE: INTERVIEWER WORKLOAD
# ==========================================
@analyst_bp.route('/interviewer-workload')
@login_required('Analyst')
def interviewer_workload():
    try:
        workload = query_db("""
            SELECT * FROM View_InterviewerWorkload 
            ORDER BY TotalInterviews DESC
        """)
        return render_template('analyst/interviewer_workload.html', workload=workload)
    except Exception as e:
        flash(f"Error loading interviewer workload: {e}", "danger")
        return redirect(url_for('analyst.dashboard'))

# ==========================================
# ROUTE: TOP CANDIDATES (DANH SÁCH CÔNG TY)
# ==========================================
@analyst_bp.route('/top-candidates')
@login_required('Analyst')
def top_candidates():
    try:
        employers = query_db("""
            SELECT EmployerID, EmployerName 
            FROM Employers 
            WHERE IsDeleted = FALSE 
            ORDER BY EmployerName
        """)
        return render_template('analyst/top_candidates.html', employers=employers)
    except Exception as e:
        flash(f"Error loading companies: {e}", "danger")
        return redirect(url_for('analyst.dashboard'))

# ==========================================
# ROUTE: TOP CANDIDATES CỦA MỘT CÔNG TY
# ==========================================
@analyst_bp.route('/top-candidates/<int:employer_id>')
@login_required('Analyst')
def top_candidates_company(employer_id):
    employer = query_db("SELECT EmployerName FROM Employers WHERE EmployerID = %s", (employer_id,), one=True)
    if not employer:
        flash("Company not found.", "danger")
        return redirect(url_for('analyst.top_candidates'))

    search_name = request.args.get('search_name', '').strip()
    search_position = request.args.get('search_position', '').strip()

    candidates = query_db("""
        SELECT *
        FROM View_TopCandidates
        WHERE EmployerName = %s
        ORDER BY AvgScore DESC
    """, (employer['EmployerName'],))

    if search_name:
        candidates = [c for c in candidates if search_name.lower() in c['CandidateName'].lower()]
    if search_position:
        candidates = [c for c in candidates if search_position.lower() in c['PositionName'].lower()]

    return render_template('analyst/top_candidates_company.html',
                           employer=employer,
                           candidates=candidates,
                           search_name=search_name,
                           search_position=search_position)

