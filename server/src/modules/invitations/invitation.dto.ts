import type { InvitationDocument } from './invitation.model';

export interface PublicInvitation {
  id: string;
  eventId: string;
  fromUserId: string;
  toUserId: string;
  status: string;
  createdAt?: string;
  updatedAt?: string;
}

const toISOStringOrUndefined = (value: unknown): string | undefined => {
  return value instanceof Date ? value.toISOString() : undefined;
};

export const toPublicInvitation = (
  invitation: InvitationDocument,
): PublicInvitation => ({
  id: invitation._id.toString(),
  eventId: invitation.eventId.toString(),
  fromUserId: invitation.fromUserId.toString(),
  toUserId: invitation.toUserId.toString(),
  status: invitation.status,
  createdAt: toISOStringOrUndefined(invitation.get('createdAt')),
  updatedAt: toISOStringOrUndefined(invitation.get('updatedAt')),
});
