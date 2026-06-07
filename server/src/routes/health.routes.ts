import { Router } from 'express';
import type { Router as ExpressRouter } from 'express';

import { getDatabaseStatus } from '../config/database';

export const healthRouter: ExpressRouter = Router();

healthRouter.get('/', (_req, res) => {
  res.json({
    status: 'ok',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    database: getDatabaseStatus(),
  });
});
