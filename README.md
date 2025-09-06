# Contact Chronicle

Contact Chronicle is a specialized contact management application designed for medical professionals. It provides an intuitive interface for managing patient information and chronological notes, tailored to clinical workflows.

---

## Core Features

- Centralized contact list with dynamic search
- Add & edit patients with form validation
- Local image uploads for patient avatars
- Auto-incrementing unique Patient IDs (PN00001, PN00002, ...)
- Profession-specific note templating (Acupuncture, General Practice, Nurse)
- Initial and follow-up notes generated from templates
- Chronological timeline for patient notes
- Editable notes with rich text formatting
- Dashboard with analytics and global note search
- Progressive Web App (PWA): installable, offline access, responsive design
- Mocked user tiers for feature preview

---

## Features Requiring Backend Implementation

- User Authentication: UI complete, requires backend (e.g., Firebase Authentication)
- Real-time Database: UI complete, data currently in-memory, needs backend (e.g., Firestore)
- Data Sync & Backup: UI placeholders, requires backend integration
- Google Contacts Import: UI placeholder, requires Google People API integration

---

## Technical Stack

- Next.js (App Router)
- TypeScript
- Tailwind CSS
- ShadCN UI
- React Hook Form + Zod
- React Hooks for state management
- PWA via @ducanh2912/next-pwa

---

## Getting Started

### Prerequisites
- Node.js (v18 or later)
- npm or yarn

### Installation & Setup
```sh
git clone <repository-url>
cd <repository-directory>
npm install
npm run dev
```
Visit [http://localhost:9002](http://localhost:9002) in your browser.

---

## Project Structure

- `src/app/` — Main application pages
- `src/components/` — Reusable React and UI components
- `src/lib/` — Utilities, types, mock data
- `public/` — Static assets, manifest, icons
- `lib/` (Flutter): Dart files for platform-specific builds

---

## PWA Installation

Open the deployed app URL in Chrome (Android) or Safari (iOS), and use browser options to "Install app" or "Add to Home Screen". The app icon will appear on your device, ready to launch.