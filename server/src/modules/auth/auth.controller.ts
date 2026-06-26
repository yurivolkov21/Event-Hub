import type { RequestHandler } from 'express';

import { AppError } from '../../middlewares/error.middleware';
import { googleAuthSchema, loginSchema, registerSchema } from './auth.schemas';
import * as authService from './auth.service';

export const register: RequestHandler = async (req, res, next) => {
  try {
    const input = registerSchema.parse(req.body);
    const response = await authService.register(input);

    res.status(201).json(response);
  } catch (error) {
    next(error);
  }
};

export const login: RequestHandler = async (req, res, next) => {
  try {
    const input = loginSchema.parse(req.body);
    const response = await authService.login(input);

    res.json(response);
  } catch (error) {
    next(error);
  }
};

export const googleAuth: RequestHandler = async (req, res, next) => {
  try {
    const input = googleAuthSchema.parse(req.body);
    const response = await authService.googleAuth(input.idToken);

    res.json(response);
  } catch (error) {
    next(error);
  }
};

export const me: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const user = await authService.getCurrentUser(req.user.id);

    res.json({ user });
  } catch (error) {
    next(error);
  }
};
