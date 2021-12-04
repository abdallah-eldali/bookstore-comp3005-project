/**
 * This is our own library that deals with the querying an all the DBs stuff
 */

import { Pool } from 'pg';
import internal from 'stream';

const credentials = {
    user: 'postgres',
    host: 'localhost',
    database: 'project',
    password: '***REMOVED***', //Change this to your password
    port: 5432
}

const pool = new Pool(credentials);

//Returns Promise<boolean> which is true if the customer exists in the database
//and false otherwise
export async function checkIfCustomerExists(email: string, password: string): Promise<boolean>{
    const query : string = `
        select check_customer($1, $2);
    `;

    const values : string[] = [email, password];

    //Wait for the async query and return the promise
    return (await pool.query(query, values)).rows[0].check_customer;
}

//Returns true if the query succeded, false otherwise
export async function registerUser(email: string, 
                                   password: string, 
                                   name: string, 
                                   full_address: string, 
                                   phone_number: string, 
                                   card_number: string, 
                                   user_type: string): Promise<boolean>{
    const values : string[] = [email, name, password, card_number, full_address, phone_number];
    let query : string;
    if (user_type === "owner"){
        query = `
            insert into owner(owner_email, name, password, card_number, full_address, phone_number)
            values ($1, $2, $3, $4, $5, $6);
        `
    }else{
        query = `
            insert into customer(customer_email, name, password, card_number, full_address, phone_number)
            values ($1, $2, $3, $4, $5, $6);
        `
    }

    try{
        await pool.query(query, values);
        return true;
    } catch(err){
        console.log(err);
        return false;
    }
}

//Given an object with key/value it will convert it into a SQL query
function createWhereQuery(query: any): string{

    let q = `
        select isbn, title, 
    `;

    //Remove all attributes with empty values (null or empty)
    Object.keys(query).forEach((key) => (query[key] === null || query[key] === '') && delete query[key])
    
    //Check if the query is empty after removing everthing
    //if not empty...
    if(!(Object.keys(query).length === 0)){
        let whereQuery = "";
        for (let i=0; i<Object.keys(query).length - 1; i++){
            let attribute = query[Object.keys(query)[i]]
            whereQuery += `${query[attribute]}=$${i} and `;
        }
        whereQuery += `${query[Object.keys(query)[Object.keys(query).length]]}=${Object.keys(query).length}`;
    }
    
    return ""
}

export async function getAllBooks(): Promise<any[]>{
    const query = `
        select *
        from customer_book_view;
    `;
    return (await pool.query(query)).rows;
}

export async function getBook(obj: any): Promise<any[]>{
    
    //Remove all attributes with empty values (null or empty)
    Object.keys(obj).forEach((key) => (obj[key] === null || obj[key] === '') && delete obj[key])

    let whereQuery = '';
    //If obj not empty
    if(!(Object.keys(obj).length === 0)){
        let keys = Object.keys(obj);
        whereQuery += 'where ';
        for (let i = 0; i < keys.length - 1; i++){
            if (keys[i] === 'genre' || keys[i] === 'author'){
                whereQuery += `$${i+1}=any(${keys[i]}) and `;
            }
            else{
                whereQuery += `${keys[i]}=$${i+1} and `;
            }
        }

        let i = keys.length-1
        if (keys[i] === 'genre' || keys[i] === 'author'){
            whereQuery += `$${i+1}=any(${keys[i]});`;
        }
        else{
            whereQuery += `${keys[i]}=$${i+1};`;
        }
    }

    const query = `
        select *
        from customer_book_view
        ${whereQuery}
    `;

    return (await pool.query(query, Object.values(obj))).rows;

}

//TODO: Check if it already exists in basket, if so, update it to increase the amount
export async function insertIntoBasket(isbn: string, customer_email: string, amount: string): Promise<void>{
    
    //Check if the tuple exists in the table first before attempting to insert
    let query = `
        select count(*)
        from basket
        where isbn=$1 and customer_email=$2;
    `;

    if((await pool.query(query, [isbn, customer_email])).rows[0].count > 0){
        console.log("Book is already in basket, updating value");
        query = `
            update basket set quantity = quantity + $3
            where isbn=$1 and customer_email=$2
        `;

        console.log(query);
        console.log([isbn, customer_email, amount]);

        await pool.query(query, [isbn, customer_email, amount]);
    }
    else{
        console.log("Adding book to basket");
        query = `
            insert into basket(isbn, customer_email, quantity)
            values($1, $2, $3);
        `;
        await pool.query(query, [isbn, customer_email, amount]);
    }
}

