import { Router } from 'express';
import type { Router as ExpressRouter } from 'express';

import {
  authMiddleware,
  requireRole,
} from '../../middlewares/auth.middleware';
import * as eventController from './event.controller';

export const eventRouter: ExpressRouter = Router();

eventRouter.get('/', eventController.listEvents);
eventRouter.get('/:id', eventController.getEventById);
eventRouter.post(
  '/',
  authMiddleware,
  requireRole('organizer', 'admin'),
  eventController.createEvent,
);
eventRouter.put(
  '/:id',
  authMiddleware,
  requireRole('organizer', 'admin'),
  eventController.updateEvent,
);
eventRouter.delete(
  '/:id',
  authMiddleware,
  requireRole('organizer', 'admin'),
  eventController.deleteEvent,
);
