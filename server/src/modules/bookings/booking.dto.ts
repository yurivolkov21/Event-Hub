import { Types } from 'mongoose';

import type { BookingDocument } from './booking.model';

export interface PublicBookingEvent {
  id: string;
  title: string;
  imageUrl: string | null;
  startAt?: string;
  venueName: string;
}

export interface PublicBooking {
  id: string;
  userId: string;
  eventId: string;
  quantity: number;
  totalPrice: number;
  status: string;
  event?: PublicBookingEvent | null;
  createdAt?: string;
  updatedAt?: string;
}

interface PopulatedBookingEvent {
  _id: Types.ObjectId;
  title: string;
  imageUrl?: string | null;
  startAt?: Date;
  venueName: string;
}

const toISOStringOrUndefined = (value: unknown): string | undefined => {
  return value instanceof Date ? value.toISOString() : undefined;
};

const readPopulatedEvent = (eventId: unknown): PopulatedBookingEvent | null => {
  if (
    eventId &&
    typeof eventId === 'object' &&
    'title' in (eventId as Record<string, unknown>)
  ) {
    return eventId as PopulatedBookingEvent;
  }

  return null;
};

export const toPublicBooking = (booking: BookingDocument): PublicBooking => {
  const populatedEvent = readPopulatedEvent(booking.eventId);

  return {
    id: booking._id.toString(),
    userId: booking.userId.toString(),
    eventId: populatedEvent
      ? populatedEvent._id.toString()
      : booking.eventId.toString(),
    quantity: booking.quantity,
    totalPrice: booking.totalPrice,
    status: booking.status,
    event: populatedEvent
      ? {
          id: populatedEvent._id.toString(),
          title: populatedEvent.title,
          imageUrl: populatedEvent.imageUrl ?? null,
          startAt: toISOStringOrUndefined(populatedEvent.startAt),
          venueName: populatedEvent.venueName,
        }
      : null,
    createdAt: toISOStringOrUndefined(booking.get('createdAt')),
    updatedAt: toISOStringOrUndefined(booking.get('updatedAt')),
  };
};
