import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { ApiError } from '../middlewares/error.middleware';

export const getUserFavorites = async (req: Request, res: Response) => {
  try {
    const favorites = await prisma.favorite.findMany({
      where: {
        userId: req.user!.id,
      },
      include: {
        recipe: {
          include: {
            categories: true,
            author: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
      },
    });

    res.json({
      success: true,
      data: favorites.map((fav) => fav.recipe),
    });
  } catch (error) {
    throw error;
  }
};

export const addFavorite = async (req: Request, res: Response) => {
  try {
    const { recipeId } = req.params;

    // Check if recipe exists
    const recipe = await prisma.recipe.findUnique({
      where: { id: recipeId },
    });

    if (!recipe) {
      throw new ApiError('Recipe not found');
    }

    // Check if already favorited
    const existingFavorite = await prisma.favorite.findUnique({
      where: {
        userId_recipeId: {
          userId: req.user!.id,
          recipeId,
        },
      },
    });

    if (existingFavorite) {
      throw new ApiError('Recipe already in favorites');
    }

    // Add to favorites
    await prisma.favorite.create({
      data: {
        userId: req.user!.id,
        recipeId,
      },
    });

    res.status(201).json({
      success: true,
      message: 'Recipe added to favorites',
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

export const removeFavorite = async (req: Request, res: Response) => {
  try {
    const { recipeId } = req.params;

    // Check if favorite exists
    const favorite = await prisma.favorite.findUnique({
      where: {
        userId_recipeId: {
          userId: req.user!.id,
          recipeId,
        },
      },
    });

    if (!favorite) {
      throw new ApiError('Recipe not in favorites');
    }

    // Remove from favorites
    await prisma.favorite.delete({
      where: {
        userId_recipeId: {
          userId: req.user!.id,
          recipeId,
        },
      },
    });

    res.json({
      success: true,
      message: 'Recipe removed from favorites',
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