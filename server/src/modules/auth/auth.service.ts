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

  const email = decoded.email?.trim().toLowerCase();

  if (!email) {
    throw new AppError('Google account does not expose an email', 400);
  }

  const fullName = decoded.name?.trim() || email.split('@')[0];
  const avatarUrl = decoded.picture ?? null;

  let user = (await UserModel.findOne({ email })) as UserDocument | null;

  if (!user) {
    user = (await UserModel.create({
      fullName,
      email,
      role: 'user',
      authProvider: 'google',
      avatarUrl,
      interests: [],
    })) as UserDocument;
  }

  return buildAuthResponse(user);
};

export const getCurrentUser = async (userId: string): Promise<PublicUser> => {
  const user = (await UserModel.findById(userId)) as UserDocument | null;

  if (!user) {
    throw new AppError('Authenticated user no longer exists', 401);
  }

  return toPublicUser(user);
};
