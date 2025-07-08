import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { errorMiddleware } from './middlewares/error.middleware';

// Import routes
import authRoutes from './routes/auth.routes';
import recipeRoutes from './routes/recipe.routes';
import categoryRoutes from './routes/category.routes';
import favoriteRoutes from './routes/favorite.routes';
import userRoutes from './routes/user.routes';

// Load environment variables
dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'Server is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// Welcome endpoint
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Welcome to the Meal App API!',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      recipes: '/api/recipes',
      categories: '/api/categories',
      favorites: '/api/favorites',
      users: '/api/users',
      health: '/api/health'
    }
  });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/recipes', recipeRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/favorites', favoriteRoutes);
app.use('/api/user', userRoutes);

// Error handling middleware
app.use(errorMiddleware);

export default app; 