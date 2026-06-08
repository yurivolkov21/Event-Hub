import type { RequestHandler } from 'express';

import { AppError } from '../../middlewares/error.middleware';
import {
  createEventSchema,
  eventIdParamSchema,
  listEventsQuerySchema,
  updateEventSchema,
} from './event.schemas';
import * as eventService from './event.service';
import { uploadImageToCloudinary } from '../images/image-storage.service';

const imageUrlValidationPlaceholder =
  'https://eventhub.local/upload-placeholder.jpg';

const buildBodyWithOptionalUploadedImage = (
  body: unknown,
  file: Express.Multer.File | undefined,
) => {
  if (!file) {
    return body;
  }

  return {
    ...(typeof body === 'object' && body !== null ? body : {}),
    imageUrl: imageUrlValidationPlaceholder,
  };
};

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

    const input = createEventSchema.parse(
      buildBodyWithOptionalUploadedImage(req.body, req.file),
    );

    if (req.file) {
      const uploadedImage = await uploadImageToCloudinary(req.file);
      input.imageUrl = uploadedImage.imageUrl;

      const event = await eventService.createEvent(req.user.id, {
        ...input,
        imagePublicId: uploadedImage.imagePublicId,
      });

      res.status(201).json({ event });
      return;
    }

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
    const input = updateEventSchema.parse(
      buildBodyWithOptionalUploadedImage(req.body, req.file),
    );

    if (req.file) {
      const uploadedImage = await uploadImageToCloudinary(req.file);
      input.imageUrl = uploadedImage.imageUrl;

      const event = await eventService.updateEvent(
        id,
        {
          ...input,
          imagePublicId: uploadedImage.imagePublicId,
        },
        req.user,
      );

      res.json({ event });
      return;
    }

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
