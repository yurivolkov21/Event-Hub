import type { BookingDocument } from './booking.model';

export interface PublicBooking {
  id: string;
  userId: string;
  eventId: string;
  quantity: number;
  totalPrice: number;
  status: string;
  createdAt?: string;
  updatedAt?: string;
}

const toISOStringOrUndefined = (value: unknown): string | undefined => {
  return value instanceof Date ? value.toISOString() : undefined;
};

export const toPublicBooking = (booking: BookingDocument): PublicBooking => ({
  id: booking._id.toString(),
  userId: booking.userId.toString(),
  eventId: booking.eventId.toString(),
  quantity: booking.quantity,
  totalPrice: booking.totalPrice,
  status: booking.status,
  createdAt: toISOStringOrUndefined(booking.get('createdAt')),
  updatedAt: toISOStringOrUndefined(booking.get('updatedAt')),
});
