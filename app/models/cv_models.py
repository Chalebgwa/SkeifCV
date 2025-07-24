from pydantic import BaseModel, EmailStr
from typing import List, Optional
from datetime import date


class PersonalInfo(BaseModel):
    full_name: str
    email: EmailStr
    phone: str
    location: str
    website: Optional[str] = None
    linkedin: Optional[str] = None
    github: Optional[str] = None
    summary: Optional[str] = None
    profile_image: Optional[str] = None


class WorkExperience(BaseModel):
    job_title: str
    company: str
    location: str
    start_date: date
    end_date: Optional[date] = None
    current: bool = False
    description: List[str]


class Education(BaseModel):
    degree: str
    institution: str
    location: str
    start_date: date
    end_date: Optional[date] = None
    current: bool = False
    gpa: Optional[str] = None
    description: Optional[List[str]] = None


class Skill(BaseModel):
    name: str
    level: Optional[str] = None  # e.g., "Beginner", "Intermediate", "Advanced", "Expert"
    category: Optional[str] = None  # e.g., "Programming", "Languages", "Tools"


class Project(BaseModel):
    name: str
    description: str
    technologies: List[str]
    url: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None


class Certificate(BaseModel):
    name: str
    issuer: str
    date_issued: date
    expiry_date: Optional[date] = None
    credential_id: Optional[str] = None
    url: Optional[str] = None


class CVData(BaseModel):
    personal_info: PersonalInfo
    work_experience: List[WorkExperience] = []
    education: List[Education] = []
    skills: List[Skill] = []
    projects: List[Project] = []
    certificates: List[Certificate] = []
    template: str = "modern"  # Default template


class CVTemplate(BaseModel):
    name: str
    display_name: str
    description: str
    preview_image: str
    style_file: str