import { Router } from 'express';
import type { Router as ExpressRouter } from 'express';

import {
  authMiddleware,
  requireRole,
} from '../../middlewares/auth.middleware';
import { uploadEventImage } from '../../middlewares/upload.middleware';
import * as eventController from './event.controller';
import * as invitationController from '../invitations/invitation.controller';
import * as reviewController from '../reviews/review.controller';

export const eventRouter: ExpressRouter = Router();

eventRouter.get('/', eventController.listEvents);
eventRouter.get('/:id', eventController.getEventById);
eventRouter.post(
  '/:eventId/invitations',
  authMiddleware,
  invitationController.createInvitations,
);
eventRouter.get('/:eventId/reviews', reviewController.listReviews);
eventRouter.get(
  '/:eventId/reviews/eligibility',
  authMiddleware,
  reviewController.getReviewEligibility,
);
eventRouter.post(
  '/:eventId/reviews',
  authMiddleware,
  reviewController.createReview,
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
