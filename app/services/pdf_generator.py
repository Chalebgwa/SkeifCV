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
        try:
            # Generate HTML from template
            html_content = await self.generate_html(cv_data)
            
            # Create PDF
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            pdf_filename = f"cv_{timestamp}.pdf"
            pdf_path = self.output_dir / pdf_filename
            
            # Try to convert HTML to PDF
            try:
                html_doc = HTML(string=html_content)
                html_doc.write_pdf(str(pdf_path))
                return str(pdf_path)
            except Exception as pdf_error:
                print(f"PDF generation failed: {pdf_error}")
                # Fallback: save as HTML file for now
                html_filename = f"cv_{timestamp}.html"
                html_path = self.output_dir / html_filename
                with open(html_path, 'w', encoding='utf-8') as f:
                    f.write(html_content)
                return str(html_path)
                
        except Exception as e:
            print(f"Error in generate_cv: {str(e)}")
            import traceback
            traceback.print_exc()
            raise
    
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