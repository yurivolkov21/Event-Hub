import { Types } from 'mongoose';

import { toPublicUser, type PublicUser } from './user.dto';
import { UserModel, type UserDocument } from './user.model';
import type { ListUsersQuery } from './user.schemas';

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
