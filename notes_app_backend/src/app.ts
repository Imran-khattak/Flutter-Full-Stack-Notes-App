import express from "express";
import cors from "cors";
import appLogger from "./middleware/app_logger.js";
import { connectToDatabase } from "./config/mongodb_client.js";
import userRouting from "./router/user_router.js";
import notesRouter from "./router/notes_router.js";

const app: express.Application = express();

app.use(appLogger);
app.use(express.json());
app.use(cors());
app.use(express.urlencoded({ extended: false }));

// Add debug middleware
app.use("/v1/users", (req, res, next) => {
  console.log(`API Request: ${req.method} /v1/users${req.path}`);
  console.log("Request body:", req.body);
  next();
});

app.use("/v1/users", userRouting);
app.use("/v1/notes", notesRouter);

const portNumber: number = 5001;

app.listen(portNumber, async () => {
  try {
    await connectToDatabase();
    console.log(`Notes App backend Server running on port ${portNumber}`);
    console.log(`Available routes:`);
    console.log(`- POST http://localhost:${portNumber}/v1/users/signup`);
    console.log(`- POST http://localhost:${portNumber}/v1/users/login`);
    console.log(`- GET http://localhost:${portNumber}/test`);
  } catch (error) {
    console.error("Failed to start server:", error);
  }
});
