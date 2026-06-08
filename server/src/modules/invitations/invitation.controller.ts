import type { RequestHandler } from 'express';

import { AppError } from '../../middlewares/error.middleware';
import {
  createInvitationsParamSchema,
  createInvitationsSchema,
  invitationIdParamSchema,
  listInvitationsQuerySchema,
} from './invitation.schemas';
import * as invitationService from './invitation.service';

export const createInvitations: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const { eventId } = createInvitationsParamSchema.parse(req.params);
    const input = createInvitationsSchema.parse(req.body);
    const invitations = await invitationService.createInvitations(
      req.user.id,
      eventId,
      input,
    );

    res.status(201).json({ invitations });
  } catch (error) {
    next(error);
  }
};

export const listMyInvitations: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const query = listInvitationsQuerySchema.parse(req.query);
    const response = await invitationService.listMyInvitations(
      req.user.id,
      query,
    );

    res.json(response);
  } catch (error) {
    next(error);
  }
};

export const acceptInvitation: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const { id } = invitationIdParamSchema.parse(req.params);
    const invitation = await invitationService.acceptInvitation(id, req.user.id);

    res.json({ invitation });
  } catch (error) {
    next(error);
  }
};

export const rejectInvitation: RequestHandler = async (req, res, next) => {
  try {
    if (!req.user) {
      throw new AppError('Authentication token is required', 401);
    }

    const { id } = invitationIdParamSchema.parse(req.params);
    const invitation = await invitationService.rejectInvitation(id, req.user.id);

    res.json({ invitation });
  } catch (error) {
    next(error);
  }
};
