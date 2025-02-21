from sqlalchemy import Column, Integer, String, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from .database import Base

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    first_name = Column(String)
    last_name = Column(String)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    is_admin = Column(Boolean, default=False)
    
    medical_records = relationship("MedicalRecords", uselist=True, back_populates="user")
    medical_data = relationship("UserMedicalData", uselist=True, back_populates="user")
    personal_data = relationship("UserPersonalData", uselist=False, back_populates="user")

    class Config:
        orm_mode: True


class UserPersonalData(Base):
    __tablename__ = 'user_personal_data'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey('users.id'))
    user = relationship("User", back_populates="personal_data")

    birth_date = Column(String)
    height = Column(String)
    weight = Column(String)
    is_male = Column(String)
    education = Column(String)
    current_smoker = Column(String)
    cigs_per_day = Column(String)
    BPMeds = Column(String)
    prevalentStroke = Column(String)  
    prevalentHyp = Column(String)
    diabetes = Column(String)
    totChol = Column(String)
    glucose = Column(String)

    class Config:
        orm_mode: True

class UserMedicalData(Base):
    __tablename__ = 'user_medical_data'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey('users.id'))
    user = relationship("User", back_populates="medical_data")

    sysBP = Column(String)
    diaBP = Column(String)
    BMI = Column(String)
    heartRate = Column(String)

    class Config:
        orm_mode: True


class MedicalRecords(Base):
    __tablename__ = 'medical_records'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey('users.id'))
    medical_data_id = Column(Integer, ForeignKey('user_medical_data.id'))
    personal_data_id = Column(Integer, ForeignKey('user_personal_data.id'))

    user = relationship("User", back_populates="medical_records")
    medical_data = relationship("UserMedicalData")
    personal_data = relationship("UserPersonalData")
    
    TenYearCHD = Column(String)

    class Config:
        orm_mode: True
