# Stage 1: Build the application
FROM openjdk:21-jdk-slim AS builder

# Set the working directory
WORKDIR /app

# Copy the Maven build files and the source code to the container
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

# Make the mvnw script executable
RUN chmod +x mvnw

# Install dependencies and package the application
RUN ./mvnw clean package -DskipTests

# Verify the JAR file in the target directory
RUN ls -al target/

# Stage 2: Run the application
FROM openjdk:19-jdk-slim

# Set the working directory
WORKDIR /app

# Copy the JAR file from the builder stage
COPY --from=builder /app/target/agency-0.0.1-SNAPSHOT.jar /app/agency-0.0.1-SNAPSHOT.jar

# Expose the port that the application runs on
EXPOSE 8080

# Define the command to run the application
CMD ["java", "-jar", "/app/agency-0.0.1-SNAPSHOT.jar"]
