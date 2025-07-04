import jwt from "jsonwebtoken";
import User from "../models/user.model.js";

export const protectRoute = async (req, res, next) => {
  const authHeader = req.headers["authorization"];

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({
      success: false,
      message: "Access token is required",
      error: "MISSING_TOKEN",
    });
  }
  const token = authHeader.substring(7);

  if (!token) {
    return res.status(401).json({
      success: false,
      message: "Access token is required",
      error: "MISSING_TOKEN",
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.userId).select("-password");

    if (!user) {
      return res.status(401).json({
        success: false,
        message: "User for this token not found.",
        error: "USER_TOKEN_NOT_FOUND",
      });
    }

    req.user = user; 
    next();
  } catch (error) {
    
    if (error.name === "TokenExpiredError") {
      return res.status(401).json({
        success: false,
        message: "Token has expired",
        error: "TOKEN_EXPIRED",
      });
    } else if (error.name === "JsonWebTokenError") {
      return res.status(401).json({
        success: false,
        message: "Invalid token",
        error: "INVALID_TOKEN",
      });
    } else if (error.name === "NotBeforeError") {
      return res.status(401).json({
        success: false,
        message: "Token not active yet",
        error: "TOKEN_NOT_ACTIVE",
      });
    } else {
    
      console.error("Token verification unexpected error:", error);
      return res.status(500).json({
        success: false,
        message: "Token verification failed",
        error: "TOKEN_VERIFICATION_FAILED",
      });
    }
  }
};

export const adminProtectRoute = async (req, res, next) => {
  if (req.user && req.user.role === "admin") {
    next();
  } else {
    res.status(403).json({
      success: false,
      message: "Access denied. Admin role required.",
      error: "FORBIDDEN",
    });
  }
};
