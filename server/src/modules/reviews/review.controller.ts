import type { RequestHandler } from 'express';

import { AppError } from '../../middlewares/error.middleware';
import { createReviewSchema, eventIdParamSchema } from './review.schemas';
import * as reviewService from './review.service';

export const listReviews: RequestHandler = async (req, res, next) => {
  try {
    const { eventId } = eventIdParamSchema.parse(req.params);
    const reviews = await reviewService.listReviews(eventId);

    res.json({ data: reviews });
  } catch (error) {
    next(error);
  }
};

export const listOrganizerReviews: RequestHandler = async (req, res, next) => {
  try {
    const organizerId = String(req.params.id ?? '');

    if (!/^[a-f\d]{24}$/i.test(organizerId)) {
      throw new AppError('Invalid user id', 400);
    }

    const reviews = await reviewService.listReviewsByOrganizer(organizerId);

    res.json({ data: reviews });
  } catch (error) {
    next(error);
  }
};

export const createReview: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const { eventId } = eventIdParamSchema.parse(req.params);
    const input = createReviewSchema.parse(req.body);
    const review = await reviewService.createReview(
      eventId,
      req.user.id,
      input,
    );

    res.status(201).json({ review });
  } catch (error) {
    next(error);
  }
};
