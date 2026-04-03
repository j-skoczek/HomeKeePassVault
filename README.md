# HomeKeePassVault

Syncing .kdbx files over multiple machines can be annoying. Here is a simple, self hosted solution for that problem.

# How it works

Deploy the docker on you local server, and enjoy the app. By default the app will keep last 5 vesrions of .kdbx files. Users will have to resolve conflicts on their own.

# Some safety precautions

Do not use the app outside local networks.
Always use kee files.
Do not store keefiles in the vault.
Use hardware keys.

# Getting started

Copy `.env.example` as `.env` and fill it with data.
Install docker compose v2
Run `docker compose build && docker compose up`
Go to the link TODO: provide setup for custom url for the app
