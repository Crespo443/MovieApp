import express from "express";
import {
  protectRoute,
  adminProtectRoute,
} from "../middleware/auth.middleware.js";
import {
  addMovieComment,
  getMovieComments,
  getUnrepliedComments,
  deleteCommentByAdmin,
} from "../controllers/comment.controller.js";

const router = express.Router();

// Add or reply to a comment
router.post("/movies/:tmdbId/comments", protectRoute, addMovieComment);
// Get comments for a movie
router.get("/movies/:tmdbId/comments", getMovieComments);
// Admin: get all unreplied comments
router.get(
  "/admin/unreplied",
  protectRoute,
  adminProtectRoute,
  getUnrepliedComments
);
// Admin: delete a comment
router.delete(
  "/admin/:commentId",
  protectRoute,
  adminProtectRoute,
  deleteCommentByAdmin
);

export default router;
