#!/bin/bash

filename="scenarios/input_data.csv"

# Write the header to the file
echo "username,firstName,lastName,email,password,phone,userStatus" > $filename

# Get the number of records from the first argument, default is 5
num_records=${1:-5}

# Use a for loop to create the specified number of records
for (( i=1; i<=num_records; i++ ))
do
  # Write the data to the file
  echo "username$i,firstName$i,lastName$i,username$i@example.com,password$i,+38067000000$i,$((i%2))" >> $filename
done

# Replace the LoopController.loops value in the jmx file
sed_command="s|<stringProp name=\"LoopController.loops\">[0-9]*</stringProp>|<stringProp name=\"LoopController.loops\">$num_records</stringProp>|g"
sed -i '' "$sed_command" scenarios/SDT503Assignment3Scenario.jmx || { echo "sed command failed"; exit 1; }

# Build the Docker image
docker build -t test_jmeter . || { echo "Docker build failed"; exit 1; }

# Remove existing container if it exists
if docker ps -a | grep -q test_jmeter; then
    docker rm -f test_jmeter || { echo "Failed to remove existing Docker container"; exit 1; }
fi

# Run the Docker container
docker run -v "$(pwd)"/scenarios:/jmeter/scenarios -v "$(pwd)"/results:/jmeter/results --name test_jmeter --entrypoint "" test_jmeter java -jar '/opt/apache-jmeter-5.5/bin/ApacheJMeter.jar' -n -f -t '/jmeter/scenarios/SDT503Assignment3Scenario.jmx' -l '/jmeter/results/performance.jtl' -e -o '/jmeter/results/report' || { echo "Docker run failed"; exit 1; }
