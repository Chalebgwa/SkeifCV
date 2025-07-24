from weasyprint import HTML, CSS
from jinja2 import Environment, FileSystemLoader
import os
from datetime import datetime
from pathlib import Path
from app.models.cv_models import CVData


class PDFGenerator:
    def __init__(self):
        self.templates_dir = Path("app/templates/cv")
        self.output_dir = Path("generated_cvs")
        self.output_dir.mkdir(exist_ok=True)
        
        # Set up Jinja2 environment
        self.jinja_env = Environment(
            loader=FileSystemLoader(str(self.templates_dir)),
            autoescape=True
        )
    
    async def generate_cv(self, cv_data: CVData) -> str:
        """Generate PDF from CV data"""
        # Generate HTML from template
        html_content = await self.generate_html(cv_data)
        
        # Create PDF
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        pdf_filename = f"cv_{timestamp}.pdf"
        pdf_path = self.output_dir / pdf_filename
        
        # Convert HTML to PDF
        html_doc = HTML(string=html_content, base_url=str(Path.cwd()))
        html_doc.write_pdf(str(pdf_path))
        
        return str(pdf_path)
    
    async def generate_html(self, cv_data: CVData) -> str:
        """Generate HTML from CV data and template"""
        template_name = f"{cv_data.template}.html"
        
        try:
            template = self.jinja_env.get_template(template_name)
        except Exception:
            # Fallback to modern template
            template = self.jinja_env.get_template("modern.html")
        
        # Render the template with CV data
        html_content = template.render(cv=cv_data)
        
        return html_content
    
    async def generate_preview_html(self, cv_data: CVData) -> str:
        """Generate HTML preview (same as PDF but for web display)"""
        return await self.generate_html(cv_data)