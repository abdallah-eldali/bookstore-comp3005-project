/**
 * This is our own library that deals with the querying an all the DBs stuff
 */

import { Pool } from 'pg';

const credentials = {
    user: 'postgres',
    host: 'localhost',
    database: 'project',
    password: 'XXXXXX', //Change this to your password
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