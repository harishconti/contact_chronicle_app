# Contact Chronicle

Contact Chronicle is a specialized contact management application designed for medical professionals. It provides an intuitive interface for managing patient information and chronological notes, tailored to clinical workflows.

## Current Implemented Features (MVP)

This section details the features that are currently implemented and functional in the application, based on the existing codebase.

### 1. Contact Management

- **Create, Edit, and Delete Contacts**: A comprehensive form allows for the creation and updating of contact details, including name, email, phone, age, location, and initial medical complaints/analysis. Contacts can also be deleted.
- **Contact List & Search**: The main screen displays a list of all contacts. A search bar allows for real-time filtering of contacts by name, phone number, or patient ID.
- **Detailed Contact View**: Tapping a contact opens a detailed view showing all their information, including a chronological timeline of their clinical notes.
- **Avatar Upload**: Users can upload a profile picture for a contact from their device's gallery.

### 2. Clinical Notes

- **Chronological Timeline**: Each contact has a dedicated timeline that displays all their clinical notes in reverse chronological order.
- **Add & Delete Notes**: Users can add new notes to a contact's timeline. Existing notes can be deleted with a confirmation prompt.
- **Profession-Specific Templates**: A "Use Template" feature pre-fills notes with a structure tailored to the user's profession, which can be set in their profile. Templates are available for professions such as Doctor, Nurse, Pharmacist, Acupuncturist, Ayurveda practitioners, and Veterinarians.

### 3. Dashboard & Analytics

- **Summary Cards**: A dashboard provides a quick overview with cards showing the total number of contacts and the total number of notes across all contacts.
- **Global Note Search**: A powerful search bar on the dashboard allows users to find specific text across all notes from every contact.

### 4. User Experience & Settings

- **Mock Authentication**: A simple login screen simulates the user authentication flow. The login state is persisted locally.
- **User Settings**: Users can select their medical profession and a mock "user tier" from a settings menu. These settings are saved locally and used for features like note templating.
- **Light & Dark Mode**: The application includes distinct, professionally designed themes for both light and dark modes, adapting to system settings.
- **Click-to-Action**: Email addresses and phone numbers in the contact details are clickable, launching the default mail or phone app.

## Placeholder & Future Features

### Features to Work On (Frontend)
- UI for Google Contacts Import: A UI element to initiate the import process from Google Contacts.
- UI for Data Sync & Backup: Settings or UI elements to manage data synchronization and backup.
- Enhanced Note Editing: A more advanced rich text editor for notes.

### Backend Features to Work On
- User Authentication: Full implementation of user sign-up, sign-in, and session management using a service like Firebase Authentication.
- Real-time Database: Integration with a real-time database like Firestore to store and sync contacts and notes.
- Data Sync & Backup: Cloud-based data synchronization and backup functionality.
- Google People API Integration: Implementation of the logic to import contacts from a user's Google account.

## Technical Stack

- **Framework**: Flutter
- **State Management**: Provider
- **UI**:
    - Icons: Lucide Flutter Icons
    - Fonts: Google Fonts
    - Local Storage: `shared_preferences` for settings persistence
- **Functionality**:
    - `image_picker` for gallery access
    - `url_launcher` for opening external links (e.g., mail, phone)

## Getting Started

### Prerequisites

- Flutter SDK
- An IDE like VS Code or Android Studio with the Flutter plugin.

### Installation & Setup

- git clone <repository-url>
- cd contact_chronicle_app
- flutter pub get
- flutter run


## Project Structure

The core of the application is located in the `lib` directory:

- **main.dart**: The entry point of the application.
- **models/**: Contains data model classes (Contact, Note).
- **screens/**: Holds widget classes for different app screens (LoginScreen, ContactListScreen, etc.).
- **widgets/**: Contains reusable UI components (ContactListItem, NoteTimeline).
- **services/**: Houses business logic and services (DataService, SettingsService).
- **utils/**: Includes utility classes and helper functions (AppTheme).
