import type { RequestHandler } from 'express';

import { AppError } from './error.middleware';
import { UserModel } from '../modules/users/user.model';
import { verifyAuthToken } from '../utils/jwt';

export const authMiddleware: RequestHandler = async (req, _res, next) => {
  try {
    const authorizationHeader = req.headers.authorization;

    if (!authorizationHeader?.startsWith('Bearer ')) {
      throw new AppError('Authentication token is required', 401);
    }

    const token = authorizationHeader.slice('Bearer '.length).trim();

    if (!token) {
      throw new AppError('Authentication token is required', 401);
    }

    const payload = verifyAuthToken(token);
    const user = await UserModel.findById(payload.userId);

    if (!user) {
      throw new AppError('Authenticated user no longer exists', 401);
    }

    req.user = {
      id: user._id.toString(),
      email: user.email,
      role: user.role,
    };

    next();
  } catch (error) {
    next(error);
  }
};

export const requireRole = (...roles: Express.User['role'][]): RequestHandler => {
  return (req, _res, next) => {
    if (!req.user) {
      return next(new AppError('Authentication token is required', 401));
    }

    if (!roles.includes(req.user.role)) {
      return next(new AppError('You are not allowed to perform this action', 403));
    }

    return next();
  };
};
