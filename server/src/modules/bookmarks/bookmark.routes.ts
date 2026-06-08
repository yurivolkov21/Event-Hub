import { Router } from 'express';
import type { Router as ExpressRouter } from 'express';

import { authMiddleware } from '../../middlewares/auth.middleware';
import * as bookmarkController from './bookmark.controller';

export const bookmarkRouter: ExpressRouter = Router();

bookmarkRouter.post(
  '/:eventId',
  authMiddleware,
  bookmarkController.createBookmark,
);
bookmarkRouter.get('/me', authMiddleware, bookmarkController.listMyBookmarks);
bookmarkRouter.delete(
  '/:eventId',
  authMiddleware,
  bookmarkController.deleteBookmark,
);
