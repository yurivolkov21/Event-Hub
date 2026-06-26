import { Types } from 'mongoose';

import type { ReviewDocument } from './review.model';

export interface PublicReview {
  id: string;
  eventId: string;
  userId: string;
  userName: string | null;
  userAvatar: string | null;
  rating: number;
  comment: string;
  createdAt?: string;
}

interface PopulatedReviewer {
  _id: Types.ObjectId;
  fullName: string;
  avatarUrl?: string | null;
}

const toISOStringOrUndefined = (value: unknown): string | undefined => {
  return value instanceof Date ? value.toISOString() : undefined;
};

const readReviewer = (userId: unknown): PopulatedReviewer | null => {
  if (
    userId &&
    typeof userId === 'object' &&
    'fullName' in (userId as Record<string, unknown>)
  ) {
    return userId as PopulatedReviewer;
  }

  return null;
};

export const toPublicReview = (review: ReviewDocument): PublicReview => {
  const reviewer = readReviewer(review.userId);

  return {
    id: review._id.toString(),
    eventId: review.eventId.toString(),
    userId: reviewer ? reviewer._id.toString() : review.userId.toString(),
    userName: reviewer ? reviewer.fullName : null,
    userAvatar: reviewer ? reviewer.avatarUrl ?? null : null,
    rating: review.rating,
    comment: review.comment ?? '',
    createdAt: toISOStringOrUndefined(review.get('createdAt')),
  };
};
