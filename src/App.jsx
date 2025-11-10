import { useMemo, useState } from 'react';
import {
  DndContext,
  PointerSensor,
  closestCenter,
  useSensor,
  useSensors,
} from '@dnd-kit/core';
import {
  SortableContext,
  arrayMove,
  useSortable,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { jsPDF } from 'jspdf';
import {
  HiOutlineAcademicCap,
  HiOutlineArrowsUpDown,
  HiOutlineBriefcase,
  HiOutlineEye,
  HiOutlineSparkles,
  HiOutlineUser,
} from 'react-icons/hi2';
import themes from './data/cvThemes.json';
import './App.css';

const componentLibrary = [
  {
    id: 'personal',
    label: 'Personal',
    description: 'Contact details, hero headline, first impression.',
    icon: HiOutlineUser,
    isCore: true,
    isDefault: true,
  },
  {
    id: 'experience',
    label: 'Experience',
    description: 'Roles, impact statements, and timelines.',
    icon: HiOutlineBriefcase,
    isCore: true,
    isDefault: true,
  },
  {
    id: 'education',
    label: 'Education',
    description: 'Academic journey & certifications.',
    icon: HiOutlineAcademicCap,
    isCore: false,
    isDefault: true,
  },
  {
    id: 'skills',
    label: 'Skills',
    description: 'Technical stacks and soft-skill highlights.',
    icon: HiOutlineSparkles,
    isCore: false,
    isDefault: true,
  },
  {
    id: 'review',
    label: 'Review',
    description: 'Snapshot of every section before exporting.',
    icon: HiOutlineEye,
    isCore: false,
    isDefault: true,
  },
];

const emptyExperience = () => ({
  jobTitle: '',
  company: '',
  dates: '',
  description: '',
});

const emptyEducation = () => ({
  degree: '',
  institution: '',
  dates: '',
  description: '',
});

const defaultCvData = {
  fullName: '',
  email: '',
  phoneNumber: '',
  workExperience: [],
  education: [],
  skills: [],
};

function App() {
  const [cvData, setCvData] = useState(defaultCvData);
  const [activeSectionIds, setActiveSectionIds] = useState(
    componentLibrary.filter((component) => component.isDefault).map((c) => c.id),
  );
  const [searchQuery, setSearchQuery] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('all');
  const [selectedThemeId, setSelectedThemeId] = useState(themes[0]?.id ?? '');
  const sensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 5 } }),
  );

  const categories = useMemo(() => {
    const set = new Set(themes.map((theme) => theme.category));
    return ['all', ...Array.from(set).sort()];
  }, []);

  const filteredThemes = useMemo(() => {
    const lowered = searchQuery.toLowerCase();
    return themes.filter((theme) => {
      const matchesCategory =
        categoryFilter === 'all' || theme.category === categoryFilter;
      const matchesQuery =
        !lowered ||
        theme.name.toLowerCase().includes(lowered) ||
        theme.description.toLowerCase().includes(lowered) ||
        theme.category.toLowerCase().includes(lowered);
      return matchesCategory && matchesQuery;
    });
  }, [searchQuery, categoryFilter]);

  const selectedTheme = useMemo(() => {
    return themes.find((theme) => theme.id === selectedThemeId) ?? themes[0];
  }, [selectedThemeId]);

  const handleDragEnd = (event) => {
    const { active, over } = event;
    if (!over || active.id === over.id) {
      return;
    }
    setActiveSectionIds((items) => {
      const oldIndex = items.indexOf(active.id);
      const newIndex = items.indexOf(over.id);
      return arrayMove(items, oldIndex, newIndex);
    });
  };

  const toggleSection = (id) => {
    const meta = componentLibrary.find((component) => component.id === id);
    if (!meta) return;

    setActiveSectionIds((prev) => {
      const exists = prev.includes(id);
      if (exists) {
        if (meta.isCore) return prev;
        return prev.filter((item) => item !== id);
      }
      return [...prev, id];
    });
  };

  const updatePersonal = (key, value) => {
    setCvData((prev) => ({ ...prev, [key]: value }));
  };

  const addExperience = () => {
    setCvData((prev) => ({
      ...prev,
      workExperience: [...prev.workExperience, emptyExperience()],
    }));
  };

  const updateExperience = (index, field, value) => {
    setCvData((prev) => {
      const updated = [...prev.workExperience];
      updated[index] = { ...updated[index], [field]: value };
      return { ...prev, workExperience: updated };
    });
  };

  const removeExperience = (index) => {
    setCvData((prev) => ({
      ...prev,
      workExperience: prev.workExperience.filter((_, i) => i !== index),
    }));
  };

  const addEducation = () => {
    setCvData((prev) => ({
      ...prev,
      education: [...prev.education, emptyEducation()],
    }));
  };

  const updateEducation = (index, field, value) => {
    setCvData((prev) => {
      const updated = [...prev.education];
      updated[index] = { ...updated[index], [field]: value };
      return { ...prev, education: updated };
    });
  };

  const removeEducation = (index) => {
    setCvData((prev) => ({
      ...prev,
      education: prev.education.filter((_, i) => i !== index),
    }));
  };

  const addSkill = () => {
    setCvData((prev) => ({
      ...prev,
      skills: [...prev.skills, ''],
    }));
  };

  const updateSkill = (index, value) => {
    setCvData((prev) => {
      const updated = [...prev.skills];
      updated[index] = value;
      return { ...prev, skills: updated };
    });
  };

  const removeSkill = (index) => {
    setCvData((prev) => ({
      ...prev,
      skills: prev.skills.filter((_, i) => i !== index),
    }));
  };

  const handleExport = () => {
    const doc = new jsPDF();
    const margin = 16;
    let cursorY = margin;

    const addHeading = (text) => {
      doc.setFont('helvetica', 'bold');
      doc.setFontSize(16);
      doc.text(text, margin, cursorY);
      cursorY += 8;
    };

    const addParagraph = (text, options = {}) => {
      doc.setFont('helvetica', options.bold ? 'bold' : 'normal');
      doc.setFontSize(options.size ?? 12);
      const lines = doc.splitTextToSize(text, 180);
      doc.text(lines, margin, cursorY);
      cursorY += lines.length * 6;
    };

    const addSpacer = (size = 6) => {
      cursorY += size;
    };

    doc.setFontSize(20);
    doc.setFont('helvetica', 'bold');
    doc.text(cvData.fullName || 'Full Name', margin, cursorY);
    cursorY += 8;
    doc.setFontSize(11);
    doc.setFont('helvetica', 'normal');
    doc.text(
      `${cvData.email || 'email@example.com'}  |  ${
        cvData.phoneNumber || '+1 000 000 0000'
      }`,
      margin,
      cursorY,
    );
    cursorY += 12;

    if (cvData.workExperience.length) {
      addHeading('Experience');
      cvData.workExperience.forEach((role) => {
        addParagraph(role.jobTitle || 'Job Title', { bold: true });
        addParagraph(
          `${role.company || 'Company'} • ${role.dates || 'Dates'}`,
          {},
        );
        addParagraph(role.description || 'Description goes here.', {
          size: 11,
        });
        addSpacer();
      });
    }

    if (cvData.education.length) {
      addSpacer();
      addHeading('Education');
      cvData.education.forEach((entry) => {
        addParagraph(entry.degree || 'Degree', { bold: true });
        addParagraph(
          `${entry.institution || 'Institution'} • ${entry.dates || 'Dates'}`,
          {},
        );
        addParagraph(entry.description || 'Details here.', { size: 11 });
        addSpacer();
      });
    }

    if (cvData.skills.length) {
      addSpacer();
      addHeading('Skills');
      addParagraph(cvData.skills.filter(Boolean).join(', ') || 'Skill list');
    }

    doc.save('cv.pdf');
  };

  const renderSectionBody = (sectionId) => {
    switch (sectionId) {
      case 'personal':
        return (
          <div className="grid grid--2-col">
            <Input
              label="Full name"
              value={cvData.fullName}
              onChange={(event) => updatePersonal('fullName', event.target.value)}
            />
            <Input
              label="Email"
              type="email"
              value={cvData.email}
              onChange={(event) => updatePersonal('email', event.target.value)}
            />
            <Input
              label="Phone number"
              value={cvData.phoneNumber}
              onChange={(event) => updatePersonal('phoneNumber', event.target.value)}
            />
          </div>
        );
      case 'experience':
        if (!cvData.workExperience.length) {
          return (
            <EmptyState
              message="No experience blocks yet."
              actionLabel="Add experience"
              onAction={addExperience}
            />
          );
        }
        return (
          <>
            {cvData.workExperience.map((experience, index) => (
              <div key={`exp-${index}`} className="sub-card">
                <div className="sub-card__header">
                  <p>Experience #{index + 1}</p>
                  <button
                    className="ghost-button danger"
                    onClick={() => removeExperience(index)}
                  >
                    Remove
                  </button>
                </div>
                <Input
                  label="Job title"
                  value={experience.jobTitle}
                  onChange={(event) =>
                    updateExperience(index, 'jobTitle', event.target.value)
                  }
                />
                <Input
                  label="Company"
                  value={experience.company}
                  onChange={(event) =>
                    updateExperience(index, 'company', event.target.value)
                  }
                />
                <Input
                  label="Dates"
                  value={experience.dates}
                  onChange={(event) =>
                    updateExperience(index, 'dates', event.target.value)
                  }
                />
                <Textarea
                  label="Impact / responsibilities"
                  value={experience.description}
                  onChange={(event) =>
                    updateExperience(index, 'description', event.target.value)
                  }
                />
              </div>
            ))}
            <button className="primary-link" onClick={addExperience}>
              + Add experience
            </button>
          </>
        );
      case 'education':
        if (!cvData.education.length) {
          return (
            <EmptyState
              message="No education entries added."
              actionLabel="Add education"
              onAction={addEducation}
            />
          );
        }
        return (
          <>
            {cvData.education.map((entry, index) => (
              <div key={`edu-${index}`} className="sub-card">
                <div className="sub-card__header">
                  <p>Education #{index + 1}</p>
                  <button
                    className="ghost-button danger"
                    onClick={() => removeEducation(index)}
                  >
                    Remove
                  </button>
                </div>
                <Input
                  label="Degree / Program"
                  value={entry.degree}
                  onChange={(event) =>
                    updateEducation(index, 'degree', event.target.value)
                  }
                />
                <Input
                  label="Institution"
                  value={entry.institution}
                  onChange={(event) =>
                    updateEducation(index, 'institution', event.target.value)
                  }
                />
                <Input
                  label="Dates"
                  value={entry.dates}
                  onChange={(event) =>
                    updateEducation(index, 'dates', event.target.value)
                  }
                />
                <Textarea
                  label="Highlights"
                  value={entry.description}
                  onChange={(event) =>
                    updateEducation(index, 'description', event.target.value)
                  }
                />
              </div>
            ))}
            <button className="primary-link" onClick={addEducation}>
              + Add education
            </button>
          </>
        );
      case 'skills':
        if (!cvData.skills.length) {
          return (
            <EmptyState
              message="You have not added any skills."
              actionLabel="Add skill"
              onAction={addSkill}
            />
          );
        }
        return (
          <>
            {cvData.skills.map((skill, index) => (
              <div key={`skill-${index}`} className="skill-row">
                <Input
                  label={`Skill #${index + 1}`}
                  value={skill}
                  onChange={(event) => updateSkill(index, event.target.value)}
                />
                <button
                  className="ghost-button danger"
                  onClick={() => removeSkill(index)}
                >
                  Remove
                </button>
              </div>
            ))}
            <button className="primary-link" onClick={addSkill}>
              + Add skill
            </button>
          </>
        );
      case 'review':
        return (
          <ReviewSection cvData={cvData} selectedTheme={selectedTheme} />
        );
      default:
        return null;
    }
  };

  return (
    <div className="page">
      <header className="app-header">
        <div>
          <p className="eyebrow">Skeif CV Studio</p>
          <h1>Create a drag-and-drop CV in minutes</h1>
        </div>
        <div className="header-actions">
          <button className="ghost-button" onClick={() => setCvData(defaultCvData)}>
            Reset form
          </button>
          <button className="primary-button" onClick={handleExport}>
            Export PDF
          </button>
        </div>
      </header>

      <section className="theme-selector">
        <div className="theme-selector__controls">
          <div className="input-with-label">
            <label htmlFor="theme-search">Search themes</label>
            <input
              id="theme-search"
              type="text"
              placeholder="Search names, categories, vibes..."
              value={searchQuery}
              onChange={(event) => setSearchQuery(event.target.value)}
            />
          </div>
          <div className="category-chips">
            {categories.map((category) => (
              <button
                key={category}
                className={`chip ${
                  category === categoryFilter ? 'chip--active' : ''
                }`}
                onClick={() => setCategoryFilter(category)}
              >
                {category === 'all' ? 'All categories' : category}
              </button>
            ))}
          </div>
        </div>

        <div className="theme-carousel">
          {filteredThemes.map((theme) => (
            <ThemeCard
              key={theme.id}
              theme={theme}
              selected={theme.id === selectedThemeId}
              onSelect={() => setSelectedThemeId(theme.id)}
            />
          ))}
          {!filteredThemes.length && (
            <div className="empty-carousel">No themes match your filters.</div>
          )}
        </div>

        {selectedTheme && <ThemePreview theme={selectedTheme} />}
      </section>

      <section className="canvas">
        <DndContext
          sensors={sensors}
          collisionDetection={closestCenter}
          onDragEnd={handleDragEnd}
        >
          <SortableContext
            items={activeSectionIds}
            strategy={verticalListSortingStrategy}
          >
            {activeSectionIds.map((sectionId) => {
              const meta = componentLibrary.find((component) => component.id === sectionId);
              if (!meta) return null;
              return (
                <SortableSection key={sectionId} id={sectionId}>
                  {({ attributes, listeners, setNodeRef, style }) => (
                    <div ref={setNodeRef} style={style}>
                      <SectionCard
                        metadata={meta}
                        isRemovable={!meta.isCore}
                        onRemove={() => toggleSection(sectionId)}
                        dragAttributes={attributes}
                        dragListeners={listeners}
                      >
                        {renderSectionBody(sectionId)}
                      </SectionCard>
                    </div>
                  )}
                </SortableSection>
              );
            })}
          </SortableContext>
        </DndContext>
      </section>

      <ComponentTray
        library={componentLibrary}
        activeIds={activeSectionIds}
        toggleSection={toggleSection}
      />
    </div>
  );
}

