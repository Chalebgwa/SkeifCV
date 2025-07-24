#!/usr/bin/env python3
"""
Script to generate placeholder preview images for CV templates
"""

import os
from pathlib import Path


def create_placeholder_svg(template_name, color, description):
    """Create an SVG placeholder image for a template"""
    svg_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg width="400" height="500" viewBox="0 0 400 500" xmlns="http://www.w3.org/2000/svg">
    <rect width="400" height="500" fill="{color}"/>
    <rect x="20" y="20" width="360" height="460" fill="white" rx="8"/>
    
    <!-- Header -->
    <rect x="40" y="40" width="320" height="80" fill="{color}" opacity="0.1" rx="4"/>
    <circle cx="80" cy="80" r="20" fill="{color}" opacity="0.3"/>
    <rect x="120" y="70" width="150" height="8" fill="{color}" opacity="0.7" rx="4"/>
    <rect x="120" y="85" width="100" height="6" fill="{color}" opacity="0.5" rx="3"/>
    
    <!-- Content lines -->
    <rect x="40" y="150" width="320" height="4" fill="#e2e8f0" rx="2"/>
    <rect x="40" y="170" width="280" height="3" fill="#f7fafc" rx="1.5"/>
    <rect x="40" y="185" width="300" height="3" fill="#f7fafc" rx="1.5"/>
    <rect x="40" y="200" width="260" height="3" fill="#f7fafc" rx="1.5"/>
    
    <rect x="40" y="230" width="320" height="4" fill="#e2e8f0" rx="2"/>
    <rect x="40" y="250" width="280" height="3" fill="#f7fafc" rx="1.5"/>
    <rect x="40" y="265" width="300" height="3" fill="#f7fafc" rx="1.5"/>
    <rect x="40" y="280" width="260" height="3" fill="#f7fafc" rx="1.5"/>
    
    <rect x="40" y="310" width="320" height="4" fill="#e2e8f0" rx="2"/>
    <rect x="40" y="330" width="200" height="3" fill="#f7fafc" rx="1.5"/>
    <rect x="40" y="345" width="180" height="3" fill="#f7fafc" rx="1.5"/>
    
    <!-- Sidebar -->
    <rect x="260" y="150" width="100" height="200" fill="{color}" opacity="0.05" rx="4"/>
    <rect x="270" y="160" width="80" height="3" fill="{color}" opacity="0.4" rx="1.5"/>
    <rect x="270" y="175" width="60" height="2" fill="{color}" opacity="0.3" rx="1"/>
    <rect x="270" y="185" width="70" height="2" fill="{color}" opacity="0.3" rx="1"/>
    
    <!-- Template name -->
    <text x="200" y="480" text-anchor="middle" fill="{color}" font-family="Arial, sans-serif" font-size="16" font-weight="bold">{template_name.title()}</text>
</svg>'''
    
    return svg_content


def main():
    """Generate placeholder images for all templates"""
    templates = {
        "modern": {"color": "#667eea", "description": "Modern gradient design"},
        "classic": {"color": "#2c3e50", "description": "Traditional professional"},
        "minimal": {"color": "#4a5568", "description": "Clean and simple"}
    }
    
    images_dir = Path("app/static/images")
    images_dir.mkdir(parents=True, exist_ok=True)
    
    for template_name, config in templates.items():
        svg_content = create_placeholder_svg(template_name, config["color"], config["description"])
        
        # Save as SVG (can be used directly or converted to other formats)
        svg_path = images_dir / f"{template_name}-preview.svg"
        with open(svg_path, 'w') as f:
            f.write(svg_content)
        
        print(f"Created preview image: {svg_path}")


if __name__ == "__main__":
    main()