import type { UserDocument } from './user.model';

export interface PublicUser {
  id: string;
  fullName: string;
  email: string;
  role: string;
  avatarUrl: string | null | undefined;
  phone: string | null | undefined;
  bio: string | null | undefined;
  interests: string[];
}

export const toPublicUser = (user: UserDocument): PublicUser => ({
  id: user._id.toString(),
  fullName: user.fullName,
  email: user.email,
  role: user.role,
  avatarUrl: user.avatarUrl,
  phone: user.phone,
  bio: user.bio,
  interests: user.interests,
});
