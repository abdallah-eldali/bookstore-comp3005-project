/**
 * This is our own library that deals with the querying an all the DBs stuff
 */

import { Pool } from 'pg';

const credentials = {
    user: 'postgres',
    host: 'localhost',
    database: 'project',
    password: '***REMOVED***',
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