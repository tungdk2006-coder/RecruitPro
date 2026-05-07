from flask import Blueprint, render_template, session, request, redirect, url_for, flash, jsonify
from models.db import call_procedure_out, query_db
from utils.decorators import login_required
from datetime import datetime, date, timedelta

interviewer_bp = Blueprint('interviewer', __name__)

@interviewer_bp.route('/schedule')
@login_required('Interviewer')
def schedule():
    int_id = session['interviewer_id']
    now = datetime.now()
    all_interviews = query_db("""
        SELECT i.*, jp.PositionName, c.CandidateName, ip.Role, a.CandidateID, a.Status as AppStatus
        FROM Interviews i
        JOIN InterviewPanel ip ON i.InterviewID = ip.InterviewID
        JOIN Applications a ON i.ApplicationID = a.ApplicationID
        JOIN JobPositions jp ON a.PositionID = jp.PositionID
        JOIN Candidates c ON a.CandidateID = c.CandidateID
        WHERE ip.InterviewerID = %s AND i.IsDeleted = FALSE
        ORDER BY i.InterviewDate ASC
    """, (int_id,))
    
    past = [iv for iv in all_interviews if iv['Score'] is not None or iv['Result'] in ('Pass', 'Fail')]
    upcoming = [iv for iv in all_interviews if iv not in past]
    
    return render_template('interviewer/my_schedule.html', upcoming=upcoming, past=past)

@interviewer_bp.route('/record', methods=['POST'])
@login_required('Interviewer')
def record_result():
    int_id = session['interviewer_id']
    interview_id = request.form.get('interview_id')
    score = request.form.get('score')
    result = request.form.get('result')
    note = request.form.get('note', '')
    tech = request.form.get('tech_skills', '')
    comm = request.form.get('communication', '')
    strengths = request.form.get('strengths', '')
    weaknesses = request.form.get('weaknesses', '')
    redirect_to = request.form.get('redirect_to', 'schedule') 

    # Validate panel
    valid = query_db("SELECT 1 FROM InterviewPanel WHERE InterviewID = %s AND InterviewerID = %s", (interview_id, int_id), one=True)
    if not valid:
        flash("Unauthorized to record this interview.", "danger")
        return redirect(url_for('interviewer.schedule'))

    # Tổng hợp ghi chú
    full_note = f"[Tech: {tech}/10]\n[Comm: {comm}/10]\nStrengths: {strengths}\nWeaknesses: {weaknesses}\n{note}"

    try:
        _, out = call_procedure_out('sp_RecordInterviewResult', (interview_id, score, result, full_note, ''))
        flash(out[4], "success" if "success" in out[4].lower() else "info")
    except Exception as e:
        flash("Error recording result.", "danger")

    if redirect_to == 'dashboard':
        return redirect(url_for('interviewer.dashboard'))
    else:
        return redirect(url_for('interviewer.schedule'))

@interviewer_bp.route('/interview/<int:id>/candidate')
@login_required('Interviewer')
def view_candidate(id):
    int_id = session['interviewer_id']
    # Check authorization
    valid = query_db("SELECT a.CandidateID FROM Interviews i JOIN InterviewPanel ip ON i.InterviewID = ip.InterviewID JOIN Applications a ON i.ApplicationID = a.ApplicationID WHERE i.InterviewID = %s AND ip.InterviewerID = %s", (id, int_id), one=True)
    
    if not valid:
        flash("Unauthorized.", "danger")
        return redirect(url_for('interviewer.schedule'))
        
    cand_id = valid['CandidateID']
    candidate = query_db("SELECT * FROM Candidates WHERE CandidateID = %s", (cand_id,), one=True)
    
    # Nếu là AJAX request (từ modal) -> trả về template modal nhỏ
    if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
        return render_template('interviewer/candidate_modal.html', candidate=candidate)
    
    # Ngược lại, trả về trang chi tiết đầy đủ
    return render_template('interviewer/candidate_detail.html', candidate=candidate)

@interviewer_bp.route('/notifications')
@login_required('Interviewer')
def notifications():
    interviewer_id = session['interviewer_id']
    try:
        notifs = query_db(
            "SELECT * FROM InterviewerNotifications WHERE InterviewerID = %s ORDER BY CreatedAt DESC",
            (interviewer_id,)
        )
        return render_template('interviewer/notifications.html', notifications=notifs)
    except Exception as e:
        flash("Error loading notifications.", "danger")
        return redirect(url_for('interviewer.schedule'))

