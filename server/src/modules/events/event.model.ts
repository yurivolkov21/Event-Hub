import {
  HydratedDocument,
  Schema,
  Types,
  model,
  type InferSchemaType,
} from 'mongoose';

export const eventStatuses = ['draft', 'published', 'cancelled'] as const;
export type EventStatus = (typeof eventStatuses)[number];

const eventSchema = new Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
      minlength: 2,
      maxlength: 120,
    },
    description: {
      type: String,
      required: true,
      trim: true,
      minlength: 10,
      maxlength: 3000,
    },
    categoryId: {
      type: Schema.Types.ObjectId,
      required: true,
      index: true,
    },
    organizerId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    imageUrl: {
      type: String,
      default: null,
    },
    imagePublicId: {
      type: String,
      default: null,
    },
    startAt: {
      type: Date,
      required: true,
      index: true,
    },
    endAt: {
      type: Date,
      required: true,
    },
    venueName: {
      type: String,
      required: true,
      trim: true,
      maxlength: 160,
    },
    address: {
      type: String,
      required: true,
      trim: true,
      maxlength: 240,
    },
    city: {
      type: String,
      default: null,
      trim: true,
      maxlength: 120,
    },
    country: {
      type: String,
      default: null,
      trim: true,
      maxlength: 120,
    },
    latitude: {
      type: Number,
      default: null,
      min: -90,
      max: 90,
    },
    longitude: {
      type: Number,
      default: null,
      min: -180,
      max: 180,
    },
    price: {
      type: Number,
      required: true,
      min: 0,
    },
    capacity: {
      type: Number,
      required: true,
      min: 1,
    },
    bookedCount: {
      type: Number,
      default: 0,
      min: 0,
    },
    status: {
      type: String,
      enum: eventStatuses,
      default: 'published',
      index: true,
    },
  },
  {
    timestamps: true,
    versionKey: false,
  },
);

eventSchema.index({
  title: 'text',
  description: 'text',
  venueName: 'text',
  address: 'text',
});

eventSchema.index({ latitude: 1, longitude: 1 });

eventSchema.set('toJSON', {
  transform(_document, returnedObject: Record<string, unknown>) {
    const id = returnedObject._id;

    if (id instanceof Types.ObjectId) {
      returnedObject.id = id.toString();
    }

    delete returnedObject._id;

    return returnedObject;
  },
});

export type Event = InferSchemaType<typeof eventSchema>;
export type EventDocument = HydratedDocument<Event> & { _id: Types.ObjectId };

export const EventModel = model<Event>('Event', eventSchema);
