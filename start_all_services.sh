#!/bin/bash

echo "🚀 Starting all Giving Tree backend services..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "❌ Virtual environment not found. Please run setup first."
    exit 1
fi

# Activate virtual environment
source venv/bin/activate

echo "📊 Starting Main API (Port 8000)..."
python -m uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload &
MAIN_PID=$!

echo "⛓️  Starting Contract Wrapper API (Port 8001)..."
python -m uvicorn contract_wrapper_api.main:app --host 0.0.0.0 --port 8001 --reload &
CONTRACT_PID=$!

echo "🤖 Starting AI News Matcher..."
python run_matcher.py &
AI_PID=$!

echo ""
echo "✅ All services started!"
echo "📊 Main API: http://localhost:8000"
echo "⛓️  Contract API: http://localhost:8001"
echo "🤖 AI Matcher: Running in background"
echo ""
echo "Press Ctrl+C to stop all services"

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Stopping all services..."
    kill $MAIN_PID $CONTRACT_PID $AI_PID 2>/dev/null
    echo "✅ All services stopped"
    exit 0
}

# Set trap to cleanup on script exit
trap cleanup SIGINT SIGTERM

# Wait for any process to exit
wait
