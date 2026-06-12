import { Router } from 'express';
import type { Router as ExpressRouter } from 'express';

import { authMiddleware } from '../../middlewares/auth.middleware';
import * as userController from './user.controller';

export const userRouter: ExpressRouter = Router();

userRouter.get('/', authMiddleware, userController.listUsers);
