import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.getenv('SECRET_KEY', 'dev_key')
    WTF_CSRF_SECRET_KEY = os.getenv('WTF_CSRF_SECRET_KEY', 'csrf_dev_key')
    
    # Database configurations
    DB_HOST = os.getenv('DB_HOST', 'localhost')
    DB_USER = os.getenv('DB_USER', 'root')
    DB_PASSWORD = os.getenv('DB_PASSWORD', '')
    DB_NAME = os.getenv('DB_NAME', 'RecruitmentDB')
    
    # Upload configuration
    UPLOAD_FOLDER = os.path.join('static', 'uploads', 'cvs')
    MAX_CONTENT_LENGTH = 5 * 1024 * 1024  # 5MB max file size
