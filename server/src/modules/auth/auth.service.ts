import { AppError } from '../../middlewares/error.middleware';
import { getFirebaseAuth } from '../../config/firebase';
import { toPublicUser, type PublicUser } from '../users/user.dto';
import { UserModel, type UserDocument } from '../users/user.model';
import { signAuthToken } from '../../utils/jwt';
import { hashPassword, verifyPassword } from '../../utils/password';
import type { LoginInput, RegisterInput } from './auth.schemas';

interface AuthResponse {
  token: string;
  user: PublicUser;
}

const buildAuthResponse = (user: UserDocument): AuthResponse => ({
  token: signAuthToken({
    id: user._id.toString(),
    email: user.email,
    role: user.role,
  }),
  user: toPublicUser(user),
});

export const register = async (input: RegisterInput): Promise<AuthResponse> => {
  const email = input.email.trim().toLowerCase();
  const existingUser = await UserModel.exists({ email });

  if (existingUser) {
    throw new AppError('Email is already registered', 409);
  }

  const passwordHash = await hashPassword(input.password);

  const user = await UserModel.create({
    fullName: input.fullName.trim(),
    email,
    passwordHash,
    role: input.role,
    interests: [],
  });

  return buildAuthResponse(user as UserDocument);
};

export const login = async (input: LoginInput): Promise<AuthResponse> => {
  const email = input.email.trim().toLowerCase();
  const user = (await UserModel.findOne({ email }).select(
    '+passwordHash',
  )) as UserDocument | null;

  if (!user || !user.passwordHash) {
    throw new AppError('Invalid email or password', 401);
  }

  const passwordMatches = await verifyPassword(input.password, user.passwordHash);

  if (!passwordMatches) {
    throw new AppError('Invalid email or password', 401);
  }

  return buildAuthResponse(user);
};

export const googleAuth = async (idToken: string): Promise<AuthResponse> => {
  let decoded;

  try {
    decoded = await getFirebaseAuth().verifyIdToken(idToken);
  } catch {
    throw new AppError('Invalid or expired Google sign-in token', 401);
  }

  // Only accept tokens that actually came from Google sign-in with a verified
  // email. This blocks tokens minted via other providers and unverified emails.
  if (decoded.firebase?.sign_in_provider !== 'google.com') {
    throw new AppError('Unsupported sign-in provider', 401);
  }

  if (decoded.email_verified !== true) {
    throw new AppError('Google email is not verified', 401);
  }

  const email = decoded.email?.trim().toLowerCase();

  if (!email) {
    throw new AppError('Google account does not expose an email', 400);
  }

  const existingUser = (await UserModel.findOne({
    email,
  })) as UserDocument | null;

  if (existingUser) {
    // Account-takeover guard: a Google sign-in must not assume an account that
    // was registered with a password (local) or any other provider, because
    // local registration never proves email ownership.
    if (existingUser.authProvider !== 'google') {
      throw new AppError(
        'An account with this email already exists. Please sign in with your password.',
        409,
      );
    }

    return buildAuthResponse(existingUser);
  }

  const fullName = decoded.name?.trim() || email.split('@')[0];
  const avatarUrl = decoded.picture ?? null;

  const user = (await UserModel.create({
    fullName,
    email,
    role: 'user',
    authProvider: 'google',
    avatarUrl,
    interests: [],
  })) as UserDocument;

  return buildAuthResponse(user);
};

interface MessageResponse {
  message: string;
}

const PASSWORD_RESET_MESSAGE =
  'If an account exists for that email, password reset instructions have been sent.';

/**
 * Initiates a password reset. Always responds with the same generic message so
 * the endpoint cannot be used to enumerate which emails are registered. Email
 * delivery is intentionally not wired up (no SMTP provider is configured); the
 * lookup runs so the flow is real, but no token is leaked to the client.
 */
export const forgotPassword = async (
  email: string,
): Promise<MessageResponse> => {
  const normalizedEmail = email.trim().toLowerCase();

  // Only password (local) accounts can reset a password; Google accounts have
  // no passwordHash. We look the user up but never reveal the outcome.
  await UserModel.exists({ email: normalizedEmail, authProvider: 'local' });

  return { message: PASSWORD_RESET_MESSAGE };
};

export const getCurrentUser = async (userId: string): Promise<PublicUser> => {
  const user = (await UserModel.findById(userId)) as UserDocument | null;

  if (!user) {
    throw new AppError('Authenticated user no longer exists', 401);
  }

  return toPublicUser(user);
};
