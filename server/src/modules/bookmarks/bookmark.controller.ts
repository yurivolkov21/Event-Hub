import type { RequestHandler } from 'express';

import { AppError } from '../../middlewares/error.middleware';
import {
  bookmarkEventParamSchema,
  listBookmarksQuerySchema,
} from './bookmark.schemas';
import * as bookmarkService from './bookmark.service';

export const createBookmark: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const { eventId } = bookmarkEventParamSchema.parse(req.params);
    const bookmark = await bookmarkService.createBookmark(req.user.id, eventId);

    res.status(201).json({ bookmark });
  } catch (error) {
    next(error);
  }
};

export const listMyBookmarks: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const query = listBookmarksQuerySchema.parse(req.query);
    const response = await bookmarkService.listMyBookmarks(req.user.id, query);

    res.json(response);
  } catch (error) {
    next(error);
  }
};

export const deleteBookmark: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const { eventId } = bookmarkEventParamSchema.parse(req.params);
    await bookmarkService.deleteBookmark(req.user.id, eventId);

    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
