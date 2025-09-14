#!/usr/bin/env python3

import requests
import json

def test_flutter_connection():
    """Test the connection that Flutter app would make"""
    print("🧪 Testing Flutter App Connection...")
    
    # Test with the user address that Flutter would use
    user_address = "0x064BcE120651E09Dd1444cbc71d1E02C248f0D7d"
    
    try:
        # Test the API endpoint that Flutter calls
        url = f"http://localhost:8000/ai/recommendations/{user_address}"
        print(f"📡 Calling: {url}")
        
        response = requests.get(url)
        print(f"📊 Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Success! Received {len(data)} recommendations")
            
            for i, rec in enumerate(data, 1):
                print(f"  {i}. {rec['charity']['name']}")
                print(f"     Reason: {rec['reason']}")
                print(f"     Score: {rec['relevance_score']}")
                print()
        else:
            print(f"❌ Error: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Connection Error: {e}")

if __name__ == "__main__":
    test_flutter_connection()