export async function getBasket(customer_email: string): Promise<any[]>{
    let query = `
        select *
        from basket
        where customer_email=$1
    `;

    console.log((await pool.query(query, [customer_email])).rows);

    return (await pool.query(query, [customer_email])).rows;
}

//TODO:
//  1. if emptyBasket, do nothing
//  2. check if full_address or card_number are empty, if not, use the customer_email ones
//  3. create the order
//  4. create book order
//  5. update the book's quantity while adding to bookOrder
//  6. delete customer's basket after all of this

//returns true if the checkout has been succesful, false otherwise.
export async function checkoutOrder(customer_email: string, full_address: string|null, card_number: string|null): Promise<boolean>{
    
    //Check if basket is empty, if so, then return
    if(await emptyBasket(customer_email)){
        console.log("No basket for customer: " + customer_email + " cannot checkout...");
        return false;
    }
    
    //Check if full_address was specified
    if(full_address === null || full_address === ''){
        full_address = await getCustomerAddress(customer_email);
    }

    //Check if billing was specified
    if(card_number === null || card_number === ''){
        card_number = await getCustomerCard(customer_email);
    }

    //Creating the order
    let order_id = await createOrder(customer_email, full_address, card_number);

    //Creating the book order and update
    await createBookOrder(order_id, customer_email);

    //Delete customer's basket
    await deleteBasket(customer_email);

    return true;
}

async function deleteBasket(customer_email: string): Promise<void>{
    const query = `
        delete from basket
        where customer_email=$1;
    `;

    await pool.query(query, [customer_email]);
}

async function createOrder(customer_email: string, full_address: string, card_number: string): Promise<string>{
    //Creating the order
    const query = `
        insert into order_table(order_id, customer_email, full_address, card_number, order_date)
        values(default, $1, $2, $3, default)
        returning order_id;
    `;

    return (await pool.query(query, [customer_email, full_address, card_number])).rows[0].order_id;
}

async function createBookOrder(order_id: string, customer_email: string): Promise<void>{
    let query = `
        select isbn, quantity
        from basket
        where customer_email=$1;
    `;

    let books = (await pool.query(query, [customer_email])).rows;

    query = `
        insert into book_order(order_id, isbn, quantity)
        values($1, $2, $3);
    `;

    for (let book of books){
        await pool.query(query, [order_id, book.isbn, book.quantity]);

        //Update book's quantity
        await updateBookQuantity(book.isbn, book.quantity);
    }
}

async function updateBookQuantity(isbn: string, newQuantity: string|number): Promise<void>{
    const query = `
        update book
        set quantity=quantity-$1
        where isbn=$2;
    `;

    await pool.query(query, [newQuantity, isbn]);
}

async function emptyBasket(customer_email: string): Promise<boolean>{
    //Check if the tuple exists
    let query = `
        select count(*)
        from basket
        where customer_email=$1;
    `;
    
    let count = (await pool.query(query, [customer_email])).rows[0].count;

    //if there is more than one row, then return true
    return !(count > 0);
}

async function getCustomerAddress(customer_email: string): Promise<string>{
    const query = `
        select full_address
        from customer
        where customer_email=$1;
    `;

    return (await pool.query(query, [customer_email])).rows[0].full_address;
}

async function getCustomerCard(customer_email: string): Promise<string>{
    const query = `
        select card_number
        from customer
        where customer_email=$1;
    `;

    return (await pool.query(query, [customer_email])).rows[0].card_number;
}

//
export async function getOrders(customer_email: string): Promise<any[]>{
    const query = `
        select order_id, full_address, card_number, order_date, isbn, quantity
        from order_table natural join book_order
        where customer_email=$1;
    `;
    
    return (await pool.query(query, [customer_email])).rows;
}