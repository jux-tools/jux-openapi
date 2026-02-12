// SPDX-FileCopyrightText: 2026 Georges Martin <jrjsmrtn@gmail.com>
// SPDX-License-Identifier: Apache-2.0

/*
 * Jux API Architecture (Generic/Implementation Agnostic)
 *
 * This C4 model describes the Jux API contract without implementation details.
 * Any client or server can implement this contract regardless of language or framework.
 *
 * Version: 1.0.0
 * OpenAPI Specification: See openapi-submission-v1.yaml and openapi-query-v1.yaml
 */

workspace "Jux API Contract Architecture" "Generic architecture for Jux API v1" {

    model {
        # External actors
        developer = person "Developer" {
            description "Individual developer or team member running tests"
        }

        ciPipeline = softwareSystem "CI/CD Pipeline" {
            description "Automated build and test pipeline"
            tags "External System"
        }

        # Generic API Client (implementation agnostic)
        testRunnerPlugin = softwareSystem "Test Runner Plugin" {
            description "Plugin for test frameworks (pytest, Jest, JUnit, etc.) that submits results to Jux API"
            tags "API Client"

            metadataCollector = container "Metadata Collector" {
                description "Extracts git, CI, and environment metadata"
                technology "Any Language"
            }

            xmlGenerator = container "JUnit XML Generator" {
                description "Generates JUnit XML with embedded metadata properties"
                technology "Any Language"
            }

            apiClient = container "HTTP Client" {
                description "Submits XML to Jux API endpoint"
                technology "HTTP/REST"
            }
        }

        # Generic API Server (implementation agnostic)
        juxApiServer = softwareSystem "Jux API Server" {
            description "Server implementing Jux API v1 contract (any implementation: jux, jux_team_server, or custom)"

            apiEndpoint = container "API Endpoint" {
                description "Implements OpenAPI v1 specification"
                technology "HTTP REST API"

                submissionHandler = component "Submission Handler" "Receives and validates JUnit XML submissions" "POST /api/v1/junit/submit"
                queryHandler = component "Query Handler" "Returns test results with filtering and pagination" "GET /api/v1/test_runs"
                authHandler = component "Authentication Handler" "Validates API keys (except localhost)" "Authorization middleware"
            }

            xmlProcessor = container "XML Processor" {
                description "Parses JUnit XML and extracts metadata from properties"
                technology "Any Language"
            }

            storage = container "Test Results Storage" {
                description "Persistent storage for test runs, suites, and cases"
                technology "Database (SQLite, PostgreSQL, MySQL, or any database)"
            }
        }

        # Relationships - Test Runner Plugin Internal
        metadataCollector -> xmlGenerator "Provides metadata for embedding in XML properties"
        xmlGenerator -> apiClient "Passes JUnit XML with metadata"

        # Relationships - External to API
        developer -> testRunnerPlugin "Runs tests locally (localhost submission)"
        ciPipeline -> testRunnerPlugin "Runs tests in CI/CD (remote submission)"
        apiClient -> submissionHandler "POST /api/v1/junit/submit (application/xml)" "HTTPS"
        apiClient -> queryHandler "GET /api/v1/test_runs" "HTTPS"

        # Relationships - API Internal
        submissionHandler -> authHandler "Validates API key (if not localhost)"
        submissionHandler -> xmlProcessor "Sends XML for parsing"
        queryHandler -> authHandler "Validates API key (if not localhost)"
        xmlProcessor -> storage "Stores parsed test results"
        queryHandler -> storage "Retrieves test results"
    }

    views {
        systemContext juxApiServer "JuxApiSystemContext" {
            include *
            autoLayout lr
            description "System context showing Jux API server and clients (implementation agnostic)"
        }

        container juxApiServer "JuxApiContainers" {
            include *
            autoLayout lr
            description "Container view of Jux API server components (implementation agnostic)"
        }

        component apiEndpoint "JuxApiComponents" {
            include *
            autoLayout lr
            description "Component view of API endpoint handlers"
        }

        container testRunnerPlugin "TestRunnerPluginContainers" {
            include *
            autoLayout lr
            description "Container view of Test Runner Plugin (pytest-jux, junit-jux, jest-jux, etc.)"
        }

        styles {
            element "Person" {
                shape Person
                background #08427b
                color #ffffff
            }
            element "External System" {
                background #999999
                color #ffffff
            }
            element "API Client" {
                background #438dd5
                color #ffffff
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
        }
    }

}
