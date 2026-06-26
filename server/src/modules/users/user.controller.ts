import type { RequestHandler } from 'express';

import { AppError } from '../../middlewares/error.middleware';
import { listUsersQuerySchema, updateProfileSchema } from './user.schemas';
import * as userService from './user.service';

export const listUsers: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const query = listUsersQuerySchema.parse(req.query);
    const users = await userService.listUsers(req.user.id, query);

    res.json({ data: users });
  } catch (error) {
    next(error);
  }
};

export const getUserById: RequestHandler = async (req, res, next) => {
  try {
    const id = String(req.params.id ?? '');

    if (!/^[a-f\d]{24}$/i.test(id)) {
      throw new AppError('Invalid user id', 400);
    }

    const user = await userService.getUserById(id);

    res.json({ user });
  } catch (error) {
    next(error);
  }
};

export const updateMyProfile: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const input = updateProfileSchema.parse(req.body);
    const user = await userService.updateProfile(req.user.id, input);

    res.json({ user });
  } catch (error) {
    next(error);
  }
};

export const updateMyAvatar: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    if (!req.file) {
      throw new AppError('An image file is required', 400);
    }

    const user = await userService.updateAvatar(req.user.id, req.file);

    res.json({ user });
  } catch (error) {
    next(error);
  }
};
