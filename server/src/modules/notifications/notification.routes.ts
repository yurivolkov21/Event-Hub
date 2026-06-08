import { Router } from 'express';
import type { Router as ExpressRouter } from 'express';

import { authMiddleware } from '../../middlewares/auth.middleware';
import * as notificationController from './notification.controller';

export const notificationRouter: ExpressRouter = Router();

notificationRouter.get(
  '/',
  authMiddleware,
  notificationController.listNotifications,
);
notificationRouter.put(
  '/:id/read',
  authMiddleware,
  notificationController.markNotificationAsRead,
);
