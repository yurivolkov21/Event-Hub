import {
  HydratedDocument,
  Schema,
  Types,
  model,
  type InferSchemaType,
} from 'mongoose';

export const fcmTokenPlatforms = ['android', 'ios', 'web'] as const;
export type FcmTokenPlatform = (typeof fcmTokenPlatforms)[number];

const fcmTokenSchema = new Schema(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    token: {
      type: String,
      required: true,
      trim: true,
      unique: true,
      index: true,
    },
    platform: {
      type: String,
      enum: fcmTokenPlatforms,
      default: 'android',
    },
    appVersion: {
      type: String,
      default: null,
      trim: true,
      maxlength: 80,
    },
    lastSeenAt: {
      type: Date,
      default: () => new Date(),
      index: true,
    },
    disabledAt: {
      type: Date,
      default: null,
      index: true,
    },
  },
  {
    timestamps: true,
    versionKey: false,
  },
);

fcmTokenSchema.index({ userId: 1, disabledAt: 1 });

export type FcmToken = InferSchemaType<typeof fcmTokenSchema>;
export type FcmTokenDocument = HydratedDocument<FcmToken> & {
  _id: Types.ObjectId;
};

export const FcmTokenModel = model<FcmToken>('FcmToken', fcmTokenSchema);
