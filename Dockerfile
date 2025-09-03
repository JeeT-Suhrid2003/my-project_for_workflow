# ---- Build Stage ----
FROM gradle:8.7-jdk17 AS builder
WORKDIR /app

# Copy Gradle files first (for better caching)
COPY build.gradle settings.gradle gradlew* ./
COPY gradle gradle

# Download dependencies
RUN ./gradlew dependencies --no-daemon || return 0

# Copy full project and build
COPY . .
RUN ./gradlew build --no-daemon -x test

# ---- Run Stage ----
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the built JAR (finds it dynamically)
COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
