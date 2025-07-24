#!/bin/bash

# SkeifCV Deployment Script

echo "🚀 Setting up SkeifCV..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    echo "Please install Python 3.8+ and try again."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install -r requirements.txt

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p uploads generated_cvs

# Run the application
echo "✅ Setup complete!"
echo ""
echo "🌟 Starting SkeifCV..."
echo "📱 Open your browser and go to: http://localhost:8000"
echo "❌ Press Ctrl+C to stop the server"
echo ""

python main.py