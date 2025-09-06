Contact Chronicle
Contact Chronicle is a specialized contact management application designed for medical professionals like acupuncturists, general practitioners, and nurses. It provides a clean, intuitive interface for managing patient information and chronological notes, with features tailored to a clinical workflow.

This application is built as a Progressive Web App (PWA), allowing it to be installed on mobile devices for an app-like experience with offline capabilities.

Table of Contents
Core Features

Features Requiring Backend Implementation

Technical Overview

Getting Started

Project Structure

Installing on a Device (PWA)

Core Features
These features are fully implemented and functional in the current version of the app.

Contact Management:

Centralized Contact List: Displays all patients in a clear, scrollable list.

Dynamic Search: Instantly find patients by searching for their name, phone number, or unique Patient ID.

Add & Edit Contacts: Easily add new patients or edit existing information through a comprehensive form with validation.

Local Image Uploads: Upload patient photos directly from your device for their avatar.

Unique Patient IDs:

New contacts are automatically assigned a unique, auto-incrementing ID (e.g., PN00001, PN00002) for easy and professional tracking.

Profession-Specific Note Templating:

Select Your Profession: Users can set their profession (Acupuncture, General Practice, Nurse) from a dropdown menu.

Automated Initial Note: For new patients, the system generates a detailed initial note based on the selected profession's template, pre-filling it with patient details.

Streamlined Follow-up Notes: Subsequent notes start with a clean, simple template for quick entry.

Timeline & Note-Taking:

Chronological Timeline: Patient notes are organized in a clear, ledger-style timeline, making it easy to review a patient's history.

Editable Notes: All previous notes can be edited at any time.

Rich Text Support: Notes support basic formatting, including bold, italics, and bullet points for clear documentation.

Dashboard:

At-a-Glance Analytics: View key statistics like total contacts and total notes.

Global Note Search: A powerful search bar to find keywords or phrases across all notes for all contacts.

Progressive Web App (PWA):

Installable: The application can be "installed" on a mobile device or desktop, providing an app-like experience with an icon on the home screen.

Offline Access: Core functionality remains available even without an internet connection (based on cached data).

UI/UX Enhancements:

Responsive Design: The interface is optimized for both desktop and mobile devices.

Tooltips: Icon buttons have tooltips on hover for better usability.

Mocked User Tiers: A dropdown allows the user to simulate upgrading between Free, Pro, and Pro+ tiers to preview feature access.

Features Requiring Backend Implementation
The following features have a fully built-out user interface but require a backend (like Firebase) to be fully functional.

User Authentication:

The app includes a complete login page and flow. A developer needs to connect this to a real authentication service (e.g., Firebase Authentication with Google Provider) to manage user accounts securely. The current implementation only simulates the login state using localStorage.

Real-time Database:

Contact and note data is currently stored in-memory and resets on a full browser refresh. This needs to be connected to a real-time database (e.g., Cloud Firestore) to persist data, sync it across devices, and ensure it's tied to the logged-in user.

Data Sync & Backup:

The "Sync Data" and "Backup to Google Drive" buttons are placeholders. They would need to be connected to backend functions to sync data with a central database and integrate with the Google Drive API.

Google Contacts Import:

The "Import from Google" option in the user menu is a placeholder. This requires integration with the Google People API to allow users to import their existing contacts.

Technical Overview
Framework: Next.js with App Router

Language: TypeScript

Styling: Tailwind CSS

UI Components: ShadCN UI

Forms: React Hook Form with Zod for schema validation.

State Management: React Hooks (useState, useMemo, useEffect)

PWA: Implemented using @ducanh2912/next-pwa

Getting Started
To run the application on your local machine, follow these steps:

Prerequisites
Node.js (v18 or later)

npm or yarn

Installation & Setup
Clone the repository:

git clone <repository-url>
cd <repository-directory>

Install Dependencies:

npm install

Run the Development Server:

npm run dev

Open http://localhost:9002 in your browser to see the application.

Project Structure
The project follows a standard Next.js App Router structure. Key directories include:

src/app/: Contains the main pages of the application, including the login, main contact view, and dashboard.

src/components/: Reusable React components, divided into general components and UI primitives from ShadCN.

src/lib/: Contains utility functions (utils.ts), data types (types.ts), and mock data (data.ts).

public/: Static assets, including the PWA manifest and icons.

Installing on a Device (PWA)
Because this is a Progressive Web App, you can "install" it on your Android or iOS device without needing an app store.

Access the App: On your mobile device, open a compatible browser (like Chrome or Safari) and navigate to the URL where the app is deployed.

Install the App:

On Android (Chrome): Tap the three-dot menu icon in the top-right corner and select "Install app" (or "Add to Home screen").

On iOS (Safari): Tap the Share button, then scroll down and select "Add to Home Screen".

Launch from Home Screen: An icon for Contact Chronicle will be added to your phone's home screen. You can now launch it just like any other app.