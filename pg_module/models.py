from sqlalchemy import Column, Text, ForeignKey, String, Boolean, Integer
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.dialects.mysql import VARCHAR


Base = declarative_base()

class CharityCategory(Base):
    __tablename__ = 'charitycategory'

    category = Column(Text, nullable=False, primary_key=True)
    charityname = Column(Text, nullable=False, primary_key=True)

class UserCategory(Base):
    __tablename__ = 'usercategory'

    category = Column(Text, nullable=False, primary_key=True)
    userid = Column(Text, nullable=False, primary_key=True)

class Charity(Base):
    __tablename__ = 'charity'

    name = Column(String(255), nullable=False, unique=True, primary_key=True)
    mission = Column(Text)
    url = Column(String(2083))

class UserPreferences(Base):
    __tablename__ = 'userpreferences'

    userid = Column(VARCHAR(100), primary_key=True)
    mission_statement = Column(Text)
    push_notifications = Column(Boolean, default=False)
    prioritize_current_events   = Column(Boolean, default=False)

class Counter(Base):
    __tablename__ = 'counter'

    userid = Column(VARCHAR(255), primary_key=True)
    countvalue = Column(Integer)

class CharityAddress(Base):
    __tablename__ = 'charityaddress'
    
    id = Column(Integer, primary_key=True)
    name = Column(String(255), nullable=False)
    address = Column(String(100), nullable=False)