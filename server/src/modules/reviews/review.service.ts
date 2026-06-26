import { Types } from 'mongoose';

import { AppError } from '../../middlewares/error.middleware';
import { EventModel } from '../events/event.model';
import { ReviewModel, type ReviewDocument } from './review.model';
import { toPublicReview, type PublicReview } from './review.dto';
import type { CreateReviewInput } from './review.schemas';

export const createReview = async (
  eventId: string,
  userId: string,
  input: CreateReviewInput,
): Promise<PublicReview> => {
  const eventExists = await EventModel.exists({ _id: eventId });

  if (!eventExists) {
    throw new AppError('Event not found', 404);
  }

  // Upsert: a user keeps a single review per event and can update it.
  const review = await ReviewModel.findOneAndUpdate(
    {
      eventId: new Types.ObjectId(eventId),
      userId: new Types.ObjectId(userId),
    },
    {
      $set: {
        rating: input.rating,
        comment: input.comment,
      },
    },
    {
      upsert: true,
      new: true,
      setDefaultsOnInsert: true,
    },
  ).populate('userId', 'fullName avatarUrl');

  return toPublicReview(review as ReviewDocument);
};

export const listReviews = async (
  eventId: string,
): Promise<PublicReview[]> => {
  const reviews = await ReviewModel.find({
    eventId: new Types.ObjectId(eventId),
  })
    .populate('userId', 'fullName avatarUrl')
    .sort({ createdAt: -1 });

  return reviews.map((review) => toPublicReview(review as ReviewDocument));
};
