from flask import Blueprint, render_template, request, redirect, url_for, flash, session
from models.db import call_procedure_out, query_db
from utils.helpers import hash_password, check_password

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        role = request.form.get('role')
        
        if role == 'Candidate':
            candidate = query_db("""
                SELECT ca.CandidateID, ca.PasswordHash, c.CandidateName 
                FROM CandidateAccounts ca
                JOIN Candidates c ON ca.CandidateID = c.CandidateID
                WHERE ca.Email = %s
            """, (email,), one=True)
            if candidate:
                if check_password(password, candidate['PasswordHash']):
                    session['user_id'] = candidate['CandidateID']
                    session['role'] = 'Candidate'
                    session['display_name'] = candidate['CandidateName']
                    if not session.get('welcome_seen'):
                        session['welcome_seen'] = True
                        session['show_welcome'] = True
                    return redirect(url_for('candidate.dashboard'))
                else:
                    return render_template('login.html', login_error='Invalid password', email=email, role=role)
            else:
                return render_template('login.html', login_error='Account not found', email=email, role=role)
                
        elif role == 'HR':
            hr = query_db("""
                SELECT h.HR_ID, h.EmployerID, h.PasswordHash, h.IsActive, e.EmployerName
                FROM HR_Accounts h
                JOIN Employers e ON h.EmployerID = e.EmployerID
                WHERE h.Email = %s
            """, (email,), one=True)
            if hr:
                if not hr['IsActive']:
                    return render_template('login.html', login_error='Account locked', email=email, role=role)
                elif check_password(password, hr['PasswordHash']):
                    session['hr_id'] = hr['HR_ID']
                    session['employer_id'] = hr['EmployerID']
                    session['role'] = 'HR'
                    session['display_name'] = hr['EmployerName'] or 'HR Manager'
                    return redirect(url_for('hr.dashboard'))
                else:
                    return render_template('login.html', login_error='Invalid password', email=email, role=role)
            else:
                return render_template('login.html', login_error='Account not found', email=email, role=role)
                
        elif role == 'Interviewer':
            interv = query_db("""
                SELECT i.InterviewerID, i.EmployerID, i.FullName, a.PasswordHash, a.IsActive 
                FROM Interviewers i JOIN Interviewer_Accounts a ON i.InterviewerID = a.InterviewerID 
                WHERE i.Email = %s
            """, (email,), one=True)
            if interv:
                if not interv['IsActive']:
                    return render_template('login.html', login_error='Account locked', email=email, role=role)
                elif check_password(password, interv['PasswordHash']):
                    session['interviewer_id'] = interv['InterviewerID']
                    session['employer_id'] = interv['EmployerID']
                    session['role'] = 'Interviewer'
                    session['display_name'] = interv['FullName']
                    return redirect(url_for('interviewer.schedule'))
                else:
                    return render_template('login.html', login_error='Invalid password', email=email, role=role)
            else:
                return render_template('login.html', login_error='Account not found', email=email, role=role)
                
        elif role == 'Analyst':
            analyst = query_db("SELECT AnalystID, PasswordHash FROM Analyst_Accounts WHERE Email = %s", (email,), one=True)
            if analyst:
                if check_password(password, analyst['PasswordHash']):
                    session['analyst_id'] = analyst['AnalystID']
                    session['role'] = 'Analyst'
                    session['display_name'] = 'Analyst'
                    return redirect(url_for('analyst.dashboard'))
                else:
                    return render_template('login.html', login_error='Invalid password', email=email, role=role)
            else:
                return render_template('login.html', login_error='Account not found', email=email, role=role)
                
        elif role == 'Admin':
            admin = query_db("SELECT AdminID, PasswordHash FROM Admin_Accounts WHERE Email = %s", (email,), one=True)
            if admin:
                if check_password(password, admin['PasswordHash']):
                    session['admin_id'] = admin['AdminID']
                    session['role'] = 'Admin'
                    session['display_name'] = 'Admin'
                    return redirect(url_for('admin.dashboard'))
                else:
                    return render_template('login.html', login_error='Invalid password', email=email, role=role)
            else:
                return render_template('login.html', login_error='Account not found', email=email, role=role)

    return render_template('login.html')

@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form.get('name')
        gender = request.form.get('gender')
        dob_str = request.form.get('dob')
        email = request.form.get('email')
        phone = request.form.get('phone')
        address = request.form.get('address')
        education = request.form.get('education')
        gpa_str = request.form.get('gpa')
        exp_str = request.form.get('exp')
        password = request.form.get('password')
        
        try:
            import datetime
            dob = None
            if dob_str:
                try:
                    dob = datetime.datetime.strptime(dob_str, '%Y-%m-%d').date()
                except ValueError:
                    try:
                        dob = datetime.datetime.strptime(dob_str, '%d-%m-%Y').date()
                    except ValueError:
                        dob = dob_str

            gpa = None
            if gpa_str:
                try:
                    gpa_clean = gpa_str.replace(',', '.')
                    gpa = float(gpa_clean)
                except ValueError:
                    gpa = 0.0
            
            exp = 0
            if exp_str:
                try:
                    exp = int(exp_str)
                except ValueError:
                    exp = 0

            hashed_pw = hash_password(password)
            
            args = [name, gender, dob, email, phone, address, education, gpa, exp, hashed_pw, '']
            
            results, out_args = call_procedure_out('sp_RegisterCandidate', args)
            
            result_msg = out_args[10] if out_args and len(out_args) > 10 else "No response from database."
            
            if result_msg and 'success' in result_msg.lower():
                flash('Registration successful. Please login.', 'success')
                return redirect(url_for('auth.login'))
            else:
                flash(f"Registration failed: {result_msg}", 'danger')
                
        except Exception as e:
            import traceback
            from flask import current_app
            
            traceback.print_exc()
            if current_app:
                current_app.logger.error(f"Registration Error:\n{traceback.format_exc()}")
                
            flash(f"Error details: {str(e)}", 'danger')

    return render_template('register.html')

@auth_bp.route('/logout', methods=['POST'])
def logout():
    session.pop('user_id', None)
    session.pop('hr_id', None)
    session.pop('employer_id', None)
    session.pop('interviewer_id', None)
    session.pop('analyst_id', None)
    session.pop('admin_id', None)
    session.pop('role', None)
    session.pop('display_name', None)
    session.pop('welcome_seen', None)
    session.pop('show_welcome', None)
    flash('You have been logged out.', 'info')
    return redirect(url_for('auth.login'))
