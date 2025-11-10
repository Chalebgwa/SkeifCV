## SkeifCV · React Builder

A React + Vite rewrite of the SkeifCV tool. It mirrors the original Flutter builder: searchable catalogue of 100 JSON-defined themes, drag-to-reorder CV sections, toggleable components, live preview, and one-click PDF export powered entirely in-browser.

### Stack

- Vite + React 18
- `@dnd-kit` for drag-and-drop section ordering
- `jspdf` for client-side PDF export
- `react-icons` for iconography

### Getting Started

```bash
npm install
npm run dev
```

The dev server defaults to <http://localhost:5173>. The CV themes live in `src/data/cvThemes.json`; tweak or swap this file to change the available presets.

### Available Scripts

- `npm run dev` – start Vite in dev mode
- `npm run build` – production build (outputs to `dist/`)
- `npm run preview` – serve the production build locally
- `npm run lint` – run ESLint using the Vite config

### Project Structure

```
src/
├── App.jsx            # CV builder UI + state
├── App.css            # Component styling
├── data/cvThemes.json # 100 curated themes
├── index.css          # Global resets
└── main.jsx           # Entry point
```

### Testing & Next Steps

- Run `npm run build` to ensure production bundles compile cleanly.
- Extend `ReviewSection` to embed richer previews (images, layout samples) if you need more accurate PDF fidelity.
- Wire up persistence (e.g., `localStorage` or backend sync) if you want to save multiple CV drafts.
