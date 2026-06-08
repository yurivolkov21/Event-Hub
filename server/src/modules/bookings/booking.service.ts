import { Types } from 'mongoose';

import { AppError } from '../../middlewares/error.middleware';
import { EventModel, type EventDocument } from '../events/event.model';
import * as notificationService from '../notifications/notification.service';
import { BookingModel, type BookingDocument } from './booking.model';
import { toPublicBooking, type PublicBooking } from './booking.dto';
import type {
  CreateBookingInput,
  ListBookingsQuery,
} from './booking.schemas';

interface PaginatedBookings {
  data: PublicBooking[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export const createBooking = async (
  userId: string,
  input: CreateBookingInput,
): Promise<PublicBooking> => {
  const event = (await EventModel.findById(
    input.eventId,
  )) as EventDocument | null;

  if (!event) {
    throw new AppError('Event not found', 404);
  }

  if (event.status !== 'published') {
    throw new AppError('Only published events can be booked', 400);
  }

  const remainingCapacity = event.capacity - event.bookedCount;

  if (input.quantity > remainingCapacity) {
    throw new AppError('Not enough tickets available', 400);
  }

  event.bookedCount += input.quantity;
  await event.save();

  const booking = await BookingModel.create({
    userId: new Types.ObjectId(userId),
    eventId: event._id,
    quantity: input.quantity,
    totalPrice: event.price * input.quantity,
    status: 'confirmed',
  });

  await notificationService.createNotification({
    userId,
    type: 'booking',
    title: 'Booking confirmed',
    body: `Your booking for ${event.title} is confirmed.`,
    data: {
      bookingId: booking._id.toString(),
      eventId: event._id.toString(),
    },
  });

  return toPublicBooking(booking as BookingDocument);
};

export const listMyBookings = async (
  userId: string,
  query: ListBookingsQuery,
): Promise<PaginatedBookings> => {
  const filter: Record<string, unknown> = {
    userId: new Types.ObjectId(userId),
  };

  if (query.status) {
    filter.status = query.status;
  }

  const skip = (query.page - 1) * query.limit;

  const [bookings, total] = await Promise.all([
    BookingModel.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(query.limit),
    BookingModel.countDocuments(filter),
  ]);

  return {
    data: bookings.map((booking) => toPublicBooking(booking as BookingDocument)),
    pagination: {
      page: query.page,
      limit: query.limit,
      total,
      totalPages: Math.ceil(total / query.limit),
    },
  };
};

export const cancelBooking = async (
  bookingId: string,
  userId: string,
): Promise<void> => {
  const booking = (await BookingModel.findOne({
    _id: bookingId,
    userId: new Types.ObjectId(userId),
  })) as BookingDocument | null;

  if (!booking) {
    throw new AppError('Booking not found', 404);
  }

  if (booking.status === 'cancelled') {
    throw new AppError('Booking is already cancelled', 400);
  }

  booking.status = 'cancelled';
  await booking.save();

  await EventModel.updateOne(
    { _id: booking.eventId },
    {
      $inc: {
        bookedCount: -booking.quantity,
      },
    },
  );
};
