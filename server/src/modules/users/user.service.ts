import { Types } from 'mongoose';

import { AppError } from '../../middlewares/error.middleware';
import { toPublicUser, type PublicUser } from './user.dto';
import { UserModel, type UserDocument } from './user.model';
import type { ListUsersQuery, UpdateProfileInput } from './user.schemas';

export const listUsers = async (
  currentUserId: string,
  query: ListUsersQuery,
): Promise<PublicUser[]> => {
  const filter: Record<string, unknown> = {
    _id: {
      $ne: new Types.ObjectId(currentUserId),
    },
  };

  if (query.role) {
    filter.role = query.role;
  }

  if (query.search) {
    filter.$or = [
      { fullName: { $regex: query.search, $options: 'i' } },
      { email: { $regex: query.search, $options: 'i' } },
    ];
  }

  const users = await UserModel.find(filter)
    .sort({ fullName: 1 })
    .limit(query.limit);

  return users.map((user) => toPublicUser(user as UserDocument));
};

export const updateProfile = async (
  userId: string,
  input: UpdateProfileInput,
): Promise<PublicUser> => {
  const user = (await UserModel.findById(userId)) as UserDocument | null;

  if (!user) {
    throw new AppError('Authenticated user no longer exists', 401);
  }

  if (input.fullName !== undefined) {
    user.fullName = input.fullName;
  }
  if (input.phone !== undefined) {
    user.phone = input.phone;
  }
  if (input.bio !== undefined) {
    user.bio = input.bio;
  }
  if (input.avatarUrl !== undefined) {
    user.avatarUrl = input.avatarUrl;
  }
  if (input.interests !== undefined) {
    user.interests = input.interests;
  }

  await user.save();

  return toPublicUser(user);
};
