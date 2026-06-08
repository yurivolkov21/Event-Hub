import type { BookmarkDocument } from './bookmark.model';

export interface PublicBookmark {
  id: string;
  userId: string;
  eventId: string;
  createdAt?: string;
}

export const toPublicBookmark = (
  bookmark: BookmarkDocument,
): PublicBookmark => ({
  id: bookmark._id.toString(),
  userId: bookmark.userId.toString(),
  eventId: bookmark.eventId.toString(),
  createdAt:
    bookmark.get('createdAt') instanceof Date
      ? bookmark.get('createdAt').toISOString()
      : undefined,
});
