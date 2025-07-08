# Meal App

A full-stack meal recipe application built with Flutter (frontend) and Node.js/Express/PostgreSQL (backend). Users can browse recipes, filter by categories, mark favorites, and manage their own recipes.

## Project Structure

```
meal_app/
├── lib/                    # Flutter frontend code
│   ├── models/            # Data models
│   ├── providers/         # State management
│   ├── screens/           # UI screens
│   ├── services/          # API services
│   └── widgets/           # Reusable widgets
├── backend/               # Node.js backend
│   ├── prisma/           # Database schema and migrations
│   └── src/              # Backend source code
└── pubspec.yaml          # Flutter dependencies
```

## Prerequisites

- Flutter SDK (latest stable version)
- Node.js (v14 or higher)
- PostgreSQL (v12 or higher)
- Git

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd meal_app
```

### 2. Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Create .env file with the following content:
# DATABASE_URL="postgresql://username:password@localhost:5432/meal_app"
# JWT_SECRET="your-secret-key"
# PORT=3000

# Generate Prisma client
npx prisma generate

# Run migrations
npx prisma migrate dev

# Seed initial data (categories and sample recipes)
npm run seed:recipes

# Start the development server
npm run dev
```

### 3. Frontend Setup

```bash
# From the project root
flutter pub get

# Update the API URL
# In lib/services/api_service.dart, update baseUrl to match your backend URL
```

### 4. Run the Application

```bash
flutter run -d chrome  # For web
# or
flutter run            # For mobile
```

## Environment Variables

### Backend (.env)

```
DATABASE_URL="postgresql://username:password@localhost:5432/meal_app"
JWT_SECRET="your-secret-key"
PORT=3000
```

### Frontend

Update `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://your-backend-url:3000/api';
```

## Features

- User authentication (register/login)
- Browse recipes by category
- Filter recipes (gluten-free, vegetarian, etc.)
- Mark recipes as favorites
- Add and manage your own recipes
- Responsive design for web and mobile

## API Endpoints

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `GET /api/recipes` - List all recipes
- `GET /api/categories` - List all categories
- `GET /api/favorites` - List user's favorites
- More endpoints documented in the backend welcome page

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details
