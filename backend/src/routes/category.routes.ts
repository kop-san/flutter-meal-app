import { Router } from 'express';
import { authMiddleware } from '../middlewares/auth.middleware';
import {
  createCategory,
  getAllCategories,
  getCategoryById,
  updateCategory,
  deleteCategory
} from '../controllers/category.controller';

const router = Router();

// Category routes
router.get('/', getAllCategories);
router.get('/:id', getCategoryById);
router.post('/', authMiddleware, createCategory);
router.put('/:id', authMiddleware, updateCategory);
router.delete('/:id', authMiddleware, deleteCategory);

export default router; 