import { Types } from 'mongoose';

import { AppError } from '../../middlewares/error.middleware';
import {
  NotificationModel,
  type NotificationDocument,
  type NotificationType,
} from './notification.model';
import {
  toPublicNotification,
  type PublicNotification,
} from './notification.dto';
import * as fcmTokenService from './fcm-token.service';
import type { ListNotificationsQuery } from './notification.schemas';

interface CreateNotificationInput {
  userId: string;
  type: NotificationType;
  title: string;
  body: string;
  data?: Record<string, string>;
}

interface PaginatedNotifications {
  data: PublicNotification[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export const createNotification = async (
  input: CreateNotificationInput,
): Promise<PublicNotification> => {
  const notification = await NotificationModel.create({
    userId: new Types.ObjectId(input.userId),
    type: input.type,
    title: input.title,
    body: input.body,
    data: input.data ?? {},
  });

  await fcmTokenService
    .sendPushToUser(input.userId, {
      title: input.title,
      body: input.body,
      data: {
        ...(input.data ?? {}),
        notificationId: notification._id.toString(),
        type: input.type,
      },
    })
    .catch(() => undefined);

  return toPublicNotification(notification as NotificationDocument);
};

export const listNotifications = async (
  userId: string,
  query: ListNotificationsQuery,
): Promise<PaginatedNotifications> => {
  const filter: Record<string, unknown> = {
    userId: new Types.ObjectId(userId),
  };

  if (query.unreadOnly) {
    filter.readAt = null;
  }

  const skip = (query.page - 1) * query.limit;

  const [notifications, total] = await Promise.all([
    NotificationModel.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(query.limit),
    NotificationModel.countDocuments(filter),
  ]);

  return {
    data: notifications.map((notification) =>
      toPublicNotification(notification as NotificationDocument),
    ),
    pagination: {
      page: query.page,
      limit: query.limit,
      total,
      totalPages: Math.ceil(total / query.limit),
    },
  };
};

export const markNotificationAsRead = async (
  notificationId: string,
  userId: string,
): Promise<PublicNotification> => {
  const notification = (await NotificationModel.findOneAndUpdate(
    {
      _id: notificationId,
      userId: new Types.ObjectId(userId),
    },
    {
      $set: {
        readAt: new Date(),
      },
    },
    {
      returnDocument: 'after',
    },
  )) as NotificationDocument | null;

  if (!notification) {
    throw new AppError('Notification not found', 404);
  }

  return toPublicNotification(notification);
};
