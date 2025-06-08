from sqlalchemy import Column, DateTime, Integer, String, ForeignKey, Boolean, func
from sqlalchemy.orm import relationship
from .connection import Base

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    medic_id = Column(Integer, ForeignKey("medics.id"), nullable=True)
    first_name = Column(String)
    last_name = Column(String)
    email = Column(String, unique=True, index=True)
    password = Column(String)

    #TODO: Maybe delete this column
    share_data_with_medic = Column(Boolean, default=False)
    
    medic = relationship("Medic", back_populates="patients")
    health_data = relationship("UserHealthData", back_populates="user", uselist=False, cascade="all, delete-orphan")
    medical_records = relationship("UserMedicalRecord", back_populates="user", cascade="all, delete-orphan")
    appointments = relationship("Appointment", back_populates="user", cascade="all, delete-orphan")
    appointment_suggestions = relationship("AppointmentSuggestion", back_populates="user", cascade="all, delete-orphan")

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
    medical_services = relationship("MedicalService", back_populates="medic", cascade="all, delete-orphan")
    appointments = relationship("Appointment", back_populates="medic", cascade="all, delete-orphan")
    appointment_suggestions = relationship("AppointmentSuggestion", back_populates="medic", cascade="all, delete-orphan")
    availabilities = relationship("MedicAvailability", back_populates="medic", cascade="all, delete-orphan")

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

class MedicalServiceType(Base):
    __tablename__ = 'medical_service_types'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String, unique=True, index=True)

    definition = relationship("MedicalService", back_populates="type", cascade="all, delete-orphan")

    class Config:
        from_attributes = True

class MedicalService(Base):
    __tablename__ = 'medical_services'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    medic_id = Column(Integer, ForeignKey("medics.id"))
    medical_service_type_id = Column(Integer, ForeignKey("medical_service_types.id"))

    name = Column(String)
    price = Column(String)
    duration_minutes = Column(String)

    medic = relationship("Medic", back_populates="medical_services")
    type = relationship("MedicalServiceType", back_populates="definition")
    appointments = relationship("Appointment", back_populates="medical_service", cascade="save-update, merge")
    appointments_suggestions = relationship("AppointmentSuggestion", back_populates="medical_service", cascade="all, delete-orphan")

    class Config:
        from_attributes = True

class Appointment(Base):
    __tablename__ = 'appointments'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    medic_id = Column(Integer, ForeignKey("medics.id"))
    medical_service_id = Column(Integer, ForeignKey("medical_services.id"))

    medical_service_name = Column(String, nullable=False)
    medical_service_price = Column(String, nullable=False)
    medical_service_duration_minutes = Column(String, nullable=False)
    
    address = Column(String)
    appointment_start = Column(String)
    appointment_end = Column(String)
    appointment_status = Column(String, default="pending")

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="appointments")
    medic = relationship("Medic", back_populates="appointments")
    medical_service = relationship("MedicalService", back_populates="appointments")

    class Config:
        from_attributes = True

class AppointmentSuggestion(Base):
    __tablename__ = "appointment_suggestions"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    medic_id = Column(Integer, ForeignKey("medics.id"))
    medical_service_id = Column(Integer, ForeignKey("medical_services.id"))

    status = Column(String, default="pending", nullable=False, index=True)
    reason = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="appointment_suggestions")
    medic = relationship("Medic", back_populates="appointment_suggestions")
    medical_service = relationship("MedicalService", back_populates="appointments_suggestions")

    class Config:
        from_attributes = True

class MedicAvailability(Base):
    __tablename__ = 'medic_availabilities'

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    medic_id = Column(Integer, ForeignKey("medics.id"), index=True)

    weekday = Column(String, nullable=False, index=True)
    start_time = Column(String)
    end_time = Column(String)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    medic = relationship("Medic", back_populates="availabilities")

    class Config:
        from_attributes = True
