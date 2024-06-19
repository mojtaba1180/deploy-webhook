# Use an official Node.js runtime as the base image
FROM node:20-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies 
RUN npm install

# Copy the rest of the application code
COPY . .

# Ensure the deploy script is executable
RUN chmod +x /app/deploy_script.sh

# Expose the port the app runs on
EXPOSE 3000

# Command to run the app
CMD ["npm", "run","start"]