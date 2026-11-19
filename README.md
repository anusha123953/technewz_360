# TECHNEWZ 360 🚀
### Stay Updated. Stay Ahead.

TECHNEWZ 360 is a Flutter-based technology news application that brings the latest updates from the tech world into one place. Explore news related to Artificial Intelligence, Programming, Cybersecurity, Startups, and more.

## ✨ Features

- 📰 **Latest Tech News** – Explore technology-related news.
- 🔍 **Search News** – Find articles using keywords.
- 🗂️ **Category Filters** – Browse news by technology categories.
- 📖 **Article Details** – View article descriptions and publication information.
- 🔖 **Bookmarks** – Save your favourite articles during the current app session.
- 🌐 **External Article Access** – Read complete articles on their original publisher websites.
- 🌙 **Dark UI** – A modern dark-themed interface.

## 🛠️ Tech Stack

**Frontend**
- Flutter
- Dart

**Backend**
- Node.js
- Express.js

**API**
- GNews API

**Tools**
- Visual Studio Code
- Git & GitHub

## 📁 Project Structure

```text
technewz_360/
│
├── backend/
│   ├── server.js
│   ├── package.json
│   └── .env
│
├── lib/
│   ├── data/
│   ├── models/
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   └── main.dart
│
├── pubspec.yaml
└── README.md
```

## ⚙️ Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Node.js and npm
- GNews API key

### 1. Clone the Repository

```bash
git clone https://github.com/anusha123953/technewz_360.git
```

### 2. Navigate to the Project

```bash
cd technewz_360
```

### 3. Install Flutter Dependencies

```bash
flutter pub get
```

### 4. Configure the Backend

```bash
cd backend
npm install
```

Create a `.env` file inside the backend folder:

```env
GNEWS_API_KEY=your_gnews_api_key_here
PORT=5000
```

### 5. Start the Backend

```bash
node server.js
```

The backend runs at:

`http://localhost:5000`

### 6. Run the Flutter Application

Open another terminal in the project root:

```bash
flutter run -d chrome
```

## 🔐 Security

- API keys are stored in environment variables.
-
