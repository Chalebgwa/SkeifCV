const express = require('express');
const cors = require('cors');
const PDFDocument = require('pdfkit');

const app = express();
const port = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

app.post('/api/generate-cv', (req, res) => {
  const { fullName, email, phoneNumber, workExperience, education, skills } = req.body;

  const doc = new PDFDocument();

  // Set up the response to be a PDF file
  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader('Content-Disposition', 'attachment; filename=cv.pdf');

  // Pipe the PDF to the response
  doc.pipe(res);

  // Add content to the PDF
  doc.fontSize(25).text(fullName, { align: 'center' });
  doc.fontSize(12).text(`${email} | ${phoneNumber}`, { align: 'center' });

  doc.moveDown();
  doc.fontSize(20).text('Work Experience');
  workExperience.forEach(exp => {
    doc.fontSize(14).text(exp.jobTitle);
    doc.fontSize(12).text(`${exp.company} | ${exp.dates}`);
    doc.fontSize(10).text(exp.description);
    doc.moveDown();
  });

  doc.moveDown();
  doc.fontSize(20).text('Education');
  education.forEach(edu => {
    doc.fontSize(14).text(edu.degree);
    doc.fontSize(12).text(`${edu.institution} | ${edu.dates}`);
    doc.fontSize(10).text(edu.description);
    doc.moveDown();
  });

  doc.moveDown();
  doc.fontSize(20).text('Skills');
  doc.fontSize(12).list(skills);

  // Finalize the PDF and end the stream
  doc.end();
});

app.listen(port, () => {
  console.log(`Server is running on port: ${port}`);
});
