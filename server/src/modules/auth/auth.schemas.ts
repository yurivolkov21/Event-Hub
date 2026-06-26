import { z } from 'zod';

export const registerSchema = z.object({
  fullName: z
    .string()
    .trim()
    .min(2, 'Full name must contain at least 2 characters')
    .max(80, 'Full name must contain at most 80 characters'),
  email: z.email('Email is invalid').transform((email) => email.toLowerCase()),
  password: z
    .string()
    .min(8, 'Password must contain at least 8 characters')
    .max(100, 'Password must contain at most 100 characters'),
  role: z.enum(['user', 'organizer']).default('user'),
});

export const loginSchema = z.object({
  email: z.email('Email is invalid').transform((email) => email.toLowerCase()),
  password: z.string().min(1, 'Password is required'),
});

export const googleAuthSchema = z.object({
  idToken: z.string().min(10, 'Google ID token is required'),
});

export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
export type GoogleAuthInput = z.infer<typeof googleAuthSchema>;
