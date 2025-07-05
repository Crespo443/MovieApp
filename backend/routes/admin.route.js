import express from 'express';
import { getDashboardStats } from '../controllers/admin.controller.js';
import { protectRoute, adminProtectRoute } from '../middleware/auth.middleware.js';

const router = express.Router();

router.get('/dashboard-stats', protectRoute, adminProtectRoute, getDashboardStats);

export default router;
