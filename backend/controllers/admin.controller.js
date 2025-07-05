import User from "../models/user.model.js";
import Movie from "../models/movie.model.js";
import Comment from "../models/comment.model.js";

export const getDashboardStats = async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const totalSubscriptionUsers = await User.countDocuments({
      "subscription.status": "incomplete",
    });
    const totalMovies = await Movie.countDocuments();
    const totalComments = await Comment.countDocuments();

    // Static data for now
    const totalWatchingHours = 1234567;
    const totalIncome = 12.345;

    res.status(200).json({
      success: true,
      data: {
        totalUsers,
        totalSubscriptionUsers,
        totalMovies,
        totalComments,
        totalWatchingHours,
        totalIncome,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to fetch dashboard stats",
      error: error.message,
    });
  }
};
