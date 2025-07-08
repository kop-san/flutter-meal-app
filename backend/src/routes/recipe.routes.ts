import { Router } from 'express';
import { authMiddleware } from '../middlewares/auth.middleware';
import {
  createRecipe,
  getAllRecipes,
  getRecipeById,
  updateRecipe,
  deleteRecipe
} from '../controllers/recipe.controller';

const router = Router();

// Recipe routes
router.get('/', getAllRecipes);
router.get('/:id', getRecipeById);
router.post('/', authMiddleware, createRecipe);
router.put('/:id', authMiddleware, updateRecipe);
router.delete('/:id', authMiddleware, deleteRecipe);

export default router; 