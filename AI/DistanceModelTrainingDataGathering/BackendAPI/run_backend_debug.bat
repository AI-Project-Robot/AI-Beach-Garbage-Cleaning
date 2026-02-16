@echo off
echo Starting Backend Setup... > backend_debug.log
pip install -r requirements.txt >> backend_debug.log 2>&1
echo Dependencies installed. >> backend_debug.log
python app.py >> backend_debug.log 2>&1
