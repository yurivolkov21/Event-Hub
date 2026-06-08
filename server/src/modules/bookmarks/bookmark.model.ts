import {
  HydratedDocument,
  Schema,
  Types,
  model,
  type InferSchemaType,
} from 'mongoose';

const bookmarkSchema = new Schema(
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
  },
  {
    timestamps: { createdAt: true, updatedAt: false },
    versionKey: false,
  },
);

bookmarkSchema.index({ userId: 1, eventId: 1 }, { unique: true });

bookmarkSchema.set('toJSON', {
  transform(_document, returnedObject: Record<string, unknown>) {
    const id = returnedObject._id;

    if (id instanceof Types.ObjectId) {
      returnedObject.id = id.toString();
    }

    delete returnedObject._id;

    return returnedObject;
  },
});

export type Bookmark = InferSchemaType<typeof bookmarkSchema>;
export type BookmarkDocument = HydratedDocument<Bookmark> & {
  _id: Types.ObjectId;
};

export const BookmarkModel = model<Bookmark>('Bookmark', bookmarkSchema);
