import { Types } from 'mongoose';

import { AppError } from '../../middlewares/error.middleware';
import { InvitationModel } from '../invitations/invitation.model';
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

/**
 * Whether a notification may be cleared (deleted). Read notifications can be
 * cleared; an invitation notification additionally requires that the invitation
 * has been responded to (accepted/rejected) — a pending invite cannot be
 * dismissed without answering it.
 */
const assertClearable = async (
  notification: NotificationDocument,
): Promise<void> => {
  if (notification.type === 'invite') {
    const invitationId = notification.data?.get('invitationId');

    if (invitationId) {
      const invitation = await InvitationModel.findById(invitationId).select(
        'status',
      );

      if (invitation && invitation.get('status') === 'pending') {
        throw new AppError(
          'Respond to the invitation before clearing it.',
          400,
        );
      }
    }

    return;
  }

  if (!notification.readAt) {
    throw new AppError('Mark the notification as read before clearing it.', 400);
  }
};

export const deleteNotification = async (
  notificationId: string,
  userId: string,
): Promise<void> => {
  const notification = (await NotificationModel.findOne({
    _id: notificationId,
    userId: new Types.ObjectId(userId),
  })) as NotificationDocument | null;

  if (!notification) {
    throw new AppError('Notification not found', 404);
  }

  await assertClearable(notification);
  await notification.deleteOne();
};

/**
 * Clears every notification the rules allow: read non-invite notifications and
 * invitations that have already been answered. Pending invites are kept.
 */
export const clearReadNotifications = async (
  userId: string,
): Promise<{ cleared: number }> => {
  const candidates = (await NotificationModel.find({
    userId: new Types.ObjectId(userId),
  })) as NotificationDocument[];

  let cleared = 0;

  for (const notification of candidates) {
    try {
      await assertClearable(notification);
      await notification.deleteOne();
      cleared += 1;
    } catch {
      // Skip anything not yet clearable (unread, or pending invitations).
    }
  }

  return { cleared };
};
