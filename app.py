from flask import Flask, render_template
from flask_wtf.csrf import CSRFProtect
from config import Config
import os
from flask import session
from models.db import query_db

app = Flask(__name__)
app.config.from_object(Config)

csrf = CSRFProtect(app)

os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# Import Blueprints
from controllers.auth import auth_bp
from controllers.candidate import candidate_bp
from controllers.hr import hr_bp
from controllers.interviewer import interviewer_bp
from controllers.analyst import analyst_bp
from controllers.admin import admin_bp

# Register Blueprints
app.register_blueprint(auth_bp)
app.register_blueprint(candidate_bp, url_prefix='/candidate')
app.register_blueprint(hr_bp, url_prefix='/hr')
app.register_blueprint(interviewer_bp, url_prefix='/interviewer')
app.register_blueprint(analyst_bp, url_prefix='/analyst')
app.register_blueprint(admin_bp, url_prefix='/admin')

@app.route('/')
def home():
    from models.db import query_db
    try:
        total_jobs = query_db("SELECT COUNT(*) as count FROM JobPositions WHERE IsDeleted = FALSE AND Status = 'Open'", one=True)['count']
        total_employers = query_db("SELECT COUNT(*) as count FROM Employers WHERE IsDeleted = FALSE", one=True)['count']
        featured_jobs = query_db("""
            SELECT jp.*, e.EmployerName 
            FROM JobPositions jp 
            JOIN Employers e ON jp.EmployerID = e.EmployerID 
            WHERE jp.IsDeleted = FALSE AND jp.Status = 'Open' 
            ORDER BY jp.CreatedAt DESC LIMIT 6
        """)
    except Exception as e:
        import traceback
        traceback.print_exc()
        total_jobs = 0
        total_employers = 0
        featured_jobs = []
        
    return render_template('home.html', total_jobs=total_jobs, total_employers=total_employers, featured_jobs=featured_jobs)

@app.context_processor
def inject_unread_notifications():
    unread_candidate = 0
    unread_interviewer = 0
    if 'user_id' in session:
        role = session.get('role')
        if role == 'Candidate':
            try:
                count = query_db(
                    "SELECT COUNT(*) as cnt FROM CandidateNotifications WHERE CandidateID = %s AND IsRead = FALSE",
                    (session['user_id'],),
                    one=True
                )
                unread_candidate = count['cnt'] if count else 0
            except:
                unread_candidate = 0
        elif role == 'Interviewer':
            if 'interviewer_id' in session:
                try:
                    count = query_db(
                        "SELECT COUNT(*) as cnt FROM InterviewerNotifications WHERE InterviewerID = %s AND IsRead = FALSE",
                        (session['interviewer_id'],),
                        one=True
                    )
                    unread_interviewer = count['cnt'] if count else 0
                except:
                    unread_interviewer = 0
    return {'unread_candidate': unread_candidate, 'unread_interviewer': unread_interviewer}

if __name__ == '__main__':
    app.run(debug=True, port=5000)
