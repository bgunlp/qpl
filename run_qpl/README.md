# QPL Checker

This application runs a Web User Interface to execute QPL programs on a database.
It allows you to manually test QPL programs predicted by a model interactively to verify their execution.

## Instructions

1. Run `docker-compose up --build`
2. Go to `http://localhost:5173`
3. Select the correct schema name from the dropdown
4. Write QPL line-by-line, i.e., not separated by semicolons
5. Click "Submit"
6. Errors appear in red, results appear in a table

## Example

![image](https://github.com/bgunlp/qpl/assets/3891274/7cec119f-0290-43b3-ba9f-cca23ef2b04f)
