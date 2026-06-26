import { Router } from 'express';
import type { Router as ExpressRouter } from 'express';

import { authMiddleware } from '../../middlewares/auth.middleware';
import { uploadEventImage } from '../../middlewares/upload.middleware';
import * as userController from './user.controller';
import * as reviewController from '../reviews/review.controller';

export const userRouter: ExpressRouter = Router();

userRouter.get('/', authMiddleware, userController.listUsers);
userRouter.put('/me', authMiddleware, userController.updateMyProfile);
userRouter.post(
  '/me/avatar',
  authMiddleware,
  uploadEventImage,
  userController.updateMyAvatar,
);
userRouter.get('/:id', userController.getUserById);
userRouter.get('/:id/reviews', reviewController.listOrganizerReviews);
