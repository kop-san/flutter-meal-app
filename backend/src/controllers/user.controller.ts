import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import { prisma } from '../utils/prisma';
import { ApiError } from '../middlewares/error.middleware';

export const updateProfile = async (req: Request, res: Response) => {
  try {
    const { name, email } = req.body;

    // Check if email is already taken
    if (email) {
      const existingUser = await prisma.user.findUnique({
        where: { email },
      });

      if (existingUser && existingUser.id !== req.user!.id) {
        throw new ApiError('Email already in use');
      }
    }

    const user = await prisma.user.update({
      where: { id: req.user!.id },
      data: {
        name,
        email,
      },
      select: {
        id: true,
        email: true,
        name: true,
        createdAt: true,
      },
    });

    res.json({
      success: true,
      data: user,
    });
  } catch (error) {
    if (error instanceof ApiError) {
      res.status(400).json({
        success: false,
        message: error.message,
      });
    } else {
      throw error;
    }
  }
};

export const changePassword = async (req: Request, res: Response) => {
  try {
    const { currentPassword, newPassword } = req.body;

    // Get user with password
    const user = await prisma.user.findUnique({
      where: { id: req.user!.id },
    });

    if (!user) {
      throw new ApiError('User not found');
    }

    // Check current password
    const isPasswordValid = await bcrypt.compare(currentPassword, user.password);

    if (!isPasswordValid) {
      throw new ApiError('Current password is incorrect');
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 12);

    // Update password
    await prisma.user.update({
      where: { id: req.user!.id },
      data: {
        password: hashedPassword,
      },
    });

    res.json({
      success: true,
      message: 'Password updated successfully',
    });
  } catch (error) {
    if (error instanceof ApiError) {
      res.status(400).json({
        success: false,
        message: error.message,
      });
    } else {
      throw error;
    }
  }
};

export const deleteAccount = async (req: Request, res: Response) => {
  try {
    // Delete user's recipes first (this will cascade delete favorites)
    await prisma.recipe.deleteMany({
      where: { authorId: req.user!.id },
    });

    // Delete user
    await prisma.user.delete({
      where: { id: req.user!.id },
    });

    res.json({
      success: true,
      message: 'Account deleted successfully',
    });
  } catch (error) {
    throw error;
  }
};

export const getMyRecipes = async (req: Request, res: Response) => {
  try {
    const recipes = await prisma.recipe.findMany({
      where: { authorId: req.user!.id },
      include: {
        categories: true,
        author: {
          select: { id: true, name: true },
        },
      },
    });
    res.json({
      success: true,
      data: recipes,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch your recipes.' });
  }
}; 