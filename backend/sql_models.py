from sqlalchemy import Column, Integer, Float, String, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from .database import Base

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    first_name = Column(String)
    last_name = Column(String)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    medical_records = relationship("MedicalRecords", back_populates="user") # The medical record for each user
    is_admin = Column(Boolean, default=False)

    class Config:
        orm_mode: True


class MedicalRecords(Base):
    __tablename__ = 'medical_records'

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id')) # The user ID whose record belongs to
    user = relationship("User", back_populates="medical_records")
    male = Column(Integer)
    age = Column(Integer)
    education = Column(Integer)
    currentSmoker = Column(Integer)
    cigsPerDay = Column(Integer)
    BPMeds = Column(Integer)
    prevalentStroke = Column(Integer)  
    prevalentHyp = Column(Integer)
    diabetes = Column(Integer)
    totChol = Column(Integer)
    sysBP = Column(Float)
    diaBP = Column(Float)
    BMI = Column(Float)
    heartRate = Column(Integer)
    glucose = Column(Integer)
    TenYearCHD = Column(Integer)