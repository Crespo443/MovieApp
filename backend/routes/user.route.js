import express from "express";
import {
  protectRoute,
  adminProtectRoute,
} from "../middleware/auth.middleware.js";
import {
  getAllUsers, // Added import for getAllUsers
  getMe,
  getUserFavorites,
  toggleFavorite,
  getWatchHistory,
  addToWatchHistory,
  clearWatchHistory,
  updateUsername,
  updateUserByAdmin, // NEW
  deleteUserByAdmin, // NEW
} from "../controllers/user.controller.js";

const router = express.Router();

// Admin route to get all users (with search/pagination)
router.get("/admin/users", protectRoute, adminProtectRoute, getAllUsers);
// Admin edit user
router.put(
  "/admin/users/:userId",
  protectRoute,
  adminProtectRoute,
  updateUserByAdmin
);
// Admin delete user
router.delete(
  "/admin/users/:userId",
  protectRoute,
  adminProtectRoute,
  deleteUserByAdmin
);

router.get("/me", protectRoute, getMe);
router.put("/me/username", protectRoute, updateUsername);
router.get("/favorites", protectRoute, getUserFavorites);
router.post("/favorites/:movieId", protectRoute, toggleFavorite); // movieId here is tmdbId
router.get("/watch-history", protectRoute, getWatchHistory);
router.post("/watch-history/:movieId", protectRoute, addToWatchHistory);
router.delete("/watch-history", protectRoute, clearWatchHistory);

export default router;
