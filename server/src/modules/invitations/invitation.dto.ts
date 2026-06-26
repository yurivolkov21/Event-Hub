import { Types } from 'mongoose';

import type { InvitationDocument } from './invitation.model';

export interface PublicInvitation {
  id: string;
  eventId: string;
  fromUserId: string;
  toUserId: string;
  status: string;
  createdAt?: string;
  updatedAt?: string;
  // Enriched (populated) fields, present on the inbox listing.
  eventTitle?: string;
  eventImageUrl?: string | null;
  eventStartAt?: string;
  eventVenueName?: string;
  fromUserName?: string;
}

const toISOStringOrUndefined = (value: unknown): string | undefined => {
  return value instanceof Date ? value.toISOString() : undefined;
};

const idToString = (value: unknown): string =>
  value instanceof Types.ObjectId ? value.toString() : String(value);

export const toPublicInvitation = (
  invitation: InvitationDocument,
): PublicInvitation => ({
  id: invitation._id.toString(),
  eventId: idToString(invitation.eventId),
  fromUserId: idToString(invitation.fromUserId),
  toUserId: idToString(invitation.toUserId),
  status: invitation.status,
  createdAt: toISOStringOrUndefined(invitation.get('createdAt')),
  updatedAt: toISOStringOrUndefined(invitation.get('updatedAt')),
});

/**
 * Serializes an invitation whose `eventId` / `fromUserId` may be populated
 * documents, flattening the useful event + inviter details into the payload so
 * the invitation inbox can render a meaningful card.
 */
export const toPublicInvitationWithRefs = (
  invitation: InvitationDocument,
): PublicInvitation => {
  const base = toPublicInvitation(invitation);
  const event = invitation.eventId as unknown;
  const fromUser = invitation.fromUserId as unknown;

  if (event && typeof event === 'object' && 'title' in event) {
    const populatedEvent = event as {
      _id: Types.ObjectId;
      title?: string;
      imageUrl?: string | null;
      startAt?: Date;
      venueName?: string;
    };
    base.eventId = populatedEvent._id.toString();
    base.eventTitle = populatedEvent.title;
    base.eventImageUrl = populatedEvent.imageUrl ?? null;
    base.eventStartAt = toISOStringOrUndefined(populatedEvent.startAt);
    base.eventVenueName = populatedEvent.venueName;
  }

  if (fromUser && typeof fromUser === 'object' && 'fullName' in fromUser) {
    const populatedUser = fromUser as {
      _id: Types.ObjectId;
      fullName?: string;
    };
    base.fromUserId = populatedUser._id.toString();
    base.fromUserName = populatedUser.fullName;
  }

  return base;
};
