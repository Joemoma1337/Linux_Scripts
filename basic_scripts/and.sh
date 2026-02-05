Description
The AND operator (represented as &&) is a logical operator used to combine multiple conditions in a single if statement.
For the entire statement to be considered True, every individual condition must evaluate to true.
If even one part is false, the whole block fails.

Think of it as a strict security gate: you need both the correct ID card and the correct passcode to enter.
https://encrypted-tbn1.gstatic.com/licensed-image?q=tbn:ANd9GcTc86ZQoBPHbON7nx6LW5iyLI0YSGARp4JSI0VeGmCfyniAMGdznI9uDX9V4QW2Mb7EeOpV5Ar6Y4HJtxpJOZrWIuSVWnF_s03Dr2PigmBqLAAx3aM

Example Usage
In this example, we check if a number is "Small and Even." To pass, the number must be less than 10 AND divisible by 2.
```
#!/bin/bash

echo -n "Enter a number: "
read num

# Condition 1: Less than 10
# Condition 2: Remainder when divided by 2 is 0
if [[ ($num -lt 10) && ($num%2 -eq 0) ]]; then
    echo "The number $num is a small even number."
else
    echo "The number $num does not meet both criteria."
fi
```

Key Syntax Tips
    Double Brackets: Using [[ ... ]] is the modern standard in Bash for tests; it's more flexible and handles the && operator more cleanly than the old [ ] syntax.
    Exit Status: In Linux, && is also used between commands. For example, mkdir folder && cd folder tells Bash: "Only try to enter the folder if the creation was successful."

Scenario Challenges
Test your knowledge by trying to write scripts for these real-world situations:
    The Login Validator: Create a script that asks for a username and a password. Use the && operator to print "Access Granted" only if the username is "admin" and the password is "P@ss123".
    The Age & Status Check: Write a script that asks for a user's age. Use && to check if the age is between 13 and 19 (inclusive). If both are true, print "You are a teenager."
    File Permissions: Create a script that checks if a file named config.sh both exists (-f) and is executable (-x).