function ThemeCard({ theme, selected, onSelect }) {
  return (
    <button
      type="button"
      className={`theme-card ${selected ? 'theme-card--selected' : ''}`}
      onClick={onSelect}
      style={{
        backgroundImage: `linear-gradient(135deg, ${theme.primaryColor}, ${theme.accentColor})`,
      }}
    >
      <div className="theme-card__content">
        <p className="theme-category">{theme.category}</p>
        <h3>{theme.name}</h3>
        <p>{theme.description}</p>
      </div>
    </button>
  );
}

function ThemePreview({ theme }) {
  return (
    <div className="theme-preview">
      <div>
        <p className="eyebrow">Selected theme</p>
        <h3>{theme.name}</h3>
        <p>{theme.description}</p>
        <div className="color-swatches">
          <ColorSwatch label="Primary" color={theme.primaryColor} />
          <ColorSwatch label="Accent" color={theme.accentColor} />
          <ColorSwatch label="Background" color={theme.backgroundColor} />
        </div>
      </div>
      <div className="theme-preview__badge">
        <span>Font</span>
        <strong>{theme.fontFamily}</strong>
      </div>
    </div>
  );
}

function ColorSwatch({ label, color }) {
  return (
    <div className="swatch">
      <span className="swatch__dot" style={{ backgroundColor: color }} />
      <span>{label}</span>
    </div>
  );
}

