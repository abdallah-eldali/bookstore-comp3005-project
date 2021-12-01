/**
 * This is the main server 
 * 
 */

import express from 'express';
import session from 'express-session';
import { checkIfCustomerExists } from './database';
import path from 'path';
import bodyParser from 'body-parser';

//Some weird thing with express-session and TS
declare module 'express-session' {
    export interface SessionData {
      loggedin: boolean;
      user_email: string
    }
  }
  

const app = express();

const publicDir = path.join(__dirname, '/public');

//These two lines are used to pass information from server to client
app.use(bodyParser.urlencoded({extended : true}));
app.use(bodyParser.json());

//Setting up the session
app.use(session({
    secret: 'secret',
    resave: true,
    saveUninitialized: true
}));

//Send the login page
app.get("/", function(req, res){
    res.sendFile(path.join(publicDir, "login.html"));
});

//This is where we recieve the login information inside req
app.post("/login", async function(req, res){
    try{
        //console.log(req.body.user_email);
        if (await checkIfCustomerExists(req.body.user_email, req.body.password)){
            req.session.loggedin = true;
            req.session.user_email = req.body.user_email;
            res.redirect("/bookstore")
        }else{
            res.send("Invalid account")
        }
    }catch (err){
        console.log(err);
    }
});

//Server execution
app.listen(8000, function(){
    console.log("Server is running at: http://localhost:8000");
});