import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { ApiError } from '../middlewares/error.middleware';

export const getAllCategories = async (req: Request, res: Response) => {
  try {
    const categories = await prisma.category.findMany({
      include: {
        _count: {
          select: {
            recipes: true,
          },
        },
      },
    });

    res.json({
      success: true,
      data: categories,
    });
  } catch (error) {
    throw error;
  }
};

export const getCategoryById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const category = await prisma.category.findUnique({
      where: { id },
      include: {
        recipes: {
          include: {
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

    if (!category) {
      throw new ApiError('Category not found');
    }

    res.json({
      success: true,
      data: category,
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

export const createCategory = async (req: Request, res: Response) => {
  try {
    const { title, color } = req.body;

    // Check if category with same title exists
    const existingCategory = await prisma.category.findUnique({
      where: { title },
    });

    if (existingCategory) {
      throw new ApiError('Category with this title already exists');
    }

    const category = await prisma.category.create({
      data: {
        title,
        color,
      },
    });

    res.status(201).json({
      success: true,
      data: category,
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

export const updateCategory = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { title, color } = req.body;

    // Check if category exists
    const existingCategory = await prisma.category.findUnique({
      where: { id },
    });

    if (!existingCategory) {
      throw new ApiError('Category not found');
    }

    // Check if new title is already taken by another category
    if (title !== existingCategory.title) {
      const titleExists = await prisma.category.findUnique({
        where: { title },
      });

      if (titleExists) {
        throw new ApiError('Category with this title already exists');
      }
    }

    const category = await prisma.category.update({
      where: { id },
      data: {
        title,
        color,
      },
    });

    res.json({
      success: true,
      data: category,
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

export const deleteCategory = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    // Check if category exists
    const existingCategory = await prisma.category.findUnique({
      where: { id },
      include: {
        _count: {
          select: {
            recipes: true,
          },
        },
      },
    });

    if (!existingCategory) {
      throw new ApiError('Category not found');
    }

    // Check if category has recipes
    if (existingCategory._count.recipes > 0) {
      throw new ApiError('Cannot delete category with associated recipes');
    }

    await prisma.category.delete({
      where: { id },
    });

    res.json({
      success: true,
      message: 'Category deleted successfully',
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