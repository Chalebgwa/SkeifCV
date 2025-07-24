from pathlib import Path
from typing import Dict, List
from app.models.cv_models import CVTemplate


class TemplateService:
    def __init__(self):
        self.templates_dir = Path("app/templates/cv")
        self.templates_dir.mkdir(parents=True, exist_ok=True)
        
        # Define available templates
        self.templates = {
            "modern": CVTemplate(
                name="modern",
                display_name="Modern",
                description="Clean and contemporary design with accent colors",
                preview_image="/static/images/modern-preview.svg",
                style_file="modern.css"
            ),
            "classic": CVTemplate(
                name="classic",
                display_name="Classic",
                description="Traditional and professional layout",
                preview_image="/static/images/classic-preview.svg",
                style_file="classic.css"
            ),
            "minimal": CVTemplate(
                name="minimal",
                display_name="Minimal",
                description="Simple and elegant design with focus on content",
                preview_image="/static/images/minimal-preview.svg",
                style_file="minimal.css"
            )
        }
    
    def get_available_templates(self) -> List[CVTemplate]:
        """Get list of available CV templates"""
        return list(self.templates.values())
    
    def get_template_info(self, template_name: str) -> CVTemplate:
        """Get information about a specific template"""
        return self.templates.get(template_name, self.templates["modern"])
    
    def template_exists(self, template_name: str) -> bool:
        """Check if template exists"""
        return template_name in self.templates