import type { RequestHandler } from 'express';

import { AppError } from '../../middlewares/error.middleware';
import {
  bookingIdParamSchema,
  createBookingSchema,
  listBookingsQuerySchema,
} from './booking.schemas';
import * as bookingService from './booking.service';

export const createBooking: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const input = createBookingSchema.parse(req.body);
    const booking = await bookingService.createBooking(req.user.id, input);

    res.status(201).json({ booking });
  } catch (error) {
    next(error);
  }
};

export const listMyBookings: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const query = listBookingsQuerySchema.parse(req.query);
    const response = await bookingService.listMyBookings(req.user.id, query);

    res.json(response);
  } catch (error) {
    next(error);
  }
};

export const cancelBooking: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const { id } = bookingIdParamSchema.parse(req.params);
    await bookingService.cancelBooking(id, req.user.id);

    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
