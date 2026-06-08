import { z } from 'zod';

const objectIdSchema = z
  .string()
  .regex(/^[a-f\d]{24}$/i, 'Invalid ObjectId');

export const createInvitationsParamSchema = z.object({
  eventId: objectIdSchema,
});

export const createInvitationsSchema = z.object({
  userIds: z.array(objectIdSchema).min(1).max(20),
});

export const invitationIdParamSchema = z.object({
  id: objectIdSchema,
});

export const listInvitationsQuerySchema = z.object({
  status: z.enum(['pending', 'accepted', 'rejected']).optional(),
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(50).default(20),
});

export type CreateInvitationsInput = z.infer<typeof createInvitationsSchema>;
export type ListInvitationsQuery = z.infer<typeof listInvitationsQuerySchema>;
