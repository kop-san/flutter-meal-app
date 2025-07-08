import { Router } from 'express';
import { authMiddleware } from '../middlewares/auth.middleware';
import {
  updateProfile,
  deleteAccount,
  changePassword,
  getMyRecipes
} from '../controllers/user.controller';

const router = Router();

// User routes - all require authentication
router.use(authMiddleware);

router.put('/profile', updateProfile);
router.put('/change-password', changePassword);
router.delete('/account', deleteAccount);
router.get('/recipes', getMyRecipes);

export default router; 