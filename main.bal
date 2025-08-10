import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;

// Database configuration
configurable string dbHost = "localhost";
configurable int dbPort = 3306;
configurable string dbUser = "root";
configurable string dbPassword = "";
configurable string dbName = "todo_db";

// MySQL client initialization
final mysql:Client dbClient = check new (
    host = dbHost,
    port = dbPort,
    user = dbUser,
    password = dbPassword,
    database = dbName
);

// HTTP service for Todo application
service /api/v1 on new http:Listener(9090) {

    // Get all todos or filter by completion status
    resource function get todos(boolean? completed) returns TodoResponse|http:InternalServerError {
        sql:ParameterizedQuery query;

        if completed is boolean {
            query = `SELECT id, title, description, completed FROM todos WHERE completed = ${completed}`;
        } else {
            query = `SELECT id, title, description, completed FROM todos`;
        }

        stream<Todo, sql:Error?> todoStream = dbClient->query(query);
        Todo[]|error todoArray = from Todo todo in todoStream
            select todo;

        if todoArray is error {
            return http:INTERNAL_SERVER_ERROR;
        }

        error? closeResult = todoStream.close();
        if closeResult is error {
            return http:INTERNAL_SERVER_ERROR;
        }

        string responseMessage = completed is boolean ? "Filtered todos retrieved successfully" : "All todos retrieved successfully";

        return {
            success: true,
            message: responseMessage,
            data: todoArray
        };
    }

    // Get a specific todo by ID
    resource function get todos/[int todoId]() returns TodoResponse|http:NotFound|http:InternalServerError {
        sql:ParameterizedQuery query = `SELECT id, title, description, completed FROM todos WHERE id = ${todoId}`;

        Todo|sql:Error result = dbClient->queryRow(query);

        if result is sql:NoRowsError {
            return http:NOT_FOUND;
        }

        if result is sql:Error {
            return http:INTERNAL_SERVER_ERROR;
        }

        return {
            success: true,
            message: "Todo retrieved successfully",
            data: result
        };
    }

    // Create a new todo
    resource function post todos(@http:Payload TodoRequest todoRequest) returns TodoResponse|http:BadRequest|http:InternalServerError {
        string todoTitle = todoRequest.title;
        if todoTitle.trim().length() == 0 {
            return http:BAD_REQUEST;
        }

        string? todoDescription = todoRequest.description;
        boolean todoCompleted = todoRequest.completed ?: false;

        sql:ParameterizedQuery insertQuery = `INSERT INTO todos (title, description, completed) 
                                             VALUES (${todoTitle}, ${todoDescription}, ${todoCompleted})`;

        sql:ExecutionResult|sql:Error insertResult = dbClient->execute(insertQuery);

        if insertResult is sql:Error {
            return http:INTERNAL_SERVER_ERROR;
        }

        string|int? lastInsertId = insertResult.lastInsertId;
        if lastInsertId is () {
            return http:INTERNAL_SERVER_ERROR;
        }

        int newTodoId;
        if lastInsertId is string {
            int|error parsedId = int:fromString(lastInsertId);
            if parsedId is error {
                return http:INTERNAL_SERVER_ERROR;
            }
            newTodoId = parsedId;
        } else {
            newTodoId = lastInsertId;
        }

        Todo newTodo = {
            id: newTodoId,
            title: todoTitle,
            description: todoDescription,
            completed: todoCompleted
        };

        return {
            success: true,
            message: "Todo created successfully",
            data: newTodo
        };
    }

    // Update an existing todo
    resource function put todos/[int todoId](@http:Payload TodoRequest todoRequest) returns TodoResponse|http:NotFound|http:BadRequest|http:InternalServerError {
        string todoTitle = todoRequest.title;
        if todoTitle.trim().length() == 0 {
            return http:BAD_REQUEST;
        }

        // Check if todo exists
        sql:ParameterizedQuery checkQuery = `SELECT id FROM todos WHERE id = ${todoId}`;
        int|sql:Error existsResult = dbClient->queryRow(checkQuery);

        if existsResult is sql:NoRowsError {
            return http:NOT_FOUND;
        }

        if existsResult is sql:Error {
            return http:INTERNAL_SERVER_ERROR;
        }

        string? todoDescription = todoRequest.description;
        boolean? todoCompleted = todoRequest.completed;

        sql:ParameterizedQuery updateQuery;
        if todoCompleted is boolean {
            updateQuery = `UPDATE todos SET title = ${todoTitle}, description = ${todoDescription}, 
                          completed = ${todoCompleted} WHERE id = ${todoId}`;
        } else {
            updateQuery = `UPDATE todos SET title = ${todoTitle}, description = ${todoDescription} 
                          WHERE id = ${todoId}`;
        }

        sql:ExecutionResult|sql:Error updateResult = dbClient->execute(updateQuery);

        if updateResult is sql:Error {
            return http:INTERNAL_SERVER_ERROR;
        }

        // Fetch updated todo
        sql:ParameterizedQuery fetchQuery = `SELECT id, title, description, completed FROM todos WHERE id = ${todoId}`;
        Todo|sql:Error updatedTodo = dbClient->queryRow(fetchQuery);

        if updatedTodo is sql:Error {
            return http:INTERNAL_SERVER_ERROR;
        }

        return {
            success: true,
            message: "Todo updated successfully",
            data: updatedTodo
        };
    }

    // Mark a specific todo as completed
    resource function post todos/[int todoId]/complete() returns TodoResponse|http:NotFound|http:InternalServerError {
        // Check if todo exists
        sql:ParameterizedQuery checkQuery = `SELECT id FROM todos WHERE id = ${todoId}`;
        int|sql:Error existsResult = dbClient->queryRow(checkQuery);

        if existsResult is sql:NoRowsError {
            return http:NOT_FOUND;
        }

        if existsResult is sql:Error {
            return http:INTERNAL_SERVER_ERROR;
        }

        // Update todo to mark as completed
        sql:ParameterizedQuery updateQuery = `UPDATE todos SET completed = true WHERE id = ${todoId}`;
        sql:ExecutionResult|sql:Error updateResult = dbClient->execute(updateQuery);

        if updateResult is sql:Error {
            return http:INTERNAL_SERVER_ERROR;
        }

        // Fetch updated todo
        sql:ParameterizedQuery fetchQuery = `SELECT id, title, description, completed FROM todos WHERE id = ${todoId}`;
        Todo|sql:Error completedTodo = dbClient->queryRow(fetchQuery);

        if completedTodo is sql:Error {
            return http:INTERNAL_SERVER_ERROR;
        }

        return {
            success: true,
            message: "Todo marked as completed successfully",
            data: completedTodo
        };
    }

    // Delete a todo
    resource function delete todos/[int todoId]() returns TodoResponse|http:NotFound|http:InternalServerError {
        // First, get the todo to return it in response
        sql:ParameterizedQuery fetchQuery = `SELECT id, title, description, completed FROM todos WHERE id = ${todoId}`;
        Todo|sql:Error todoToDelete = dbClient->queryRow(fetchQuery);

        if todoToDelete is sql:NoRowsError {
            return http:NOT_FOUND;
        }

        if todoToDelete is sql:Error {
            return http:INTERNAL_SERVER_ERROR;
        }

        // Delete the todo
        sql:ParameterizedQuery deleteQuery = `DELETE FROM todos WHERE id = ${todoId}`;
        sql:ExecutionResult|sql:Error deleteResult = dbClient->execute(deleteQuery);

        if deleteResult is sql:Error {
            return http:INTERNAL_SERVER_ERROR;
        }

        return {
            success: true,
            message: "Todo deleted successfully",
            data: todoToDelete
        };
    }
}
