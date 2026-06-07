import jwt, { type JwtPayload, type SignOptions } from 'jsonwebtoken';

import { env } from '../config/env';
import { AppError } from '../middlewares/error.middleware';
import type { UserRole } from '../modules/users/user.model';

interface SignAuthTokenInput {
  id: string;
  email: string;
  role: UserRole;
}

export interface AuthTokenPayload {
  userId: string;
  email: string;
  role: UserRole;
}

export const signAuthToken = (user: SignAuthTokenInput): string => {
  const options: SignOptions = {
    subject: user.id,
    expiresIn: env.JWT_EXPIRES_IN as SignOptions['expiresIn'],
  };

  return jwt.sign(
    {
      email: user.email,
      role: user.role,
    },
    env.JWT_SECRET,
    options,
  );
};

export const verifyAuthToken = (token: string): AuthTokenPayload => {
  try {
    const decoded = jwt.verify(token, env.JWT_SECRET);

    if (typeof decoded === 'string') {
      throw new AppError('Invalid authentication token', 401);
    }

    const payload = decoded as JwtPayload & {
      email?: unknown;
      role?: unknown;
      sub?: unknown;
    };

    if (
      typeof payload.sub !== 'string' ||
      typeof payload.email !== 'string' ||
      !['user', 'organizer', 'admin'].includes(String(payload.role))
    ) {
      throw new AppError('Invalid authentication token', 401);
    }

    return {
      userId: payload.sub,
      email: payload.email,
      role: payload.role as UserRole,
    };
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    }

    throw new AppError('Invalid or expired authentication token', 401);
  }
};
