import cors from 'cors';
import express from 'express';
import type { Express } from 'express';
import helmet from 'helmet';
import morgan from 'morgan';

import { env } from './config/env';
import { errorHandler, notFoundHandler } from './middlewares/error.middleware';
import { authRouter } from './modules/auth/auth.routes';
import { bookingRouter } from './modules/bookings/booking.routes';
import { bookmarkRouter } from './modules/bookmarks/bookmark.routes';
import { eventRouter } from './modules/events/event.routes';
import { healthRouter } from './routes/health.routes';
import { invitationRouter } from './modules/invitations/invitation.routes';
import { notificationRouter } from './modules/notifications/notification.routes';

export const createApp = (): Express => {
  const app = express();

  app.use(helmet());
  app.use(cors());
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  if (env.NODE_ENV !== 'test') {
    app.use(morgan('dev'));
  }

  app.use('/health', healthRouter);
  app.use('/api/health', healthRouter);
  app.use('/api/auth', authRouter);
  app.use('/api/events', eventRouter);
  app.use('/api/bookings', bookingRouter);
  app.use('/api/bookmarks', bookmarkRouter);
  app.use('/api/invitations', invitationRouter);
  app.use('/api/notifications', notificationRouter);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
};
