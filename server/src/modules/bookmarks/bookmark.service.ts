import { Types } from 'mongoose';

import { AppError } from '../../middlewares/error.middleware';
import { EventModel } from '../events/event.model';
import { BookmarkModel, type BookmarkDocument } from './bookmark.model';
import { toPublicBookmark, type PublicBookmark } from './bookmark.dto';
import type { ListBookmarksQuery } from './bookmark.schemas';

interface PaginatedBookmarks {
  data: PublicBookmark[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export const createBookmark = async (
  userId: string,
  eventId: string,
): Promise<PublicBookmark> => {
  const eventExists = await EventModel.exists({ _id: eventId });

  if (!eventExists) {
    throw new AppError('Event not found', 404);
  }

  const bookmark = (await BookmarkModel.findOneAndUpdate(
    {
      userId: new Types.ObjectId(userId),
      eventId: new Types.ObjectId(eventId),
    },
    {
      $setOnInsert: {
        userId: new Types.ObjectId(userId),
        eventId: new Types.ObjectId(eventId),
      },
    },
    {
      returnDocument: 'after',
      upsert: true,
    },
  )) as BookmarkDocument;

  return toPublicBookmark(bookmark);
};

export const listMyBookmarks = async (
  userId: string,
  query: ListBookmarksQuery,
): Promise<PaginatedBookmarks> => {
  const filter = {
    userId: new Types.ObjectId(userId),
  };
  const skip = (query.page - 1) * query.limit;

  const [bookmarks, total] = await Promise.all([
    BookmarkModel.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(query.limit),
    BookmarkModel.countDocuments(filter),
  ]);

  return {
    data: bookmarks.map((bookmark) =>
      toPublicBookmark(bookmark as BookmarkDocument),
    ),
    pagination: {
      page: query.page,
      limit: query.limit,
      total,
      totalPages: Math.ceil(total / query.limit),
    },
  };
};

export const deleteBookmark = async (
  userId: string,
  eventId: string,
): Promise<void> => {
  const result = await BookmarkModel.deleteOne({
    userId: new Types.ObjectId(userId),
    eventId: new Types.ObjectId(eventId),
  });

  if (result.deletedCount === 0) {
    throw new AppError('Bookmark not found', 404);
  }
};
