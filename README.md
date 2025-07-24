# SkeifCV

Free CV making app with modernized templates. Create professional resumes with multiple template options, custom data input, and export to PDF.

## Features

- **Multiple Templates**: Choose from modern, classic, and minimal CV designs
- **Easy Data Input**: User-friendly web interface for adding personal information, work experience, education, and skills
- **Real-time Preview**: See your CV as you build it
- **PDF Export**: Generate high-quality PDF files (currently outputs HTML due to dependency issue)
- **Profile Images**: Upload and include profile pictures
- **Responsive Design**: Works on desktop and mobile devices

## Templates

1. **Modern**: Clean and contemporary design with gradient colors and modern typography
2. **Classic**: Traditional professional layout with serif fonts
3. **Minimal**: Simple and elegant design focusing on content clarity

## Quick Start

### Prerequisites

- Python 3.8 or higher
- pip (Python package manager)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Chalebgwa/SkeifCV.git
   cd SkeifCV
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run the application:
   ```bash
   python main.py
   ```

4. Open your browser and navigate to:
   ```
   http://localhost:8000
   ```

## Usage

1. **Choose a Template**: Browse the available templates on the home page and click "Use Template"

2. **Fill in Your Information**:
   - Personal details (name, email, phone, location)
   - Professional summary
   - Work experience (add multiple entries)
   - Education background
   - Skills (format: `Skill Name|Level|Category`)

3. **Upload Profile Image** (optional): Add a professional photo to your CV

4. **Preview**: See a live preview of your CV as you fill in the information

5. **Generate CV**: Click "Generate CV" to download your formatted resume

## API Endpoints

- `GET /` - Home page with template selection
- `GET /editor/{template_name}` - CV editor for a specific template
- `GET /preview/{template_name}` - Preview template with sample data
- `POST /upload-image` - Upload profile image
- `POST /generate-cv` - Generate CV from form data

## Development

### Project Structure

```
SkeifCV/
├── app/
│   ├── main.py              # FastAPI application
│   ├── models/
│   │   └── cv_models.py     # Data models
│   ├── services/
│   │   ├── pdf_generator.py # PDF generation service
│   │   └── template_service.py # Template management
│   ├── templates/           # HTML templates
│   │   ├── base.html
│   │   ├── index.html
│   │   ├── editor.html
│   │   └── cv/              # CV templates
│   │       ├── modern.html
│   │       ├── classic.html
│   │       └── minimal.html
│   └── static/              # CSS, JS, images
├── requirements.txt
├── main.py                  # Application entry point
└── README.md
```

### Adding New Templates

1. Create a new HTML template in `app/templates/cv/`
2. Add template configuration in `app/services/template_service.py`
3. Create a preview image in `app/static/images/`

### Running in Development Mode

```bash
python main.py
```

The application will reload automatically when you make changes to the code.

## Known Issues

- PDF generation currently has a dependency compatibility issue with pydyf/weasyprint. The application falls back to HTML export which can be manually converted to PDF using the browser's print function.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is open source and available under the MIT License.

## Support

For issues and feature requests, please create an issue on the GitHub repository.