function SectionCard({
  metadata,
  isRemovable,
  onRemove,
  dragAttributes,
  dragListeners,
  children,
}) {
  const Icon = metadata.icon;
  return (
    <article className="section-card">
      <header className="section-card__header">
        <div className="section-card__title">
          <div className="icon-chip">
            <Icon />
          </div>
          <div>
            <h3>{metadata.label}</h3>
            <p>{metadata.description}</p>
          </div>
        </div>
        <div className="section-card__actions">
          {isRemovable && (
            <button className="ghost-button" onClick={onRemove}>
              Remove
            </button>
          )}
          <button
            className="ghost-button icon-only"
            {...dragAttributes}
            {...dragListeners}
          >
            <HiOutlineArrowsUpDown />
          </button>
        </div>
      </header>
      <div className="section-card__body">{children}</div>
    </article>
  );
}

function SortableSection({ id, children }) {
  const { attributes, listeners, setNodeRef, transform, transition } =
    useSortable({ id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  return children({ attributes, listeners, setNodeRef, style });
}

function Input({ label, type = 'text', value, onChange }) {
  return (
    <label className="field">
      <span>{label}</span>
      <input type={type} value={value} onChange={onChange} />
    </label>
  );
}

function Textarea({ label, value, onChange }) {
  return (
    <label className="field">
      <span>{label}</span>
      <textarea rows={3} value={value} onChange={onChange} />
    </label>
  );
}

function EmptyState({ message, actionLabel, onAction }) {
  return (
    <div className="empty-state">
      <p>{message}</p>
      <button className="primary-link" onClick={onAction}>
        {actionLabel}
      </button>
    </div>
  );
}

function ReviewSection({ cvData, selectedTheme }) {
  return (
    <div className="review-card">
      <div className="review-card__hero">
        <p>{cvData.fullName || 'Your name'}</p>
        <p>
          {cvData.email || 'email@example.com'} ·{' '}
          {cvData.phoneNumber || '+1 000 000 0000'}
        </p>
      </div>
      <SummaryList
        title="Experience"
        items={cvData.workExperience.map(
          (exp) => `${exp.jobTitle || 'Role'} @ ${exp.company || 'Company'}`,
        )}
      />
      <SummaryList
        title="Education"
        items={cvData.education.map(
          (edu) => `${edu.degree || 'Degree'} · ${edu.institution || 'School'}`,
        )}
      />
      <SummaryList title="Skills" items={cvData.skills.filter(Boolean)} />
      <div className="review-card__theme">
        <p>Theme</p>
        <strong>{selectedTheme?.name}</strong>
      </div>
    </div>
  );
}

function SummaryList({ title, items }) {
  if (!items.length) return null;
  return (
    <div className="summary-list">
      <p className="eyebrow">{title}</p>
      <ul>
        {items.map((item, index) => (
          <li key={`${title}-${index}`}>{item}</li>
        ))}
      </ul>
    </div>
  );
}

function ComponentTray({ library, activeIds, toggleSection }) {
  return (
    <div className="component-tray">
      <div className="tray-handle" />
      <div className="component-tray__header">
        <div>
          <p className="eyebrow">Component tray</p>
          <h3>Slide sections on/off and drag to reorder above</h3>
        </div>
        <p>
          Active sections:{' '}
          <strong>
            {activeIds.length}/{library.length}
          </strong>
        </p>
      </div>
      <div className="tray-chips">
        {library.map((component) => {
          const isActive = activeIds.includes(component.id);
          return (
            <button
              key={component.id}
              className={`chip ${isActive ? 'chip--active' : ''}`}
              onClick={() => toggleSection(component.id)}
              disabled={component.isCore}
            >
              {component.label}
              {component.isCore && ' • core'}
            </button>
          );
        })}
      </div>
    </div>
  );
}

export default App;
