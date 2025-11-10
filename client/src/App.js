import React, { useState } from 'axios';
import './App.css';
import axios from 'axios';

function App() {
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    phoneNumber: '',
    workExperience: [],
    education: [],
    skills: [],
  });

  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleExperienceChange = (index, e) => {
    const newExperience = [...formData.workExperience];
    newExperience[index][e.target.name] = e.target.value;
    setFormData({ ...formData, workExperience: newExperience });
  };

  const addExperience = () => {
    setFormData({
      ...formData,
      workExperience: [
        ...formData.workExperience,
        { jobTitle: '', company: '', dates: '', description: '' },
      ],
    });
  };

  const handleEducationChange = (index, e) => {
    const newEducation = [...formData.education];
    newEducation[index][e.target.name] = e.target.value;
    setFormData({ ...formData, education: newEducation });
  };

  const addEducation = () => {
    setFormData({
      ...formData,
      education: [
        ...formData.education,
        { degree: '', institution: '', dates: '', description: '' },
      ],
    });
  };

  const handleSkillChange = (index, e) => {
    const newSkills = [...formData.skills];
    newSkills[index] = e.target.value;
    setFormData({ ...formData, skills: newSkills });
  };

  const addSkill = () => {
    setFormData({ ...formData, skills: [...formData.skills, ''] });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post(
        'http://localhost:5000/api/generate-cv',
        formData,
        { responseType: 'blob' }
      );
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', 'cv.pdf');
      document.body.appendChild(link);
      link.click();
    } catch (error) {
      console.error('Error generating CV:', error);
    }
  };

  return (
    <div className="App">
      <h1>CV Generator</h1>
      <form onSubmit={handleSubmit}>
        <h2>Personal Details</h2>
        <input
          type="text"
          name="fullName"
          placeholder="Full Name"
          onChange={handleInputChange}
        />
        <input
          type="email"
          name="email"
          placeholder="Email"
          onChange={handleInputChange}
        />
        <input
          type="text"
          name="phoneNumber"
          placeholder="Phone Number"
          onChange={handleInputChange}
        />

        <h2>Work Experience</h2>
        {formData.workExperience.map((exp, index) => (
          <div key={index}>
            <input
              type="text"
              name="jobTitle"
              placeholder="Job Title"
              value={exp.jobTitle}
              onChange={(e) => handleExperienceChange(index, e)}
            />
            <input
              type="text"
              name="company"
              placeholder="Company"
              value={exp.company}
              onChange={(e) => handleExperienceChange(index, e)}
            />
            <input
              type="text"
              name="dates"
              placeholder="Dates"
              value={exp.dates}
              onChange={(e) => handleExperienceChange(index, e)}
            />
            <textarea
              name="description"
              placeholder="Description"
              value={exp.description}
              onChange={(e) => handleExperienceChange(index, e)}
            />
          </div>
        ))}
        <button type="button" onClick={addExperience}>
          Add Experience
        </button>

        <h2>Education</h2>
        {formData.education.map((edu, index) => (
          <div key={index}>
            <input
              type="text"
              name="degree"
              placeholder="Degree"
              value={edu.degree}
              onChange={(e) => handleEducationChange(index, e)}
            />
            <input
              type="text"
              name="institution"
              placeholder="Institution"
              value={edu.institution}
              onChange={(e) => handleEducationChange(index, e)}
            />
            <input
              type="text"
              name="dates"
              placeholder="Dates"
              value={edu.dates}
              onChange={(e) => handleEducationChange(index, e)}
            />
            <textarea
              name="description"
              placeholder="Description"
              value={edu.description}
              onChange={(e) => handleEducationChange(index, e)}
            />
          </div>
        ))}
        <button type="button" onClick={addEducation}>
          Add Education
        </button>

        <h2>Skills</h2>
        {formData.skills.map((skill, index) => (
          <div key={index}>
            <input
              type="text"
              placeholder="Skill"
              value={skill}
              onChange={(e) => handleSkillChange(index, e)}
            />
          </div>
        ))}
        <button type="button" onClick={addSkill}>
          Add Skill
        </button>

        <button type="submit">Generate CV</button>
      </form>
    </div>
  );
}

export default App;
