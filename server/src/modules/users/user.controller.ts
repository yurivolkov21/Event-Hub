import type { RequestHandler } from 'express';

import { AppError } from '../../middlewares/error.middleware';
import { listUsersQuerySchema } from './user.schemas';
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
