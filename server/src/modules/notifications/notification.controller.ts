import type { RequestHandler } from 'express';

import { AppError } from '../../middlewares/error.middleware';
import {
  listNotificationsQuerySchema,
  notificationIdParamSchema,
  registerFcmTokenSchema,
} from './notification.schemas';
import * as notificationService from './notification.service';
import * as fcmTokenService from './fcm-token.service';

export const registerFcmToken: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const input = registerFcmTokenSchema.parse(req.body);
    await fcmTokenService.registerFcmToken(req.user.id, input);

    res.status(201).json({ registered: true });
  } catch (error) {
    next(error);
  }
};

export const listNotifications: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const query = listNotificationsQuerySchema.parse(req.query);
    const response = await notificationService.listNotifications(
      req.user.id,
      query,
    );

    res.json(response);
  } catch (error) {
    next(error);
  }
};

export const markNotificationAsRead: RequestHandler = async (
  req,
  res,
  next,
) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const { id } = notificationIdParamSchema.parse(req.params);
    const notification = await notificationService.markNotificationAsRead(
      id,
      req.user.id,
    );

    res.json({ notification });
  } catch (error) {
    next(error);
  }
};
