import { Router } from 'express';
import type { Router as ExpressRouter } from 'express';

import {
  authMiddleware,
  requireRole,
} from '../../middlewares/auth.middleware';
import { uploadEventImage } from '../../middlewares/upload.middleware';
import * as eventController from './event.controller';
import * as invitationController from '../invitations/invitation.controller';

export const eventRouter: ExpressRouter = Router();

eventRouter.get('/', eventController.listEvents);
eventRouter.get('/:id', eventController.getEventById);
eventRouter.post(
  '/:eventId/invitations',
  authMiddleware,
  invitationController.createInvitations,
);
eventRouter.post(
  '/',
  authMiddleware,
  requireRole('organizer', 'admin'),
  uploadEventImage,
  eventController.createEvent,
);
eventRouter.put(
  '/:id',
  authMiddleware,
  requireRole('organizer', 'admin'),
  uploadEventImage,
  eventController.updateEvent,
);
eventRouter.delete(
  '/:id',
  authMiddleware,
  requireRole('organizer', 'admin'),
  eventController.deleteEvent,
);
