# How to setup database

Create a new PostgreSQL database and execute the `DDL.sql` script inside the `sql\` directory in the repository

Then execute `insertFile.sql` script inside the same directory

Lastly, go to `database.ts` inside the `src\` directory in the repository and change the credentials to match the newly created database.

For example: If the database created was name `project` and the password for PostgreSQL is `password` then change the variable `credentials` (in line 7) to
```js
const credentials = {
    user: 'postgres',
    host: 'localhost',
    database: 'project',
    password: 'password',
    port: 5432
};
```


# How to run

Please make sure to have `nodejs` installed and `npm`

Install the following using `npm`

```
> npm install -g typescript ts-node
```

Then, go to the directory where `package.json` is and execute in the terminal to install all modules necessary.

```
> npm install
```

Finally, execute
```
> npm run dev
```

and go to `http://localhost:8000` in the browser.
