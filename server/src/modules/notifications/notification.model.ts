import {
  HydratedDocument,
  Schema,
  Types,
  model,
  type InferSchemaType,
} from 'mongoose';

export const notificationTypes = [
  'invite',
  'booking',
  'event_update',
  'event_cancelled',
  'follow',
  'review',
] as const;

export type NotificationType = (typeof notificationTypes)[number];

const notificationSchema = new Schema(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    type: {
      type: String,
      enum: notificationTypes,
      required: true,
      index: true,
    },
    title: {
      type: String,
      required: true,
      trim: true,
      maxlength: 160,
    },
    body: {
      type: String,
      required: true,
      trim: true,
      maxlength: 500,
    },
    data: {
      type: Map,
      of: String,
      default: {},
    },
    readAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: { createdAt: true, updatedAt: false },
    versionKey: false,
  },
);

notificationSchema.index({ userId: 1, createdAt: -1 });

notificationSchema.set('toJSON', {
  transform(_document, returnedObject: Record<string, unknown>) {
    const id = returnedObject._id;

    if (id instanceof Types.ObjectId) {
      returnedObject.id = id.toString();
    }

    delete returnedObject._id;

    return returnedObject;
  },
});

export type Notification = InferSchemaType<typeof notificationSchema>;
export type NotificationDocument = HydratedDocument<Notification> & {
  _id: Types.ObjectId;
};

export const NotificationModel = model<Notification>(
  'Notification',
  notificationSchema,
);
