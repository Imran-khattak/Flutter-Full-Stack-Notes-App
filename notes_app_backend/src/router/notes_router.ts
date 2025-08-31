import express from "express";
import { notesController } from "../controller/notes_controller.js";
import { userController } from "../controller/user_controller.js";

const notesRouter: express.Router = express.Router();

notesRouter.post("/addNotes", notesController.addNotes);
notesRouter.get("/getNotes", notesController.getNotes);
notesRouter.put("/updateNotes", notesController.updateNotes);
notesRouter.delete("/deleteNotes", notesController.deleteNotes);

export default notesRouter;
