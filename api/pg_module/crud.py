from sqlalchemy.orm import Session
from typing import Optional, List
from .models import UserCategory, CharityCategory, Charity, UserPreferences, CharityAddress

def get_users_for_category(db: Session, category: str) -> Optional[List[UserCategory]]:
    return db.query(UserCategory).filter(UserCategory.category == category).all()

def get_charities_for_category(db: Session, category: str)  -> Optional[List[Charity]]:
    # I want to return rows from Charity where there exists a row in CharityCategory with the same category and that charity name

    return db.query(Charity).join(CharityCategory, Charity.name == CharityCategory.charityname).filter(CharityCategory.category == category).all()

def get_charity(db: Session, id: str) -> Optional[Charity]:
    return db.query(Charity).filter(Charity.name == id).first()

def put_user_preferences(db: Session, userId: str, preferences: UserPreferences) -> None:    
    db.query(UserPreferences).filter(UserPreferences.userid == userId).update(preferences)
    db.commit()
    db.refresh(preferences)

def get_user_preferences(db: Session, userId: str) -> Optional[UserPreferences]:
    return db.query(UserPreferences).filter(UserPreferences.userid == userId).first()

def create_user_preferences(db: Session, userId: str, preferences: UserPreferences) -> None:
    db.add(preferences)
    db.commit()
    db.refresh(preferences)

def get_names_of_charities(db: Session, addresses: list[str]) -> Optional[List[CharityAddress]]:
    return db.query(CharityAddress).filter(CharityAddress.address.in_(addresses)).all()