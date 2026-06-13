'use strict';

const assert = require('node:assert/strict');
const { before, describe, it } = require('node:test');
const request = require('supertest');

process.env.NODE_ENV = 'test';
process.env.MONGODB_URI =
  process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/eventhub_test';
process.env.JWT_SECRET = process.env.JWT_SECRET || 'test-secret';
process.env.FCM_DRY_RUN = process.env.FCM_DRY_RUN || 'true';

let app;

before(() => {
  const { createApp } = require('../dist/app');
  app = createApp();
});

describe('EventHub API app', () => {
  it('returns health status without authentication', async () => {
    const response = await request(app).get('/health').expect(200);

    assert.equal(response.body.status, 'ok');
    assert.equal(typeof response.body.uptime, 'number');
    assert.equal(typeof response.body.timestamp, 'string');
    assert.equal(typeof response.body.database, 'object');
  });

  it('rejects protected routes without a bearer token', async () => {
    const response = await request(app).get('/api/bookings/me').expect(401);

    assert.equal(response.body.message, 'Authentication token is required');
  });
});
