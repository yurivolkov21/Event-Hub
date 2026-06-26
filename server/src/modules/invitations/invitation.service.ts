import { Types } from 'mongoose';

import { AppError } from '../../middlewares/error.middleware';
import { BookingModel } from '../bookings/booking.model';
import * as bookingService from '../bookings/booking.service';
import { EventModel, type EventDocument } from '../events/event.model';
import * as notificationService from '../notifications/notification.service';
import { UserModel } from '../users/user.model';
import { InvitationModel, type InvitationDocument } from './invitation.model';
import {
  toPublicInvitation,
  toPublicInvitationWithRefs,
  type PublicInvitation,
} from './invitation.dto';
import type {
  CreateInvitationsInput,
  ListInvitationsQuery,
} from './invitation.schemas';

interface PaginatedInvitations {
  data: PublicInvitation[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export const createInvitations = async (
  fromUserId: string,
  eventId: string,
  input: CreateInvitationsInput,
): Promise<PublicInvitation[]> => {
  const event = (await EventModel.findById(eventId)) as EventDocument | null;

  if (!event) {
    throw new AppError('Event not found', 404);
  }

  if (event.status !== 'published') {
    throw new AppError('Only published events can be invited to', 400);
  }

  const uniqueUserIds = [...new Set(input.userIds)].filter(
    (userId) => userId !== fromUserId,
  );

  if (uniqueUserIds.length === 0) {
    throw new AppError('At least one invited user is required', 400);
  }

  const existingUsersCount = await UserModel.countDocuments({
    _id: {
      $in: uniqueUserIds.map((userId) => new Types.ObjectId(userId)),
    },
  });

  if (existingUsersCount !== uniqueUserIds.length) {
    throw new AppError('One or more invited users were not found', 404);
  }

  const invitations: PublicInvitation[] = [];

  for (const toUserId of uniqueUserIds) {
    const invitation = (await InvitationModel.findOneAndUpdate(
      {
        eventId: event._id,
        fromUserId: new Types.ObjectId(fromUserId),
        toUserId: new Types.ObjectId(toUserId),
      },
      {
        $set: {
          status: 'pending',
        },
        $setOnInsert: {
          eventId: event._id,
          fromUserId: new Types.ObjectId(fromUserId),
          toUserId: new Types.ObjectId(toUserId),
        },
      },
      {
        returnDocument: 'after',
        upsert: true,
      },
    )) as InvitationDocument;

    await notificationService.createNotification({
      userId: toUserId,
      type: 'invite',
      title: 'Event invitation',
      body: `You were invited to ${event.title}.`,
      data: {
        invitationId: invitation._id.toString(),
        eventId: event._id.toString(),
        fromUserId,
      },
    });

    invitations.push(toPublicInvitation(invitation));
  }

  return invitations;
};

export const listMyInvitations = async (
  userId: string,
  query: ListInvitationsQuery,
): Promise<PaginatedInvitations> => {
  const filter: Record<string, unknown> = {
    toUserId: new Types.ObjectId(userId),
  };

  if (query.status) {
    filter.status = query.status;
  }

  const skip = (query.page - 1) * query.limit;

  const [invitations, total] = await Promise.all([
    InvitationModel.find(filter)
      .populate('eventId', 'title imageUrl startAt venueName')
      .populate('fromUserId', 'fullName')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(query.limit),
    InvitationModel.countDocuments(filter),
  ]);

  return {
    data: invitations.map((invitation) =>
      toPublicInvitationWithRefs(invitation as InvitationDocument),
    ),
    pagination: {
      page: query.page,
      limit: query.limit,
      total,
      totalPages: Math.ceil(total / query.limit),
    },
  };
};

// Close the loop: tell the inviter how the recipient responded.
const notifyInviter = async (
  invitation: InvitationDocument,
  responderId: string,
  status: 'accepted' | 'rejected',
): Promise<void> => {
  const [event, responder] = await Promise.all([
    EventModel.findById(invitation.eventId).select('title'),
    UserModel.findById(responderId).select('fullName'),
  ]);

  const responderName = responder?.get('fullName') ?? 'Someone';
  const eventTitle = event?.get('title') ?? 'your event';
  const verb = status === 'accepted' ? 'accepted' : 'declined';

  await notificationService
    .createNotification({
      userId: invitation.fromUserId.toString(),
      type: 'invite_response',
      title: `Invitation ${verb}`,
      body: `${responderName} ${verb} your invitation to "${eventTitle}".`,
      data: {
        eventId: invitation.eventId.toString(),
        invitationId: invitation._id.toString(),
        status,
      },
    })
    .catch(() => undefined);
};

const findPendingInvitation = async (
  invitationId: string,
  userId: string,
): Promise<InvitationDocument> => {
  const invitation = (await InvitationModel.findOne({
    _id: invitationId,
    toUserId: new Types.ObjectId(userId),
    status: 'pending',
  })) as InvitationDocument | null;

  if (!invitation) {
    throw new AppError('Pending invitation not found', 404);
  }

  return invitation;
};

export const acceptInvitation = async (
  invitationId: string,
  userId: string,
): Promise<PublicInvitation> => {
  const invitation = await findPendingInvitation(invitationId, userId);

  // Model B: accepting an invitation reserves a seat (a confirmed booking),
  // so the user does not have to book again. Skip if they already booked.
  const alreadyBooked = await BookingModel.exists({
    eventId: invitation.eventId,
    userId: new Types.ObjectId(userId),
    status: 'confirmed',
  });

  if (!alreadyBooked) {
    // Throws (e.g. 400 "Not enough tickets available") if the event is full;
    // the invitation stays pending so the user can retry/decline.
    await bookingService.createBooking(userId, {
      eventId: invitation.eventId.toString(),
      quantity: 1,
    });
  }

  invitation.status = 'accepted';
  await invitation.save();
  await notifyInviter(invitation, userId, 'accepted');

  return toPublicInvitation(invitation);
};

export const rejectInvitation = async (
  invitationId: string,
  userId: string,
): Promise<PublicInvitation> => {
  const invitation = await findPendingInvitation(invitationId, userId);

  invitation.status = 'rejected';
  await invitation.save();
  await notifyInviter(invitation, userId, 'rejected');

  return toPublicInvitation(invitation);
};
