#!/bin/bash

echo "🚀 Setting up Giving Tree for Avalanche Hackathon..."

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "❌ .env file not found!"
    echo "Please create .env file with your API keys first."
    echo "See the template in the project documentation."
    exit 1
fi

# Activate virtual environment
echo "🐍 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📦 Installing Python dependencies..."
pip install -r api/requirements.txt
pip install -r contract_wrapper_api/requirements.txt
pip install -r rss_feed/requirements.txt

# Update contract addresses
echo "🔄 Updating contract addresses to Avalanche..."
python3 update_contract_addresses.py

# Setup databases
echo "🗄️  Setting up databases..."
python3 setup_database.py

echo "✅ Setup complete!"
echo ""
echo "🎉 Your Giving Tree is ready for the Avalanche hackathon!"
echo ""
echo "To start the system:"
echo "1. Backend services: ./start_services.sh"
echo "2. Flutter app: cd app && flutter run"
