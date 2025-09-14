#!/bin/bash

echo "🚀 Starting Giving Tree backend services..."

# Activate virtual environment
source venv/bin/activate

# Start PostgreSQL if not running
echo "🗄️  Starting PostgreSQL..."
brew services start postgresql@14

# Start all services in background
echo "🌐 Starting API services..."

# Main API (port 8000)
echo "Starting Main API on port 8000..."
cd api && python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload &
API_PID=$!

# Contract Wrapper API (port 8001)
echo "Starting Contract API on port 8001..."
cd ../contract_wrapper_api && python3 -m uvicorn main:app --host 0.0.0.0 --port 8001 --reload &
CONTRACT_PID=$!

# RSS Feed (port 8002)
echo "Starting RSS Feed on port 8002..."
cd ../rss_feed && python3 -m uvicorn rss_script:app --host 0.0.0.0 --port 8002 --reload &
RSS_PID=$!

# News Matcher
echo "Starting News Matcher..."
cd .. && python3 run_matcher.py &
MATCHER_PID=$!

echo "✅ All services started!"
echo ""
echo "Services running:"
echo "- Main API: http://localhost:8000"
echo "- Contract API: http://localhost:8001"
echo "- RSS Feed: http://localhost:8002"
echo "- News Matcher: Running in background"
echo ""
echo "To stop all services: ./stop_services.sh"
echo "To view logs: tail -f logs/*.log"

# Save PIDs for stopping later
echo $API_PID > .api_pid
echo $CONTRACT_PID > .contract_pid
echo $RSS_PID > .rss_pid
echo $MATCHER_PID > .matcher_pid
