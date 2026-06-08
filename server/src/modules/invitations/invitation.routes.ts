import { Router } from 'express';
import type { Router as ExpressRouter } from 'express';

import { authMiddleware } from '../../middlewares/auth.middleware';
import * as invitationController from './invitation.controller';

export const invitationRouter: ExpressRouter = Router();

invitationRouter.get(
  '/me',
  authMiddleware,
  invitationController.listMyInvitations,
);
invitationRouter.put(
  '/:id/accept',
  authMiddleware,
  invitationController.acceptInvitation,
);
invitationRouter.put(
  '/:id/reject',
  authMiddleware,
  invitationController.rejectInvitation,
);
