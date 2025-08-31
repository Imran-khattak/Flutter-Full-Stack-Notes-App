import express, { urlencoded } from "express";
import { getDatabase } from "../config/mongodb_client.js";
import type { userModel } from "../models/user_model.js";
import bcrypt from "bcrypt";
import { ObjectId } from "mongodb";
import { stat } from "fs";

export class userController {
  static async signUp(request: express.Request, response: express.Response) {
    let db = getDatabase();
    let userCollection = db.collection("users");
    let user: userModel = request.body;

    const checkUserinDb = {
      email: user.email,
    };

    let userInDb = await userCollection.find(checkUserinDb).toArray();

    if (userInDb.length != 0) {
      response.status(403).json({
        status: "Failure",
        response: "User Already Exist",
      });
    } else {
      const salt = await bcrypt.genSalt(10);
      user.password = await bcrypt.hash(user.password, salt);
      const responseData = await userCollection.insertOne(user);

      const objectId = responseData.insertedId;

      const userInfo = await userCollection
        .find({ _id: new ObjectId(objectId) })
        .toArray();

      const userCrendials = userInfo[0]!;

      userCrendials.password = "";

      response.status(200).json({
        status: "success",
        response: userCrendials,
      });
    }
  }

  static async signIn(request: express.Request, response: express.Response) {
    let db = getDatabase();
    let userCollection = db.collection("users");
    let user: userModel = request.body;

    const checkUserinDb = {
      email: user.email,
    };

    let userInDb = await userCollection.find(checkUserinDb).toArray();

    if (userInDb.length != 0) {
      const userInfo = userInDb[0]!;

      const password = await bcrypt.compare(user.password, userInfo.password);

      if (user.email == userInfo.email && password) {
        userInfo.password = "";
        response.status(200).json({
          status: "success",
          response: userInfo,
        });
      } else {
        response.status(403).json({
          status: "Failure",
          response: "Invalid email and password please check",
        });
      }
    } else {
      response.status(403).json({
        status: "Failure",
        response: "Invalid email and password please check",
      });
    }
  }

  static async getProfile(
    request: express.Request,
    response: express.Response
  ) {
    const db = getDatabase();
    const userCollection = db.collection("users");

    const userId = request.query.uid;

    const user = await userCollection
      .find({ _id: new ObjectId(userId!.toString()) })
      .toArray();

    response.status(200).json({
      status: "success",
      response: user[0],
    });
  }
  static async updateProfile(
    request: express.Request,
    response: express.Response
  ) {
    const db = getDatabase();
    const userCollection = db.collection("users");
    const user: userModel = request.body;

    const userObject = {
      username: user.username,
    };
    console.log(`id : ${user.uid}`);
    const updateUserInfo = await userCollection.updateOne(
      { _id: new ObjectId(user.uid) },
      { $set: userObject }
    );

    if (updateUserInfo.matchedCount === 0) {
      return response.status(404).json({
        status: "error",
        message: "User not found",
      });
    }

    // Fetch and return the updated user
    const updatedUser = await userCollection.findOne({
      _id: new ObjectId(user.uid),
    });

    response.status(200).json({
      status: "success",
      response: updatedUser,
    });
  }
}
