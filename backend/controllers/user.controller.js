import User from "../models/user.model.js";
import Movie from "../models/movie.model.js";

const mapMovieData = (movie) => {
  if (!movie) return null;
  return {
    id: movie.tmdbId,
    title: movie.title,
    description: movie.description,
    thumbnailUrl: movie.posterPath,
    backdropPath: movie.backdropPath,
    videoUrl: movie.videoUrl,
    categories: movie.genre,
    type: movie.type,
    rating: movie.rating,
    releaseDate: movie.releaseDate,
    tags: movie.tags || [],
  };
};

export const getMe = async (req, res) => {
  try {
    const userId = req.user.id;
    const user = await User.findById(userId);

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    res.status(200).json({
      success: true,
      data: {
        id: user._id,
        name: user.username,
        email: user.email,
        role: user.role,
        favorites: user.favorites || [],
        stripeCustomerId: user.stripeCustomerId,
        subscription: user.subscription,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to get user details",
      error: error.message,
    });
  }
};

export const getAllUsers = async (req, res) => {
  try {
    const users = await User.find({ role: "customer" });
    res.status(200).json({
      success: true,
      data: users.map((user) => ({
        id: user._id,
        name: user.username,
        email: user.email,
        role: user.role,
        favorites: user.favorites || [],
        stripeCustomerId: user.stripeCustomerId,
        subscription: user.subscription,
        createdAt: user.createdAt, // <-- include registration date
      })),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to get all users",
      error: error.message,
    });
  }
};

export const updateUsername = async (req, res) => {
  try {
    const userId = req.user.id;
    const { newUsername } = req.body;

    if (!newUsername || newUsername.trim() === "") {
      return res
        .status(400)
        .json({ success: false, message: "New username cannot be empty" });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    if (user.username === newUsername) {
      return res.status(400).json({
        success: false,
        message: "New username cannot be the same as the current one",
      });
    }

    const existingUser = await User.findOne({ username: newUsername });
    if (existingUser && existingUser._id.toString() !== userId) {
      return res
        .status(400)
        .json({ success: false, message: "Username already taken" });
    }

    user.username = newUsername;
    await user.save();

    res.status(200).json({
      success: true,
      message: "Username updated successfully",
      data: {
        id: user._id,
        name: user.username,
        email: user.email,
        role: user.role,
        favorites: user.favorites || [],
        stripeCustomerId: user.stripeCustomerId,
        subscription: user.subscription,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to update username",
      error: error.message,
    });
  }
};

export const getUserFavorites = async (req, res) => {
  try {
    const userId = req.user.id;
    const user = await User.findById(userId);

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    const favoriteTmdbIds = user.favorites || [];
    if (favoriteTmdbIds.length === 0) {
      return res.status(200).json({ success: true, data: [] });
    }

    const favoriteMovies = await Movie.find({
      tmdbId: { $in: favoriteTmdbIds },
    });

    const mappedFavorites = favoriteMovies
      .map(mapMovieData)
      .filter((movie) => movie !== null);

    res.status(200).json({
      success: true,
      data: mappedFavorites,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to get user favorites",
      error: error.message,
    });
  }
};

export const toggleFavorite = async (req, res) => {
  try {
    const userId = req.user.id;
    const { movieId: tmdbId } = req.params;

    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    const movie = await Movie.findOne({ tmdbId: tmdbId });
    if (!movie) {
      return res
        .status(404)
        .json({ success: false, message: "Movie not found" });
    }

    const currentFavorites = user.favorites || [];
    const isFavorite = currentFavorites.includes(tmdbId);

    if (isFavorite) {
      user.favorites = currentFavorites.filter((favId) => favId !== tmdbId);
    } else {
      user.favorites.push(tmdbId);
    }

    await user.save();

    res.status(200).json({
      success: true,
      message: isFavorite ? "Removed from favorites" : "Added to favorites",
      data: {
        favorites: user.favorites,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to update favorites",
      error: error.message,
    });
  }
};

export const getWatchHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const user = await User.findById(userId);

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    const watchHistoryIds = user.watchHistory
      .sort((a, b) => b.watchedAt - a.watchedAt)
      .map((item) => item.videoId);

    if (watchHistoryIds.length === 0) {
      return res.status(200).json({ success: true, data: [] });
    }

    const historyMovies = await Movie.find({
      tmdbId: { $in: watchHistoryIds },
    });

    const sortedMovies = watchHistoryIds
      .map((id) => historyMovies.find((movie) => movie.tmdbId === id))
      .filter((movie) => movie !== null);

    const mappedHistory = sortedMovies.map(mapMovieData);

    res.status(200).json({
      success: true,
      data: mappedHistory,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to get watch history",
      error: error.message,
    });
  }
};

export const addToWatchHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const { movieId: tmdbId } = req.params;

    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    const movie = await Movie.findOne({ tmdbId });
    if (!movie) {
      return res
        .status(404)
        .json({ success: false, message: "Movie not found" });
    }

    user.watchHistory = user.watchHistory.filter(
      (item) => item.videoId !== tmdbId
    );

    user.watchHistory.unshift({
      videoId: tmdbId,
      watchedAt: new Date(),
    });

    await user.save();

    res.status(200).json({
      success: true,
      message: "Added to watch history",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to update watch history",
      error: error.message,
    });
  }
};

export const clearWatchHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const user = await User.findById(userId);

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    user.watchHistory = [];
    await user.save();

    res.status(200).json({
      success: true,
      message: "Watch history cleared",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to clear watch history",
      error: error.message,
    });
  }
};
