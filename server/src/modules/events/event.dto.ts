import { Types } from 'mongoose';

import type { EventDocument } from './event.model';

export interface PublicEvent {
  id: string;
  title: string;
  description: string;
  categoryId: string;
  organizerId: string;
  organizerName: string | null;
  imageUrl: string | null | undefined;
  startAt: string;
  endAt: string;
  venueName: string;
  address: string;
  city: string | null | undefined;
  country: string | null | undefined;
  latitude: number | null | undefined;
  longitude: number | null | undefined;
  price: number;
  capacity: number;
  bookedCount: number;
  status: string;
  createdAt?: string;
  updatedAt?: string;
}

interface PopulatedOrganizer {
  _id: Types.ObjectId;
  fullName: string;
}

const toISOStringOrUndefined = (value: unknown): string | undefined => {
  return value instanceof Date ? value.toISOString() : undefined;
};

const readPopulatedOrganizer = (
  organizerId: unknown,
): PopulatedOrganizer | null => {
  if (
    organizerId &&
    typeof organizerId === 'object' &&
    'fullName' in (organizerId as Record<string, unknown>)
  ) {
    return organizerId as PopulatedOrganizer;
  }

  return null;
};

export const toPublicEvent = (event: EventDocument): PublicEvent => {
  const organizer = readPopulatedOrganizer(event.organizerId);

  return {
    id: event._id.toString(),
    title: event.title,
    description: event.description,
    categoryId: event.categoryId.toString(),
    organizerId: organizer
      ? organizer._id.toString()
      : event.organizerId.toString(),
    organizerName: organizer ? organizer.fullName : null,
    imageUrl: event.imageUrl,
    startAt: event.startAt.toISOString(),
    endAt: event.endAt.toISOString(),
    venueName: event.venueName,
    address: event.address,
    city: event.city,
    country: event.country,
    latitude: event.latitude,
    longitude: event.longitude,
    price: event.price,
    capacity: event.capacity,
    bookedCount: event.bookedCount,
    status: event.status,
    createdAt: toISOStringOrUndefined(event.get('createdAt')),
    updatedAt: toISOStringOrUndefined(event.get('updatedAt')),
  };
};
