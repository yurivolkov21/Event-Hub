import {
  HydratedDocument,
  Schema,
  Types,
  model,
  type InferSchemaType,
} from 'mongoose';

export const bookingStatuses = ['confirmed', 'cancelled'] as const;
export type BookingStatus = (typeof bookingStatuses)[number];

const bookingSchema = new Schema(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    eventId: {
      type: Schema.Types.ObjectId,
      ref: 'Event',
      required: true,
      index: true,
    },
    quantity: {
      type: Number,
      required: true,
      min: 1,
    },
    totalPrice: {
      type: Number,
      required: true,
      min: 0,
    },
    status: {
      type: String,
      enum: bookingStatuses,
      default: 'confirmed',
      index: true,
    },
  },
  {
    timestamps: true,
    versionKey: false,
  },
);

bookingSchema.index({ userId: 1, eventId: 1, status: 1 });

bookingSchema.set('toJSON', {
  transform(_document, returnedObject: Record<string, unknown>) {
    const id = returnedObject._id;

    if (id instanceof Types.ObjectId) {
      returnedObject.id = id.toString();
    }

    delete returnedObject._id;

    return returnedObject;
  },
});

export type Booking = InferSchemaType<typeof bookingSchema>;
export type BookingDocument = HydratedDocument<Booking> & {
  _id: Types.ObjectId;
};

export const BookingModel = model<Booking>('Booking', bookingSchema);
