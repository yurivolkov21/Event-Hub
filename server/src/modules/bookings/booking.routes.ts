import { Router } from 'express';
import type { Router as ExpressRouter } from 'express';

import { authMiddleware } from '../../middlewares/auth.middleware';
import * as bookingController from './booking.controller';

export const bookingRouter: ExpressRouter = Router();

bookingRouter.post('/', authMiddleware, bookingController.createBooking);
bookingRouter.get('/me', authMiddleware, bookingController.listMyBookings);
bookingRouter.delete('/:id', authMiddleware, bookingController.cancelBooking);
