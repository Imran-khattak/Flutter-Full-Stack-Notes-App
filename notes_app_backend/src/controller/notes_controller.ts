import express from "express";
import { getDatabase } from "../config/mongodb_client.js";
import type { notesModel } from "../models/notes_model.js";
import { ObjectId } from "mongodb";
export class notesController {
  static async addNotes(request: express.Request, response: express.Response) {
    let db = getDatabase();

    let notesCollection = db.collection("notes");
    const notes: notesModel = request.body;
    notes.createAt = Date.now();
    // Set default color if not provided
    if (!notes.color) {
      notes.color = "#E3F2FD"; // Default light blue color
    }
    const data = await notesCollection.insertOne(notes);

    response.status(200).json({
      status: "success",
      response: data,
    });
  }

  static async getNotes(request: express.Request, response: express.Response) {
    let db = getDatabase();

    let notesCollection = db.collection("notes");
    const uId = request.query.uid;
    const notes = await notesCollection.find({ userId: uId }).toArray();

    response.status(200).json({
      status: "success",
      response: notes,
    });
  }

  static async updateNotes(
    request: express.Request,
    response: express.Response
  ) {
    let db = getDatabase();

    let notesCollection = db.collection("notes");
    const notes: notesModel = request.body;
    const noteObject = {
      title: notes.title,
      description: notes.description,
      color: notes.color,
      createAt: notes.createAt,
    };

    const data = await notesCollection.updateOne(
      { _id: new ObjectId(notes.id) },
      { $set: noteObject }
    );

    response.status(200).json({
      status: "success",
      response: data,
    });
  }

  static async deleteNotes(
    request: express.Request,
    response: express.Response
  ) {
    let db = getDatabase();

    let notesCollection = db.collection("notes");
    const notes: notesModel = request.body;

    const data = await notesCollection.deleteOne({
      _id: new ObjectId(notes.id),
    });

    response.status(200).json({
      status: "success",
      response: data,
    });
  }
}
