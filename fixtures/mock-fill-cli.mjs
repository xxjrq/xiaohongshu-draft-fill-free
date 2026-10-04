#!/usr/bin/env node
import { appendFileSync } from 'node:fs';
const payload = { mock_only: true, argv: process.argv.slice(2) };
if (process.env.XHS_MOCK_TRACE) appendFileSync(process.env.XHS_MOCK_TRACE, JSON.stringify(payload) + '\n');
process.stdout.write(JSON.stringify(payload) + '\n');
