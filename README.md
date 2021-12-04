# How to run

Please make sure to have `nodejs` installed and `npm`

Install the following using `npm`

```
> npm install -g typescript ts-node
```

Then, go to the directory where `package.json` is and execute in the terminal

```
> npm install
```

To install all modules necessary.

Finally, execute
```
> npm run dev
```

and go to `http://localhost:8000` in the browser.

# TODO

- Create a trigger that check that publisher_email and owner_email/customer_email are not the same and vice versa (due to disjoint)
- Do the same for author/owner and author/customer
- Write all the SQL queries in database.ts to a query folder