import {
  HydratedDocument,
  Schema,
  Types,
  model,
  type InferSchemaType,
} from 'mongoose';

export const invitationStatuses = ['pending', 'accepted', 'rejected'] as const;
export type InvitationStatus = (typeof invitationStatuses)[number];

const invitationSchema = new Schema(
  {
    eventId: {
      type: Schema.Types.ObjectId,
      ref: 'Event',
      required: true,
      index: true,
    },
    fromUserId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    toUserId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    status: {
      type: String,
      enum: invitationStatuses,
      default: 'pending',
      index: true,
    },
  },
  {
    timestamps: true,
    versionKey: false,
  },
);

invitationSchema.index(
  { eventId: 1, fromUserId: 1, toUserId: 1 },
  { unique: true },
);

invitationSchema.set('toJSON', {
  transform(_document, returnedObject: Record<string, unknown>) {
    const id = returnedObject._id;

    if (id instanceof Types.ObjectId) {
      returnedObject.id = id.toString();
    }

    delete returnedObject._id;

    return returnedObject;
  },
});

export type Invitation = InferSchemaType<typeof invitationSchema>;
export type InvitationDocument = HydratedDocument<Invitation> & {
  _id: Types.ObjectId;
};

export const InvitationModel = model<Invitation>(
  'Invitation',
  invitationSchema,
);
