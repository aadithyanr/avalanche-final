#!/usr/bin/env python3

import os
import sys
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

# Add the current directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from pg_module.models import Base, Charity, CharityCategory, UserPreferences, Counter, CharityAddress

# Load environment variables
load_dotenv()

def setup_database():
    # Database connection
    engine = create_engine(
        f"postgresql://{os.getenv('PG_USER')}:{os.getenv('PG_PASSWORD')}@{os.getenv('PG_HOST')}:{os.getenv('PG_PORT')}/{os.getenv('PG_DATABASE_NAME')}"
    )
    
    # Create all tables
    Base.metadata.create_all(bind=engine)
    print("✅ Database tables created")
    
    # Create session
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db = SessionLocal()
    
    try:
        # Sample charity data
        charities = [
            Charity(name="Red Cross", mission="Emergency disaster relief and humanitarian aid", url="https://redcross.org"),
            Charity(name="World Wildlife Fund", mission="Conservation of nature and wildlife", url="https://wwf.org"),
            Charity(name="UNICEF", mission="Children's rights and emergency relief", url="https://unicef.org"),
            Charity(name="Doctors Without Borders", mission="Medical aid in crisis zones", url="https://msf.org"),
            Charity(name="Amnesty International", mission="Human rights advocacy", url="https://amnesty.org"),
            Charity(name="Greenpeace", mission="Environmental protection", url="https://greenpeace.org"),
            Charity(name="Oxfam", mission="Poverty and inequality relief", url="https://oxfam.org"),
            Charity(name="Save the Children", mission="Children's welfare and education", url="https://savethechildren.org"),
        ]
        
        # Add charities
        for charity in charities:
            db.add(charity)
        print("✅ Sample charities added")
        
        # Sample charity categories
        charity_categories = [
            CharityCategory(category="disaster_relief", charityname="Red Cross"),
            CharityCategory(category="disaster_relief", charityname="UNICEF"),
            CharityCategory(category="disaster_relief", charityname="Doctors Without Borders"),
            CharityCategory(category="environment", charityname="World Wildlife Fund"),
            CharityCategory(category="environment", charityname="Greenpeace"),
            CharityCategory(category="health", charityname="Doctors Without Borders"),
            CharityCategory(category="health", charityname="UNICEF"),
            CharityCategory(category="human_rights", charityname="Amnesty International"),
            CharityCategory(category="human_rights", charityname="UNICEF"),
            CharityCategory(category="poverty", charityname="Oxfam"),
            CharityCategory(category="poverty", charityname="Save the Children"),
            CharityCategory(category="education", charityname="UNICEF"),
            CharityCategory(category="education", charityname="Save the Children"),
        ]
        
        # Add charity categories
        for category in charity_categories:
            db.add(category)
        print("✅ Charity categories added")
        
        # Sample charity addresses (for blockchain donations)
        charity_addresses = [
            CharityAddress(name="Red Cross", address="0x1234567890123456789012345678901234567890"),
            CharityAddress(name="World Wildlife Fund", address="0x2345678901234567890123456789012345678901"),
            CharityAddress(name="UNICEF", address="0x3456789012345678901234567890123456789012"),
            CharityAddress(name="Doctors Without Borders", address="0x4567890123456789012345678901234567890123"),
            CharityAddress(name="Amnesty International", address="0x5678901234567890123456789012345678901234"),
            CharityAddress(name="Greenpeace", address="0x6789012345678901234567890123456789012345"),
            CharityAddress(name="Oxfam", address="0x7890123456789012345678901234567890123456"),
            CharityAddress(name="Save the Children", address="0x8901234567890123456789012345678901234567"),
        ]
        
        # Add charity addresses
        for address in charity_addresses:
            db.add(address)
        print("✅ Charity addresses added")
        
        # Commit all changes
        db.commit()
        print("✅ Database setup complete!")
        
    except Exception as e:
        print(f"❌ Error setting up database: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    setup_database()