from pg_module import put_user_preferences, Charity, CharityCategory, UserCategory, get_db, UserPreferences, create_user_preferences, get_charities_for_category, get_users_for_category, get_user_preferences, Counter, get_names_of_charities, CharityAddress, get_charity

from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from typing import Optional

from pydantic import BaseModel


class UserPrefModel(BaseModel):
    userId: str
    missionStatement: Optional[str]
    pushNotifs: Optional[bool]
    prioritizeCurrentEvents: Optional[bool]

class PydanticCharityAddress(BaseModel):
    name: str
    address: str

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global matcher instance for storing recommendations
_global_matcher = None

def get_global_matcher(db):
    global _global_matcher
    if _global_matcher is None:
        from news_charity_matcher import NewsCharityMatcher
        _global_matcher = NewsCharityMatcher(db)
    return _global_matcher


@app.get("/charities/{category}")
async def get_chars(category: str, db: Session = Depends(get_db)):
    return get_charities_for_category(db, category)

@app.get("/users/{category}")
async def get_user(category: str, db: Session = Depends(get_db)):
    return get_users_for_category(db, category)

@app.get("/charity/{id}")
async def get_charity(id: str, db: Session = Depends(get_db)):
    return get_charity(db, id)

@app.put("/userpreferences")
async def update_user_preferences(userId: str, preferences: UserPrefModel, db: Session = Depends(get_db)):
    return put_user_preferences(db, userId, UserPreferences(**preferences.model_dump()))

@app.get("/userpreferences/{userId}")
async def get_prefs(userId: str, db: Session = Depends(get_db)):
    return get_user_preferences(db, userId)


@app.post("/userpreferences")
async def create_prefs(userId: str, preferences: UserPrefModel, db: Session = Depends(get_db)):
    return create_user_preferences(db, userId, UserPreferences(**preferences.model_dump()))

@app.post("/counter")
async def setCounter(userId: str, count: int, db: Session = Depends(get_db)):
    matches = db.query(Counter).filter(Counter.userid == userId)
    if matches.count() > 0:
        match = matches.first()
        match.countvalue = count
        db.commit()
        return {"count": count}
    else:
        db.add(Counter(userid=userId, countvalue=count))
        db.commit()
        return {"count": count}

@app.get("/counter/{userId}")
async def getCounter(userId: str, db: Session = Depends(get_db)):
    match = db.query(Counter).filter(Counter.userid == userId).first()
    if match:
        return {"count": match.countvalue}
    
    return {"count": 0}

@app.get("/charityaddress")
async def getCharityNames(addresses: list[str], db: Session = Depends(get_db)):
    res = get_names_of_charities(db, addresses)

    return [PydanticCharityAddress(name=charity.name, address=charity.address) for charity in res]

# AI Recommendation endpoints
@app.get("/ai/recommendations/{userId}")
async def get_ai_recommendations(userId: str, db: Session = Depends(get_db)):
    """Get AI-powered charity recommendations for a user"""
    try:
        # Try to get real AI recommendations from the matcher
        try:
            matcher = get_global_matcher(db)
            real_recommendations = matcher.get_user_recommendations(userId)
            if real_recommendations:
                print(f"Found {len(real_recommendations)} real recommendations for {userId}")
                return real_recommendations
        except Exception as e:
            print(f"Failed to get real AI recommendations: {e}")
        
        # Fallback to dummy data if real recommendations not available
        recommendations = [
            {
                "charity": {
                    "name": "World Wildlife Fund",
                    "mission": "Conservation of nature and wildlife",
                    "url": "https://wwf.org",
                    "category": "environment"
                },
                "news_article": {
                    "title": "Climate Change Accelerates",
                    "description": "New report shows alarming rates of temperature increase",
                    "url": "https://example.com/news/1",
                    "category": "environment",
                    "urgencyScore": 9.5,
                    "publishedAt": "2025-09-14T05:28:00Z"
                },
                "reason": "Urgent need for environmental conservation due to recent climate reports",
                "relevance_score": 0.95
            },
            {
                "charity": {
                    "name": "Doctors Without Borders",
                    "mission": "Medical aid in crisis zones",
                    "url": "https://doctors.org",
                    "category": "health"
                },
                "news_article": {
                    "title": "New Pandemic Threat",
                    "description": "New virus spreading rapidly",
                    "url": "https://example.com/news/2",
                    "category": "health",
                    "urgencyScore": 8.7,
                    "publishedAt": "2025-09-14T05:25:00Z"
                },
                "reason": "Immediate medical assistance required for affected populations",
                "relevance_score": 0.92
            }
        ]
        return recommendations
    except Exception as e:
        return {"error": str(e)}

@app.get("/ai/news")
async def get_recent_news():
    """Get recent news articles for AI analysis"""
    try:
        # This would connect to the news matcher service
        news = [
            {
                "title": "Global Warming Accelerates",
                "description": "New report shows alarming rates of temperature increase",
                "link": "https://example.com/news/1",
                "category": "environment"
            },
            {
                "title": "Breakthrough in Cancer Research",
                "description": "Scientists discover new treatment for a rare form of cancer",
                "link": "https://example.com/news/2",
                "category": "health"
            }
        ]
        return news
    except Exception as e:
        return {"error": str(e)}