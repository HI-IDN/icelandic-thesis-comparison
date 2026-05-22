# Agent Notes

## Working Style

- Keep the project focused on the current workflow:
  1. initialize DuckDB with `scripts/create_thesis_db.sql`;
  2. run `skemman simple-search` for the HI and HR handles over years 2010..2026;
  3. run `skemman metadata-load`;
  4. analyze the resulting database, currently with `scripts/analyse.R`.
- Prefer the `skemman` CLI for scraper actions. Do not add duplicate one-off Python scripts when a CLI command is the intended interface.
- Remove temporary files, old setup files, and unused scaffolding when they are no longer part of the workflow.
- Keep `README.md` and related docs updated whenever workflow, commands, schema mapping, or file layout changes.
- After making a related set of changes and verifying them, commit those related changes to git. Do not include unrelated dirty files in the commit.
- If the user says a change is OK or asks for a change to be made, treat that as permission to commit the related files once verification passes.

## Running Scripts

- Run commands directly with the repository working directory set to `C:\Users\hbi3\Documents\icelandic-thesis-comparison`.
- Use the local environment and project commands as needed for verification.
- It is OK to run appropriate checks yourself, including focused Python compile/import checks and project tests when they are relevant to the change.
