from fastapi import FastAPI, Request, Form, File, UploadFile, HTTPException
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
import uvicorn
import os
import json
from datetime import datetime
from typing import List, Optional
import aiofiles
from pathlib import Path

from app.models.cv_models import CVData, PersonalInfo, WorkExperience, Education, Skill, Project, Certificate
from app.services.pdf_generator import PDFGenerator
from app.services.template_service import TemplateService

app = FastAPI(title="SkeifCV", description="Free CV making app with modernised templates")

# Mount static files
app.mount("/static", StaticFiles(directory="app/static"), name="static")
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# Templates
templates = Jinja2Templates(directory="app/templates")

# Services
pdf_generator = PDFGenerator()
template_service = TemplateService()


@app.get("/", response_class=HTMLResponse)
async def home(request: Request):
    """Home page with template selection"""
    available_templates = template_service.get_available_templates()
    return templates.TemplateResponse(
        "index.html", 
        {"request": request, "templates": available_templates}
    )


@app.get("/editor/{template_name}", response_class=HTMLResponse)
async def cv_editor(request: Request, template_name: str):
    """CV editor page"""
    if not template_service.template_exists(template_name):
        raise HTTPException(status_code=404, detail="Template not found")
    
    template_info = template_service.get_template_info(template_name)
    return templates.TemplateResponse(
        "editor.html",
        {"request": request, "template": template_info}
    )


@app.post("/upload-image")
async def upload_image(file: UploadFile = File(...)):
    """Upload profile image"""
    if not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    # Create uploads directory if it doesn't exist
    os.makedirs("uploads", exist_ok=True)
    
    # Generate unique filename
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{timestamp}_{file.filename}"
    filepath = os.path.join("uploads", filename)
    
    # Save file
    async with aiofiles.open(filepath, 'wb') as f:
        content = await file.read()
        await f.write(content)
    
    return {"filename": filename, "url": f"/uploads/{filename}"}


@app.post("/generate-cv")
async def generate_cv(request: Request):
    """Generate CV from form data"""
    form_data = await request.form()
    
    try:
        # Parse form data into CV model
        cv_data = await parse_form_data(form_data)
        
        # Generate PDF
        pdf_path = await pdf_generator.generate_cv(cv_data)
        
        # Return the PDF file
        return FileResponse(
            pdf_path,
            media_type="application/pdf",
            filename=f"{cv_data.personal_info.full_name.replace(' ', '_')}_CV.pdf"
        )
    
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/preview/{template_name}")
async def preview_template(request: Request, template_name: str):
    """Preview template with sample data"""
    if not template_service.template_exists(template_name):
        raise HTTPException(status_code=404, detail="Template not found")
    
    # Create sample CV data
    sample_data = create_sample_cv_data(template_name)
    
    # Generate preview HTML
    preview_html = await pdf_generator.generate_preview_html(sample_data)
    
    return HTMLResponse(content=preview_html)


