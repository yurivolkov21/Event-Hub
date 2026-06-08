import { Types } from 'mongoose';

import {
  getFirebaseMessaging,
  isFirebaseAdminConfigured,
} from '../../config/firebase';
import { env } from '../../config/env';
import {
  FcmTokenModel,
  type FcmTokenPlatform,
} from './fcm-token.model';

interface RegisterFcmTokenInput {
  token: string;
  platform: FcmTokenPlatform;
  appVersion?: string | null;
}

interface PushPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
}

const disabledTokenErrorCodes = new Set([
  'messaging/invalid-registration-token',
  'messaging/registration-token-not-registered',
]);

const chunk = <T>(items: T[], size: number): T[][] => {
  const chunks: T[][] = [];

  for (let index = 0; index < items.length; index += size) {
    chunks.push(items.slice(index, index + size));
  }

  return chunks;
};

export const registerFcmToken = async (
  userId: string,
  input: RegisterFcmTokenInput,
): Promise<void> => {
  await FcmTokenModel.findOneAndUpdate(
    {
      token: input.token,
    },
    {
      $set: {
        userId: new Types.ObjectId(userId),
        platform: input.platform,
        appVersion: input.appVersion ?? null,
        lastSeenAt: new Date(),
        disabledAt: null,
      },
    },
    {
      upsert: true,
      setDefaultsOnInsert: true,
    },
  );
};

export const sendPushToUser = async (
  userId: string,
  payload: PushPayload,
): Promise<void> => {
  const tokenDocuments = await FcmTokenModel.find({
    userId: new Types.ObjectId(userId),
    disabledAt: null,
  }).select('token');

  const tokens = tokenDocuments.map((tokenDocument) => tokenDocument.token);

  if (tokens.length === 0 || !isFirebaseAdminConfigured()) {
    return;
  }

  const messaging = getFirebaseMessaging();
  const tokensToDisable: string[] = [];

  for (const tokenBatch of chunk(tokens, 500)) {
    const response = await messaging.sendEachForMulticast(
      {
        tokens: tokenBatch,
        notification: {
          title: payload.title,
          body: payload.body,
        },
        data: payload.data ?? {},
        android: {
          priority: 'high',
          notification: {
            channelId: 'eventhub_default',
          },
        },
      },
      env.FCM_DRY_RUN,
    );

    response.responses.forEach((sendResponse, index) => {
      const errorCode = sendResponse.error?.code;

      if (errorCode && disabledTokenErrorCodes.has(errorCode)) {
        tokensToDisable.push(tokenBatch[index]);
      }
    });
  }

  if (tokensToDisable.length > 0) {
    await FcmTokenModel.updateMany(
      {
        token: {
          $in: tokensToDisable,
        },
      },
      {
        $set: {
          disabledAt: new Date(),
        },
      },
    );
  }
};
