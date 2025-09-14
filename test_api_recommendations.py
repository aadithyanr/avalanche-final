#!/usr/bin/env python3

import requests
import json

def test_api_recommendations():
    """Test the API recommendation endpoint"""
    print("🧪 Testing API Recommendation Endpoint...")
    
    try:
        # Test with the user that has recommendations
        response = requests.get("http://localhost:8000/ai/recommendations/test-user")
        
        if response.status_code == 200:
            recommendations = response.json()
            print(f"✅ API returned {len(recommendations)} recommendations")
            
            for i, rec in enumerate(recommendations, 1):
                print(f"  {i}. {rec['charity']['name']} - {rec['reason']}")
                print(f"     News: {rec['news_article']['title']}")
                print(f"     Score: {rec['relevance_score']}")
                print()
        else:
            print(f"❌ API returned status {response.status_code}")
            print(response.text)
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_api_recommendations()