async def parse_form_data(form_data) -> CVData:
    """Parse form data into CVData model"""
    # Personal Info
    personal_info = PersonalInfo(
        full_name=form_data.get("full_name", ""),
        email=form_data.get("email", ""),
        phone=form_data.get("phone", ""),
        location=form_data.get("location", ""),
        website=form_data.get("website"),
        linkedin=form_data.get("linkedin"),
        github=form_data.get("github"),
        summary=form_data.get("summary"),
        profile_image=form_data.get("profile_image")
    )
    
    # Work Experience
    work_experience = []
    exp_count = int(form_data.get("work_experience_count", 0))
    for i in range(exp_count):
        exp = WorkExperience(
            job_title=form_data.get(f"work_title_{i}", ""),
            company=form_data.get(f"work_company_{i}", ""),
            location=form_data.get(f"work_location_{i}", ""),
            start_date=datetime.strptime(form_data.get(f"work_start_{i}", ""), "%Y-%m").date(),
            end_date=datetime.strptime(form_data.get(f"work_end_{i}", ""), "%Y-%m").date() if form_data.get(f"work_end_{i}") else None,
            current=form_data.get(f"work_current_{i}", "") == "on",
            description=form_data.get(f"work_description_{i}", "").split("\n")
        )
        work_experience.append(exp)
    
    # Education
    education = []
    edu_count = int(form_data.get("education_count", 0))
    for i in range(edu_count):
        edu = Education(
            degree=form_data.get(f"edu_degree_{i}", ""),
            institution=form_data.get(f"edu_institution_{i}", ""),
            location=form_data.get(f"edu_location_{i}", ""),
            start_date=datetime.strptime(form_data.get(f"edu_start_{i}", ""), "%Y-%m").date(),
            end_date=datetime.strptime(form_data.get(f"edu_end_{i}", ""), "%Y-%m").date() if form_data.get(f"edu_end_{i}") else None,
            current=form_data.get(f"edu_current_{i}", "") == "on",
            gpa=form_data.get(f"edu_gpa_{i}"),
            description=form_data.get(f"edu_description_{i}", "").split("\n") if form_data.get(f"edu_description_{i}") else None
        )
        education.append(edu)
    
    # Skills
    skills = []
    skills_data = form_data.get("skills", "")
    if skills_data:
        for skill_line in skills_data.split("\n"):
            if skill_line.strip():
                skill_parts = skill_line.strip().split("|")
                skill = Skill(
                    name=skill_parts[0].strip(),
                    level=skill_parts[1].strip() if len(skill_parts) > 1 else None,
                    category=skill_parts[2].strip() if len(skill_parts) > 2 else None
                )
                skills.append(skill)
    
    template_name = form_data.get("template", "modern")
    
    return CVData(
        personal_info=personal_info,
        work_experience=work_experience,
        education=education,
        skills=skills,
        projects=[],  # TODO: Add projects parsing
        certificates=[],  # TODO: Add certificates parsing
        template=template_name
    )


def create_sample_cv_data(template_name: str) -> CVData:
    """Create sample CV data for preview"""
    from datetime import date
    
    return CVData(
        personal_info=PersonalInfo(
            full_name="John Doe",
            email="john.doe@example.com",
            phone="+1 (555) 123-4567",
            location="New York, NY",
            website="https://johndoe.dev",
            linkedin="https://linkedin.com/in/johndoe",
            github="https://github.com/johndoe",
            summary="Experienced software developer with 5+ years of experience in building scalable web applications. Passionate about clean code and modern technologies."
        ),
        work_experience=[
            WorkExperience(
                job_title="Senior Software Developer",
                company="Tech Corp",
                location="New York, NY",
                start_date=date(2021, 6, 1),
                current=True,
                description=[
                    "Developed and maintained microservices using Python and FastAPI",
                    "Led a team of 3 junior developers",
                    "Improved application performance by 40%"
                ]
            ),
            WorkExperience(
                job_title="Software Developer",
                company="StartupXYZ",
                location="San Francisco, CA",
                start_date=date(2019, 3, 1),
                end_date=date(2021, 5, 31),
                current=False,
                description=[
                    "Built RESTful APIs using Django and PostgreSQL",
                    "Implemented CI/CD pipelines with Docker and GitHub Actions",
                    "Collaborated with cross-functional teams in Agile environment"
                ]
            )
        ],
        education=[
            Education(
                degree="Bachelor of Science in Computer Science",
                institution="University of Technology",
                location="Boston, MA",
                start_date=date(2015, 9, 1),
                end_date=date(2019, 5, 31),
                gpa="3.8/4.0"
            )
        ],
        skills=[
            Skill(name="Python", level="Expert", category="Programming"),
            Skill(name="JavaScript", level="Advanced", category="Programming"),
            Skill(name="React", level="Advanced", category="Frontend"),
            Skill(name="PostgreSQL", level="Intermediate", category="Database"),
            Skill(name="Docker", level="Advanced", category="DevOps")
        ],
        template=template_name
    )


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)