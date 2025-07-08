import { Router } from 'express';
import { authMiddleware } from '../middlewares/auth.middleware';
import {
  addFavorite,
  removeFavorite,
  getUserFavorites
} from '../controllers/favorite.controller';

const router = Router();

// Favorite routes - all require authentication
router.use(authMiddleware);

router.get('/', getUserFavorites);
router.post('/:recipeId', addFavorite);
router.delete('/:recipeId', removeFavorite);

export default router; 