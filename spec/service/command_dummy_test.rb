# This Ruby program takes two command-line arguments:
# 1. A string to be printed.
# 2. An integer representing the desired exit status code.

# Check if the correct number of arguments is provided.
if ARGV.length != 2
  # If not, print an error message to stderr and exit with a non-zero status.
  warn "Usage: ruby #{$PROGRAM_NAME} <text_to_print> <exit_code>"
  exit 1
end

# Assign the command-line arguments to variables.
text_to_print = ARGV[0]
exit_code_str = ARGV[1]

# Attempt to convert the second argument to an integer.
begin
  exit_code = Integer(exit_code_str)
rescue ArgumentError
  # If the second argument is not a valid integer, print an error to stderr
  # and exit with a non-zero status.
  warn "Error: The second argument must be an integer."
  exit 1
end

# Check the value of the exit code.
if exit_code == 0
  # If the exit code is 0, print the text to standard output (stdout).
  puts text_to_print
  # Exit the program successfully with status code 0.
  exit 0
else
  # If the exit code is anything other than 0, print the text to standard error (stderr).
  warn text_to_print
  # Exit the program with the specified non-zero status code.
  exit exit_code
end
