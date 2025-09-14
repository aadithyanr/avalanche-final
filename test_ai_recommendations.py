#!/usr/bin/env python3

import os
import sys
from dotenv import load_dotenv

# Add the current directory to Python path
sys.path.append('.')

from news_charity_matcher import NewsCharityMatcher
from pg_module import get_db

def test_ai_recommendations():
    """Test AI recommendation generation"""
    print("🧪 Testing AI Recommendation Generation...")
    
    # Get database connection
    db = next(get_db())
    
    # Create matcher instance
    matcher = NewsCharityMatcher(db)
    
    # Create a test article
    test_article = {
        "title": "Climate Change Crisis: Urgent Action Needed",
        "description": "Scientists warn that climate change is accelerating faster than predicted, requiring immediate environmental action and conservation efforts.",
        "link": "https://example.com/climate-crisis",
        "published": "2025-09-14T06:30:00Z"
    }
    
    print(f"📰 Processing test article: {test_article['title']}")
    
    # Process the article
    try:
        # Check if article is relevant
        is_relevant = matcher.is_relevant_article(test_article["title"], test_article["description"])
        print(f"✅ Article relevant: {is_relevant}")
        
        if is_relevant:
            # Find matching categories
            matching_categories, subscribers = matcher.find_matching_categories(test_article)
            print(f"📊 Found {len(matching_categories)} matching categories")
            
            if matching_categories:
                # Find similar charities
                similar_charities = matcher.find_similar_charities(test_article)
                print(f"🏛️ Found {len(similar_charities)} similar charities")
                
                if similar_charities:
                    # Store recommendations for test user
                    test_user_id = "test-user"
                    for charity in similar_charities:
                        reason = f"Based on recent news: {test_article['title']}"
                        relevance_score = 0.9
                        matcher.store_recommendation(
                            test_user_id,
                            charity["name"],
                            test_article,
                            reason,
                            relevance_score
                        )
                    
                    # Get recommendations
                    recommendations = matcher.get_user_recommendations(test_user_id)
                    print(f"🎯 Generated {len(recommendations)} recommendations for {test_user_id}")
                    
                    for i, rec in enumerate(recommendations, 1):
                        print(f"  {i}. {rec['charity']['name']} - {rec['reason']}")
                else:
                    print("❌ No charities found")
            else:
                print("❌ No matching categories found")
        else:
            print("❌ Article not relevant")
            
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_ai_recommendations()
