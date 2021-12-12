/**
 * This is the main server 
 * 
 */

import express from 'express';
import session from 'express-session';
import { checkIfCustomerExists, 
         registerUser, 
         getBook, 
         getAllBooks, 
         insertIntoBasket, 
         getBasket, 
         checkoutOrder, 
         getOrders, 
         checkIfOwnerExists,
         getSalesPerDay,
         removeBook,
         getAllPublishersEmail,
         createPublisher,
         addBook,
         getSalesBetween } from './database';
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
const viewDir = path.join(__dirname, '/view');

app.set('views', viewDir);
app.set('view engine', 'pug')

//These two lines are used to pass information from server to client
app.use(bodyParser.urlencoded({extended : true}));
app.use(bodyParser.json());

//Setting up the session
app.use(session({
    secret: 'secret',
    resave: true,
    saveUninitialized: true
}));

//Redirect to /login when trying to access /
app.get("/", function(req, res){
    res.redirect("/login");
});

//Send the login page
app.get("/login", function(req, res){
    res.sendFile(path.join(publicDir, "login.html"));
});

//TODO: Maybe add an else if statement for if it's an owner and send the owner to a different page

//This is where we recieve the login information inside req
app.post("/login", async function(req, res){
    try{
        //console.log(req.body.user_email);
        if(await checkIfCustomerExists(req.body.user_email, req.body.password)){
            req.session.loggedin = true;
            req.session.user_email = req.body.user_email;
            res.redirect("/bookstore")
        }
        else if (await checkIfOwnerExists(req.body.user_email, req.body.password)){
            req.session.loggedin = true;
            req.session.user_email = req.body.user_email;
            res.redirect("/office")
        }
        else{
            res.send("Invalid account")
        }
    }catch(err){
        console.log(err);
    }
});

//Send them the HTML when user wants to register as an owner or customer
app.get("/register", function(req, res){
    res.sendFile(path.join(publicDir, "register.html"))
});

app.post("/register", async function(req, res){
    try{
        let body = req.body;
        //If the registration failed
        if(!(await registerUser(body.user_email, body.password, body.name, body.full_address, body.phone_number, body.card_number, body.user_type))){
            res.send("Email is already in used...");
        }
        //Else, redirect them to either bookstore if it's a customer or the office if owner
        else{
            req.session.loggedin = true;
            req.session.user_email = body.user_email;
            if(body.user_type === "customer"){
                res.redirect("/bookstore");
            }else{
                res.redirect('/office');
            }
        }
    }catch(err){
        console.error(err);
    }
});

app.get("/bookstore", async function(req, res){
    try{
        if(!req.session.loggedin){
            res.redirect('/login');
        }else{
            console.log("Rendering all books");
            res.render('bookstore', {books: (await getAllBooks())});
        }
    }catch(err){
        console.error(err);
    }
});

app.get("/bookstore/search", async function(req, res){
    try{
        res.render('bookstore', {books: (await getBook(req.query))});
    }catch(err){
        console.error(err);
    }
});

app.post("/basket", async function(req, res){
    try{
        if(!req.session.loggedin || !req.session.user_email){
            res.redirect('/login');
        }else{
            await insertIntoBasket(req.body.isbn, req.session.user_email, req.body.amount); 
        }
    }catch(err){
        console.error(err);
    }
});

app.get("/basket", async function(req, res){
    try{
        if(!req.session.loggedin || !req.session.user_email){
            res.redirect('/login');
        }else{
            res.render("basket", {basket: (await getBasket(req.session.user_email))});
        }
    }catch(err){
        console.error(err);
    }
});

//TODO: Finish this
app.post('/checkout', async function(req, res){
    
    try{
        if(!req.session.loggedin || !req.session.user_email){
            res.redirect('/login');
        }else{
            if(await checkoutOrder(req.session.user_email, req.body.address, req.body.card_number)){
                res.send("You order will be delivered in 10 days...");
            }else{
                res.send("Your basket is empty");
            }
        }
    }catch(err){
        console.error(err);
    }
});

app.get('/orders', async function(req, res){
    try{
        if(!req.session.loggedin || !req.session.user_email){
            res.redirect('/login');
        }else{
            res.render('order', {orders: (await getOrders(req.session.user_email))});
        }
    }catch(err){
        console.error(err);
    }
});

app.get('/office', async function(req, res){
    try{
        if(!req.session.loggedin || !req.session.user_email){
            res.redirect('/login');
        }else{
            res.render('office', {sales: (await getSalesPerDay())});
        }
    }catch(err){
        console.error(err);
    }
});

app.get('/office/remove-book', async function(req, res){
    res.render('remove-book', {books: (await getAllBooks())});
});

app.post('/office/remove-book', async function(req, res){
    //Remove book
    await removeBook(req.body.isbn);
    //Re-render
    res.redirect('/office/remove-book');
});

app.get('/office/add-book', async function(req, res){
    try{
        res.render('add-book', {publisher_emails: (await getAllPublishersEmail())});
    }catch(err){
        console.error(err);
    }
});

//TODO:
// 1. Parse the authors and genres (comma separated) to an array
// 2. Check if the authors exist, in author table, if so, just link them in book_author
//    else, create the new author(s) and link them
// 3. Add the genres to book_genre
// 4. Check if a publisher_name was selected, if not, use the form information instead
app.post('/office/add-book', async function(req, res){
    try{
        let book = req.body;
        await addBook(book.title, 
                      book.number_pages, 
                      book.quantity,
                      book.price,
                      book.cost,
                      book.percent_sale,
                      book.publisher_email,
                      book.genre.split(','),
                      book.author.split(','));
        console.log('Book has been created');
        res.redirect('/office/add-book');
    }catch(err){
        console.error(err);
    }
});

app.post('/office/add-publisher', async function(req, res){
    try{
        await createPublisher(req.body.publisher_email,
                              req.body.name,
                              req.body.card_number,
                              req.body.full_address,
                              req.body.phone_number)
        res.redirect("/office/add-book");
    }catch(err){
        console.error(err);
        res.send("Email is already in used...");
    }
});

app.get('/office/salesBetweenDays', async function(req, res){
    let day1 = req.query.day1!;
    let day2 = req.query.day2!; 
    if (typeof day1 === 'string' && typeof day2 === 'string'){
        res.send(`$${await getSalesBetween(day1, day2)}`);
    }else{
        res.send("Error, wrongly inputted dates, try again");
    }
});

//Server execution
app.listen(8000, function(){
    console.log("Server is running at: http://localhost:8000");
});