@interviewer_bp.route('/notifications/read/<int:notif_id>', methods=['POST'])
@login_required('Interviewer')
def mark_notification_read_ajax(notif_id):
    try:
        query_db("UPDATE InterviewerNotifications SET IsRead = TRUE WHERE NotifID = %s", (notif_id,))
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@interviewer_bp.route('/notifications/unread-count')
@login_required('Interviewer')
def unread_count():
    interviewer_id = session['interviewer_id']
    try:
        count = query_db(
            "SELECT COUNT(*) as cnt FROM InterviewerNotifications WHERE InterviewerID = %s AND IsRead = FALSE",
            (interviewer_id,),
            one=True
        )
        return jsonify({'count': count['cnt']})
    except:
        return jsonify({'count': 0})

@interviewer_bp.route('/dashboard')
@login_required('Interviewer')
def dashboard():
    int_id = session['interviewer_id']
    today = date.today()
    now = datetime.now()
    
    # Lấy danh sách cuộc phỏng vấn hôm nay
    raw_interviews = query_db("""
        SELECT i.*, jp.PositionName, c.CandidateName, c.ResumeURL, ip.Role, ip.IsConfirmed
        FROM Interviews i
        JOIN InterviewPanel ip ON i.InterviewID = ip.InterviewID
        JOIN Applications a ON i.ApplicationID = a.ApplicationID
        JOIN JobPositions jp ON a.PositionID = jp.PositionID
        JOIN Candidates c ON a.CandidateID = c.CandidateID
        WHERE ip.InterviewerID = %s 
          AND i.IsDeleted = FALSE
          AND DATE(i.InterviewDate) = %s
        ORDER BY i.InterviewDate ASC
    """, (int_id, today))
    
    # Gắn cờ is_soon nếu buổi phỏng vấn sẽ diễn ra trong vòng 30 phút tới
    today_interviews = []
    for iv in raw_interviews:
        iv_dict = dict(iv) 
        interview_dt = iv_dict.get('InterviewDate')
        # Kiểm tra đã có kết quả hay chưa (coi là completed nếu Score khác None hoặc Result là Pass/Fail)
        iv_dict['is_completed'] = (iv_dict.get('Score') is not None) or (iv_dict.get('Result') in ('Pass','Fail'))
        if interview_dt and isinstance(interview_dt, datetime):
            iv_dict['is_soon'] = (interview_dt - now <= timedelta(minutes=30)) and (interview_dt >= now)
        else:
            iv_dict['is_soon'] = False
        today_interviews.append(iv_dict)
    
    # Stats 
    total_today = query_db("SELECT COUNT(*) as cnt FROM Interviews i JOIN InterviewPanel ip ON i.InterviewID = ip.InterviewID WHERE ip.InterviewerID = %s AND DATE(i.InterviewDate) = %s AND i.IsDeleted = FALSE", (int_id, today), one=True)['cnt']
    completed_today = query_db("""
        SELECT COUNT(*) as cnt 
        FROM Interviews i 
        JOIN InterviewPanel ip ON i.InterviewID = ip.InterviewID 
        WHERE ip.InterviewerID = %s 
          AND DATE(i.InterviewDate) = %s 
          AND i.Score IS NOT NULL 
          AND i.IsDeleted = FALSE
    """, (int_id, today), one=True)['cnt']

    upcoming_week = query_db("""
        SELECT COUNT(*) as cnt 
        FROM Interviews i 
        JOIN InterviewPanel ip ON i.InterviewID = ip.InterviewID 
        WHERE ip.InterviewerID = %s 
          AND i.InterviewDate >= NOW() 
          AND i.InterviewDate < DATE_ADD(NOW(), INTERVAL 7 DAY) 
          AND i.IsDeleted = FALSE
    """, (int_id,), one=True)['cnt']
    avg_score = query_db("SELECT ROUND(AVG(i.Score),1) as avg FROM Interviews i JOIN InterviewPanel ip ON i.InterviewID = ip.InterviewID WHERE ip.InterviewerID = %s AND i.Score IS NOT NULL AND i.IsDeleted = FALSE", (int_id,), one=True)['avg'] or 0
    
    stats = {
        'total_today': total_today,
        'completed_today': completed_today,
        'upcoming_week': upcoming_week,
        'avg_score': avg_score
    }
    
    return render_template('interviewer/dashboard.html', 
                           today_interviews=today_interviews,
                           date_today=today,
                           stats=stats)


@interviewer_bp.route('/interview/<int:id>/confirm', methods=['POST'])
@login_required('Interviewer')
def confirm_interview(id):
    int_id = session['interviewer_id']
    # Kiểm tra quyền
    valid = query_db("SELECT 1 FROM InterviewPanel WHERE InterviewID = %s AND InterviewerID = %s", (id, int_id), one=True)
    if not valid:
        flash("Unauthorized.", "danger")
        return redirect(url_for('interviewer.schedule'))
    
    query_db("UPDATE InterviewPanel SET IsConfirmed = NOT IsConfirmed WHERE InterviewID = %s AND InterviewerID = %s", (id, int_id))
    flash("Confirmation updated.", "success")
    return redirect(url_for('interviewer.dashboard'))


