import { Request, Response, NextFunction } from 'express';
import { Prisma } from '@prisma/client';

export class ApiError extends Error {
  statusCode: number;
  errors?: any[];

  constructor(message: string, statusCode: number = 400, errors: any[] = []) {
    super(message);
    this.statusCode = statusCode;
    this.errors = errors;
    Error.captureStackTrace(this, this.constructor);
  }
}

export const errorMiddleware = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error(`[Error] ${err.stack}`);

  if (err instanceof ApiError) {
    return res.status(err.statusCode).json({
      success: false,
      message: err.message,
      errors: err.errors,
      stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
    });
  }

  // Handle Prisma errors
  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    switch (err.code) {
      case 'P2002': // Unique constraint violation
        return res.status(409).json({
          success: false,
          message: 'A record with this value already exists',
          error: err.message
        });
      case 'P2025': // Record not found
        return res.status(404).json({
          success: false,
          message: 'Record not found',
          error: err.message
        });
      default:
        return res.status(400).json({
          success: false,
          message: 'Database error',
          error: err.message
        });
    }
  }

  // Handle validation errors
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      success: false,
      message: 'Validation Error',
      errors: err.message
    });
  }

  // Handle JWT errors
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({
      success: false,
      message: 'Invalid token'
    });
  }

  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({
      success: false,
      message: 'Token expired'
    });
  }

  // Default error
  res.status(500).json({
    success: false,
    message: 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
};

export class AppError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public status: string = 'error'
  ) {
    super(message);
    this.statusCode = statusCode;
    this.status = status;
  }
}

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      status: err.status,
      message: err.message,
    });
  }

  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    // Handle Prisma specific errors
    switch (err.code) {
      case 'P2002':
        return res.status(409).json({
          status: 'error',
          message: 'A record with this value already exists.',
        });
      case 'P2025':
        return res.status(404).json({
          status: 'error',
          message: 'Record not found.',
        });
      default:
        console.error('Prisma Error:', err);
        return res.status(500).json({
          status: 'error',
          message: 'Database error occurred.',
        });
    }
  }

  console.error('Unhandled Error:', err);
  return res.status(500).json({
    status: 'error',
    message: 'Internal server error',
  });
}; 