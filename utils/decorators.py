from functools import wraps
from flask import session, redirect, url_for, flash

def login_required(role=None):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if 'user_id' not in session and 'employer_id' not in session and 'admin_id' not in session and 'analyst_id' not in session and 'interviewer_id' not in session:

                pass
            
            if 'role' not in session:
                flash('Please log in to access this page.', 'warning')
                return redirect(url_for('auth.login'))
            
            if role and session.get('role') != role:
                flash(f'Access denied. You must be logged in as a {role}.', 'danger')
                return redirect(url_for('home'))
                
            return f(*args, **kwargs)
        return decorated_function
    return decorator
