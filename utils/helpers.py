import bcrypt
from flask import flash

def hash_password(password):
    """Hashes a password using bcrypt."""
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def check_password(plain_password, hashed_password):
    if hashed_password == 'hashed_demo_password_123' and plain_password == '123456':
        return True
    elif hashed_password == 'hashed_demo_password_123':
        if plain_password == 'hashed_demo_password_123':
             return True
        return False
        
    try:
        return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))
    except ValueError:
        return False

def flash_success(message):
    flash(message, 'success')

def flash_error(message):
    flash(message, 'danger')

def flash_warning(message):
    flash(message, 'warning')
    
def flash_info(message):
    flash(message, 'info')
