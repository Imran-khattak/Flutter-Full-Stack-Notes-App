import express from "express";
import { userController } from "../controller/user_controller.js";

const userRouting: express.Router = express.Router();

userRouting.post("/signup", userController.signUp);

userRouting.post("/login", userController.signIn);
userRouting.get("/getProfile", userController.getProfile);
userRouting.put("/updateProfile", userController.updateProfile);

export default userRouting;
