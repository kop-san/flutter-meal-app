import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { ApiError } from '../middlewares/error.middleware';

export const getAllRecipes = async (req: Request, res: Response) => {
  try {
    const recipes = await prisma.recipe.findMany({
      include: {
        categories: true,
        author: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });

    res.json({
      success: true,
      data: recipes,
    });
  } catch (error) {
    throw error;
  }
};

export const getRecipeById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const recipe = await prisma.recipe.findUnique({
      where: { id },
      include: {
        categories: true,
        author: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });

    if (!recipe) {
      throw new ApiError('Recipe not found');
    }

    res.json({
      success: true,
      data: recipe,
    });
  } catch (error) {
    if (error instanceof ApiError) {
      res.status(404).json({
        success: false,
        message: error.message,
      });
    } else {
      throw error;
    }
  }
};

export const createRecipe = async (req: Request, res: Response) => {
  try {
    const {
      title,
      imageUrl,
      duration,
      description,
      ingredients,
      steps,
      isGlutenFree,
      isVegan,
      isVegetarian,
      isLactoseFree,
      categoryIds,
    } = req.body;

    const recipe = await prisma.recipe.create({
      data: {
        title,
        imageUrl,
        duration,
        description,
        ingredients,
        steps,
        isGlutenFree,
        isVegan,
        isVegetarian,
        isLactoseFree,
        authorId: req.user!.id,
        categories: {
          connect: categoryIds.map((id: string) => ({ id })),
        },
      },
      include: {
        categories: true,
        author: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });

    res.status(201).json({
      success: true,
      data: recipe,
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

export const updateRecipe = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const {
      title,
      imageUrl,
      duration,
      description,
      ingredients,
      steps,
      isGlutenFree,
      isVegan,
      isVegetarian,
      isLactoseFree,
      categoryIds,
    } = req.body;

    // Check if recipe exists and belongs to user
    const existingRecipe = await prisma.recipe.findUnique({
      where: { id },
    });

    if (!existingRecipe) {
      throw new ApiError('Recipe not found');
    }

    if (existingRecipe.authorId !== req.user!.id) {
      throw new ApiError('Not authorized to update this recipe');
    }

    const recipe = await prisma.recipe.update({
      where: { id },
      data: {
        title,
        imageUrl,
        duration,
        description,
        ingredients,
        steps,
        isGlutenFree,
        isVegan,
        isVegetarian,
        isLactoseFree,
        categories: {
          set: categoryIds.map((id: string) => ({ id })),
        },
      },
      include: {
        categories: true,
        author: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });

    res.json({
      success: true,
      data: recipe,
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

export const deleteRecipe = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    // Check if recipe exists and belongs to user
    const existingRecipe = await prisma.recipe.findUnique({
      where: { id },
    });

    if (!existingRecipe) {
      throw new ApiError('Recipe not found');
    }

    if (existingRecipe.authorId !== req.user!.id) {
      throw new ApiError('Not authorized to delete this recipe');
    }

    await prisma.recipe.delete({
      where: { id },
    });

    res.json({
      success: true,
      message: 'Recipe deleted successfully',
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