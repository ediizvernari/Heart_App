# backend/database/sql_models.py

from sqlalchemy import Column, DateTime, Integer, String, ForeignKey, Boolean, func
from sqlalchemy.orm import relationship
from .connection import Base

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    first_name = Column(String)
    last_name = Column(String)
    email = Column(String, unique=True, index=True)
    password = Column(String)

    share_data_with_medic = Column(Boolean, default=False)
    
    medic_id = Column(Integer, ForeignKey("medics.id"), nullable=True)
    medic = relationship("Medic", back_populates="patients")

    health_data = relationship(
        "UserHealthData",
        back_populates="user",
        uselist=False,
        cascade="all, delete-orphan"
    )
    medical_records = relationship(
        "UserMedicalRecord",
        back_populates="user",
        cascade="all, delete-orphan"
    )

    class Config:
        from_attributes = True


class Medic(Base):
    __tablename__ = 'medics'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    first_name = Column(String)
    last_name = Column(String)
    email = Column(String, unique=True, index=True)
    password = Column(String)

    street_address = Column(String)

    city_id = Column(Integer, ForeignKey("cities.id"))
    city = relationship("City")

    patients = relationship("User", back_populates="medic")

    class Config:
        from_attributes = True


class Country(Base):
    __tablename__ = 'countries'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String, unique=True, index=True)

    cities = relationship("City", back_populates="country", cascade="all, delete-orphan")

    class Config:
        from_attributes = True


class City(Base):
    __tablename__ = 'cities'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String, index=True)
    country_id = Column(Integer, ForeignKey("countries.id"))

    country = relationship("Country", back_populates="cities")

    class Config:
        from_attributes = True


class UserHealthData(Base):
    __tablename__ = 'user_health_data'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    user = relationship("User", back_populates="health_data")
    
    birth_date = Column(String)
    height = Column(String)
    weight = Column(String)
    cholesterol_level = Column(String)
    ap_hi = Column(String)
    ap_lo = Column(String)

    class Config:
        from_attributes = True


class UserMedicalRecord(Base):
    __tablename__ = 'user_medical_records'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("User", back_populates="medical_records")

    cvd_risk = Column(String)
    birth_date = Column(String)
    height = Column(String)
    weight = Column(String)
    cholesterol_level = Column(String)
    ap_hi = Column(String)
    ap_lo = Column(String)

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    class Config:
        from_attributes = True
