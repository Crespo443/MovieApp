// Semua import tetap
import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import connectDB from "./lib/db.js";
import moviesRoutes from "./routes/movie.route.js";
import authRoutes from "./routes/auth.route.js";
import userRoutes from "./routes/user.route.js";
import genreRoutes from "./routes/genre.route.js";
import paymentRoutes from "./routes/payment.route.js";
import adminRoutes from "./routes/admin.route.js";
import passport from "./config/passport-setup.js";
import mongoose from "mongoose";
import commentRoutes from "./routes/comment.route.js";

dotenv.config();

// Validasi env
const requiredEnvVars = ["MONGO_URI", "JWT_SECRET", "GOOGLE_CLIENT_ID"];
const missingEnvVars = requiredEnvVars.filter((envVar) => !process.env[envVar]);
if (missingEnvVars.length > 0) {
  console.error("Missing env vars:", missingEnvVars.join(", "));
  process.exit(1);
}

const app = express();

// DB connect
await connectDB();

// Middleware
app.use(
  cors({
    origin: process.env.FRONTEND_URL || "http://localhost:50132",
    credentials: true,
  })
);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(passport.initialize());

// Health check
app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    timestamp: new Date().toISOString(),
    mongodb:
      mongoose.connection.readyState === 1 ? "connected" : "disconnected",
  });
});

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/movies", moviesRoutes);
app.use("/api/users", userRoutes);
app.use("/api/genres", genreRoutes);
app.use("/api/payments", paymentRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/comments", commentRoutes);

// Error handler
app.use((err, req, res, next) => {
  console.error("Error:", err);
  res.status(500).json({
    success: false,
    message: "Internal Server Error",
    error: process.env.NODE_ENV === "development" ? err.message : undefined,
  });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});

//fot testing
export default app;
