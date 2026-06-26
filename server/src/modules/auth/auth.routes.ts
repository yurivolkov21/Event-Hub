import { Router } from 'express';
import type { Router as ExpressRouter } from 'express';

import { authMiddleware } from '../../middlewares/auth.middleware';
import * as authController from './auth.controller';

export const authRouter: ExpressRouter = Router();

authRouter.post('/register', authController.register);
authRouter.post('/login', authController.login);
authRouter.post('/google', authController.googleAuth);
authRouter.get('/me', authMiddleware, authController.me);
