from flask import Blueprint, render_template, session, request, redirect, url_for, flash
from models.db import query_db, call_procedure_out
from utils.decorators import login_required

admin_bp = Blueprint('admin', __name__)

# ============================================================
# DASHBOARD
# ============================================================
@admin_bp.route('/dashboard')
@login_required('Admin')
def dashboard():
    return render_template('admin/dashboard.html')


# ============================================================
# MANAGE INDUSTRIES
# ============================================================
@admin_bp.route('/industries', methods=['GET', 'POST'])
@login_required('Admin')
def manage_industries():
    if request.method == 'POST':
        industry_name = request.form.get('industry_name')
        try:
            query_db("INSERT INTO Industries (IndustryName) VALUES (%s)", (industry_name,))
            flash(f"Industry '{industry_name}' added successfully.", "success")
        except:
            flash("Error adding industry. It may already exist.", "danger")
        return redirect(url_for('admin.manage_industries'))

    industries = query_db("SELECT * FROM Industries ORDER BY IndustryID")
    return render_template('admin/industries.html', industries=industries)


# ============================================================
# USER MANAGEMENT (with role filter & pagination)
# ============================================================
@admin_bp.route('/users')
@login_required('Admin')
def users():
    role_filter = request.args.get('role', '')
    page = request.args.get('page', 1, type=int)
    per_page = 15

    union_parts = []
    if not role_filter or role_filter == 'HR':
        union_parts.append("SELECT HR_ID as ID, 'HR' as Role, Email, IsActive, NULL as FullName FROM HR_Accounts")
    if not role_filter or role_filter == 'Interviewer':
        union_parts.append("""
            SELECT ia.InterviewerID as ID, 'Interviewer' as Role, i.Email, ia.IsActive, i.FullName
            FROM Interviewer_Accounts ia
            JOIN Interviewers i ON ia.InterviewerID = i.InterviewerID
        """)
    if not role_filter or role_filter == 'Admin':
        union_parts.append("SELECT AdminID as ID, 'Admin' as Role, Email, IsActive, NULL as FullName FROM Admin_Accounts")
    if not role_filter or role_filter == 'Analyst':
        union_parts.append("SELECT AnalystID as ID, 'Analyst' as Role, Email, IsActive, NULL as FullName FROM Analyst_Accounts")
    if not role_filter or role_filter == 'Candidate':
        union_parts.append("""
            SELECT c.CandidateID as ID, 'Candidate' as Role, c.Email, ca.IsActive, c.CandidateName as FullName
            FROM CandidateAccounts ca
            JOIN Candidates c ON ca.CandidateID = c.CandidateID
        """)

    if not union_parts:
        union_parts = ["SELECT NULL as ID, NULL as Role, NULL as Email, NULL as IsActive, NULL as FullName LIMIT 0"]

    full_union = " UNION ALL ".join(union_parts)

    total_query = f"SELECT COUNT(*) as cnt FROM ({full_union}) as u"
    total = query_db(total_query, one=True)['cnt']

    data_query = f"SELECT * FROM ({full_union}) as u ORDER BY Role, Email LIMIT %s OFFSET %s"
    users_data = query_db(data_query, (per_page, (page - 1) * per_page))

    total_pages = (total + per_page - 1) // per_page
    roles = ['HR', 'Interviewer', 'Admin', 'Analyst', 'Candidate']

    return render_template('admin/users.html',
                           users=users_data,
                           page=page,
                           total_pages=total_pages,
                           current_role=role_filter,
                           roles=roles)


