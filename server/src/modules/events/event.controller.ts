import type { RequestHandler } from 'express';

import { AppError } from '../../middlewares/error.middleware';
import {
  createEventSchema,
  eventIdParamSchema,
  listEventsQuerySchema,
  updateEventSchema,
} from './event.schemas';
import * as eventService from './event.service';

export const listEvents: RequestHandler = async (req, res, next) => {
  try {
    const query = listEventsQuerySchema.parse(req.query);
    const response = await eventService.listEvents(query);

    res.json(response);
  } catch (error) {
    next(error);
  }
};

export const getEventById: RequestHandler = async (req, res, next) => {
  try {
    const { id } = eventIdParamSchema.parse(req.params);
    const event = await eventService.getEventById(id);

    res.json({ event });
  } catch (error) {
    next(error);
  }
};

export const createEvent: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const input = createEventSchema.parse(req.body);
    const event = await eventService.createEvent(req.user.id, input);

    res.status(201).json({ event });
  } catch (error) {
    next(error);
  }
};

export const updateEvent: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const { id } = eventIdParamSchema.parse(req.params);
    const input = updateEventSchema.parse(req.body);
    const event = await eventService.updateEvent(id, input, req.user);

    res.json({ event });
  } catch (error) {
    next(error);
  }
};

export const deleteEvent: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const { id } = eventIdParamSchema.parse(req.params);
    await eventService.deleteEvent(id, req.user);

    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
