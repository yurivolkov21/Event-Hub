import {
  HydratedDocument,
  Schema,
  Types,
  model,
  type InferSchemaType,
} from 'mongoose';

const reviewSchema = new Schema(
  {
    eventId: {
      type: Schema.Types.ObjectId,
      ref: 'Event',
      required: true,
      index: true,
    },
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
    comment: {
      type: String,
      trim: true,
      maxlength: 1000,
      default: '',
    },
  },
  {
    timestamps: true,
    versionKey: false,
  },
);

// One review per user per event (creating again updates the existing review).
reviewSchema.index({ eventId: 1, userId: 1 }, { unique: true });

export type Review = InferSchemaType<typeof reviewSchema>;
export type ReviewDocument = HydratedDocument<Review> & {
  _id: Types.ObjectId;
};

export const ReviewModel = model<Review>('Review', reviewSchema);