# ============================================================
# USER ACTIONS (lock/unlock, reset password)
# ============================================================
@admin_bp.route('/user/toggle-active', methods=['POST'])
@login_required('Admin')
def toggle_user_active():
    role = request.form.get('role')
    user_id = request.form.get('user_id')
    is_active = request.form.get('is_active') == '1'

    try:
        table_map = {
            'HR': 'HR_Accounts',
            'Interviewer': 'Interviewer_Accounts',
            'Candidate': 'CandidateAccounts',
            'Analyst': 'Analyst_Accounts',
            'Admin': 'Admin_Accounts'
        }
        id_column = {
            'HR': 'HR_ID',
            'Interviewer': 'InterviewerID',
            'Candidate': 'CandidateID',
            'Analyst': 'AnalystID',
            'Admin': 'AdminID'
        }
        table = table_map.get(role)
        col = id_column.get(role)
        if table and col:
            query_db(f"UPDATE {table} SET IsActive = %s WHERE {col} = %s", (not is_active, user_id))
            flash("User status updated.", "success")
        else:
            flash("Invalid role.", "danger")
    except:
        flash("Error updating user status.", "danger")
    return redirect(url_for('admin.users'))


@admin_bp.route('/user/reset-password', methods=['POST'])
@login_required('Admin')
def reset_password():
    role = request.form.get('role')
    user_id = request.form.get('user_id')
    new_hash = 'hashed_demo_password_123'

    try:
        table_map = {
            'HR': 'HR_Accounts',
            'Interviewer': 'Interviewer_Accounts',
            'Candidate': 'CandidateAccounts',
            'Analyst': 'Analyst_Accounts',
            'Admin': 'Admin_Accounts'
        }
        id_column = {
            'HR': 'HR_ID',
            'Interviewer': 'InterviewerID',
            'Candidate': 'CandidateID',
            'Analyst': 'AnalystID',
            'Admin': 'AdminID'
        }
        table = table_map.get(role)
        col = id_column.get(role)
        if table and col:
            query_db(f"UPDATE {table} SET PasswordHash = %s WHERE {col} = %s", (new_hash, user_id))
            flash("Password has been reset to default.", "success")
        else:
            flash("Invalid role.", "danger")
    except:
        flash("Error resetting password.", "danger")
    return redirect(url_for('admin.users'))


# ============================================================
# SYSTEM LOGS
# ============================================================
@admin_bp.route('/logs/applications')
@login_required('Admin')
def application_logs():
    page = request.args.get('page', 1, type=int)
    per_page = 20

    total = query_db("SELECT COUNT(*) as cnt FROM ApplicationStatusLog", one=True)['cnt']
    logs = query_db("SELECT * FROM ApplicationStatusLog ORDER BY ChangedAt DESC LIMIT %s OFFSET %s",
                    (per_page, (page - 1) * per_page))
    total_pages = (total + per_page - 1) // per_page

    return render_template('admin/logs_applications.html',
                           logs=logs, page=page, total_pages=total_pages)


@admin_bp.route('/logs/interviews')
@login_required('Admin')
def interview_logs():
    page = request.args.get('page', 1, type=int)
    per_page = 20

    total = query_db("SELECT COUNT(*) as cnt FROM InterviewLog", one=True)['cnt']
    logs = query_db("SELECT * FROM InterviewLog ORDER BY ChangedAt DESC LIMIT %s OFFSET %s",
                    (per_page, (page - 1) * per_page))  
    total_pages = (total + per_page - 1) // per_page

    return render_template('admin/logs_interviews.html',
                           logs=logs, page=page, total_pages=total_pages)


# ============================================================
# BACKUP & RECOVERY
# ============================================================
@admin_bp.route('/backup', methods=['GET'])
@login_required('Admin')
def backup_page():
    """Hiển thị trang backup (GET)"""
    return render_template('admin/backup.html')


@admin_bp.route('/backup/run', methods=['POST'])
@login_required('Admin')
def backup_run():
    """Thực hiện backup (POST)"""
    try:
        call_procedure_out('sp_BackupApplications', ())
        flash('Backup completed successfully.', 'success')
    except Exception as e:
        flash(f'Backup failed: {str(e)}', 'danger')
    return redirect(url_for('admin.backup_page'))