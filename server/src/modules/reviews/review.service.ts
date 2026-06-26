import { Types } from 'mongoose';

import { AppError } from '../../middlewares/error.middleware';
import { BookingModel } from '../bookings/booking.model';
import { EventModel, type EventDocument } from '../events/event.model';
import { ReviewModel, type ReviewDocument } from './review.model';
import { toPublicReview, type PublicReview } from './review.dto';
import type { CreateReviewInput } from './review.schemas';

export interface ReviewEligibility {
  canReview: boolean;
  reason: string | null;
}

/**
 * Business rules that decide whether a user may review an event:
 *  - the event must exist;
 *  - organizers cannot review their own event (self-promotion);
 *  - the user must have a confirmed booking (attended), to prevent spam.
 * Returns a structured result instead of throwing so it can drive both the
 * write endpoint (enforcement) and the UI (showing/hiding the button).
 */
export const getReviewEligibility = async (
  eventId: string,
  userId: string,
): Promise<ReviewEligibility> => {
  const event = (await EventModel.findById(eventId)) as EventDocument | null;

  if (!event) {
    return { canReview: false, reason: 'Event not found' };
  }

  if (event.organizerId.toString() === userId) {
    return {
      canReview: false,
      reason: 'Organizers cannot review their own event.',
    };
  }

  const hasConfirmedBooking = await BookingModel.exists({
    eventId: new Types.ObjectId(eventId),
    userId: new Types.ObjectId(userId),
    status: 'confirmed',
  });

  if (!hasConfirmedBooking) {
    return {
      canReview: false,
      reason: 'You can only review events you have booked.',
    };
  }

  return { canReview: true, reason: null };
};

export const createReview = async (
  eventId: string,
  userId: string,
  input: CreateReviewInput,
): Promise<PublicReview> => {
  const eligibility = await getReviewEligibility(eventId, userId);

  if (!eligibility.canReview) {
    const status = eligibility.reason === 'Event not found' ? 404 : 403;
    throw new AppError(
      eligibility.reason ?? 'You cannot review this event.',
      status,
    );
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

export const listReviewsByOrganizer = async (
  organizerId: string,
): Promise<PublicReview[]> => {
  const eventIds = await EventModel.find({
    organizerId: new Types.ObjectId(organizerId),
  }).distinct('_id');

  const reviews = await ReviewModel.find({ eventId: { $in: eventIds } })
    .populate('userId', 'fullName avatarUrl')
    .sort({ createdAt: -1 });

  return reviews.map((review) => toPublicReview(review as ReviewDocument));
};
