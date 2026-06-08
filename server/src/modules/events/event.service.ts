import { Types } from 'mongoose';

import { AppError } from '../../middlewares/error.middleware';
import { toPublicEvent, type PublicEvent } from './event.dto';
import { EventModel, type EventDocument } from './event.model';
import type {
  CreateEventInput,
  ListEventsQuery,
  UpdateEventInput,
} from './event.schemas';

interface CurrentUser {
  id: string;
  role: Express.User['role'];
}

interface PaginatedEvents {
  data: PublicEvent[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

const buildSort = (sort: ListEventsQuery['sort']) => {
  const direction: 1 | -1 = sort.startsWith('-') ? -1 : 1;
  const field = sort.replace('-', '');

  return { [field]: direction };
};

const buildListFilter = (query: ListEventsQuery): Record<string, unknown> => {
  const filter: Record<string, unknown> = {};

  if (query.search) {
    filter.$text = { $search: query.search };
  }

  if (query.categoryId) {
    filter.categoryId = new Types.ObjectId(query.categoryId);
  }

  if (query.status) {
    filter.status = query.status;
  }

  if (query.date) {
    const startOfDay = new Date(query.date);
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date(query.date);
    endOfDay.setHours(23, 59, 59, 999);

    filter.startAt = {
      $gte: startOfDay,
      $lte: endOfDay,
    };
  }

  if (query.minPrice !== undefined || query.maxPrice !== undefined) {
    const priceFilter: Record<string, number> = {};

    if (query.minPrice !== undefined) {
      priceFilter.$gte = query.minPrice;
    }

    if (query.maxPrice !== undefined) {
      priceFilter.$lte = query.maxPrice;
    }

    filter.price = priceFilter;
  }

  return filter;
};

const assertCanManageEvent = (event: EventDocument, user: CurrentUser) => {
  const isOwner = event.organizerId.toString() === user.id;
  const isAdmin = user.role === 'admin';

  if (!isOwner && !isAdmin) {
    throw new AppError('You are not allowed to manage this event', 403);
  }
};

export const listEvents = async (
  query: ListEventsQuery,
): Promise<PaginatedEvents> => {
  const filter = buildListFilter(query);
  const skip = (query.page - 1) * query.limit;

  const [events, total] = await Promise.all([
    EventModel.find(filter)
      .sort(buildSort(query.sort))
      .skip(skip)
      .limit(query.limit),
    EventModel.countDocuments(filter),
  ]);

  return {
    data: events.map((event) => toPublicEvent(event as EventDocument)),
    pagination: {
      page: query.page,
      limit: query.limit,
      total,
      totalPages: Math.ceil(total / query.limit),
    },
  };
};

export const getEventById = async (eventId: string): Promise<PublicEvent> => {
  const event = (await EventModel.findById(eventId)) as EventDocument | null;

  if (!event) {
    throw new AppError('Event not found', 404);
  }

  return toPublicEvent(event);
};

export const createEvent = async (
  organizerId: string,
  input: CreateEventInput,
): Promise<PublicEvent> => {
  const event = await EventModel.create({
    ...input,
    categoryId: new Types.ObjectId(input.categoryId),
    organizerId: new Types.ObjectId(organizerId),
    bookedCount: 0,
  });

  return toPublicEvent(event as EventDocument);
};

export const updateEvent = async (
  eventId: string,
  input: UpdateEventInput,
  user: CurrentUser,
): Promise<PublicEvent> => {
  const event = (await EventModel.findById(eventId)) as EventDocument | null;

  if (!event) {
    throw new AppError('Event not found', 404);
  }

  assertCanManageEvent(event, user);

  event.set({
    ...input,
    categoryId: input.categoryId
      ? new Types.ObjectId(input.categoryId)
      : event.categoryId,
  });

  if (event.endAt <= event.startAt) {
    throw new AppError('End date must be after start date', 400);
  }

  await event.save();

  return toPublicEvent(event);
};

export const deleteEvent = async (
  eventId: string,
  user: CurrentUser,
): Promise<void> => {
  const event = (await EventModel.findById(eventId)) as EventDocument | null;

  if (!event) {
    throw new AppError('Event not found', 404);
  }

  assertCanManageEvent(event, user);

  await event.deleteOne();
};
