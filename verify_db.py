import sys
sys.path.append('.')
from models.db import query_db

try:
    print("Trying to query Candidates...")
    cands = query_db("SELECT * FROM Candidates LIMIT 1")
    print("Candidates:", cands)
    
    print("Trying to query HR_Accounts...")
    hr = query_db("SELECT * FROM HR_Accounts LIMIT 1")
    print("HR_Accounts:", hr)
    
except Exception as e:
    print("Exception:", e)
