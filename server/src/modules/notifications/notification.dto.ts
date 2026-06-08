import type { NotificationDocument } from './notification.model';

export interface PublicNotification {
  id: string;
  userId: string;
  type: string;
  title: string;
  body: string;
  data: Record<string, string>;
  readAt: string | null;
  createdAt?: string;
}

const mapToRecord = (value: unknown): Record<string, string> => {
  if (value instanceof Map) {
    return Object.fromEntries(value.entries());
  }

  if (typeof value === 'object' && value !== null) {
    return value as Record<string, string>;
  }

  return {};
};

export const toPublicNotification = (
  notification: NotificationDocument,
): PublicNotification => ({
  id: notification._id.toString(),
  userId: notification.userId.toString(),
  type: notification.type,
  title: notification.title,
  body: notification.body,
  data: mapToRecord(notification.data),
  readAt: notification.readAt?.toISOString() ?? null,
  createdAt:
    notification.get('createdAt') instanceof Date
      ? notification.get('createdAt').toISOString()
      : undefined,
});
