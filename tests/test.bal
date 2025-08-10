import ballerina/test;
import ballerina/http;

// HTTP client for testing the Todo API service
final http:Client clientEp = check new ("http://localhost:9090");

// Test data setup and cleanup functions
@test:BeforeSuite
function beforeSuite() returns error? {
    // Setup test data if needed
}

@test:AfterSuite
function afterSuite() returns error? {
    // Cleanup test data if needed
}

// Scenario 1.1: GET /api/v1/todos - Retrieve all todos without query parameters
@test:Config {}
function testGetAllTodos() returns error? {
    // Action: Send GET request to retrieve all todos without any query parameters
    TodoResponse response = check clientEp->/api/v1/todos();
    
    // Validation: Verify response structure, success flag is true, data array contains todo items
    test:assertEquals(response.success, true, "Success flag should be true");
    test:assertEquals(response.message, "All todos retrieved successfully", "Message should indicate all todos retrieved");
    test:assertTrue(response.data is Todo[], "Data should be an array of todos");
}

// Scenario 1.2: GET /api/v1/todos?completed=true - Filter completed todos
@test:Config {}
function testGetCompletedTodos() returns error? {
    // Action: Send GET request with completed=true query parameter to filter completed todos
    TodoResponse response = check clientEp->/api/v1/todos(completed = true);
    
    // Validation: Verify all returned todos have completed=true, response structure is correct
    test:assertEquals(response.success, true, "Success flag should be true");
    test:assertEquals(response.message, "Filtered todos retrieved successfully", "Message should indicate filtered todos retrieved");
    test:assertTrue(response.data is Todo[], "Data should be an array of todos");
    
    Todo|Todo[]? data = response.data;
    if data is Todo[] {
        foreach Todo todo in data {
            test:assertEquals(todo.completed, true, "All returned todos should be completed");
        }
    }
}

// Scenario 2.1: GET /api/v1/todos/[int todoId] - Get specific todo by valid ID
@test:Config {}
function testGetTodoByValidId() returns error? {
    // First create a todo to ensure we have a valid ID
    TodoRequest newTodo = {
        title: "Test Todo for Get",
        description: "Test description",
        completed: false
    };
    TodoResponse createResponse = check clientEp->/api/v1/todos.post(newTodo);
    
    Todo|Todo[]? data = createResponse.data;
    if data is Todo {
        int todoId = data.id;
        
        // Action: Send GET request with valid existing todo ID
        TodoResponse response = check clientEp->/api/v1/todos/[todoId]();
        
        // Validation: Verify returned todo matches the requested ID and contains all required fields
        test:assertEquals(response.success, true, "Success flag should be true");
        test:assertEquals(response.message, "Todo retrieved successfully", "Message should indicate todo retrieved successfully");
        test:assertTrue(response.data is Todo, "Data should be a Todo record");
        
        Todo|Todo[]? dataResult = response.data;
        if dataResult is Todo {
            test:assertEquals(dataResult.id, todoId, "Returned todo ID should match requested ID");
            test:assertTrue(dataResult.title.length() > 0, "Todo should have a title");
        }
    }
}

// Scenario 2.2: GET /api/v1/todos/[int todoId] - Get todo with non-existent ID
@test:Config {}
function testGetTodoByNonExistentId() returns error? {
    // Action: Send GET request with non-existent todo ID
    http:Response response = check clientEp->/api/v1/todos/[99999];
    
    // Validation: Verify HTTP status code is 404
    test:assertEquals(response.statusCode, 404, "Status code should be 404 for non-existent todo");
}

// Scenario 3.1: POST /api/v1/todos - Create todo with valid payload
@test:Config {}
function testCreateTodoWithValidPayload() returns error? {
    // Action: Send POST request with valid TodoRequest payload
    TodoRequest todoRequest = {
        title: "New Test Todo",
        description: "Test description for new todo",
        completed: false
    };
    
    TodoResponse response = check clientEp->/api/v1/todos.post(todoRequest);
    
    // Validation: Verify new todo has valid ID, matches input data, and response structure is correct
    test:assertEquals(response.success, true, "Success flag should be true");
    test:assertEquals(response.message, "Todo created successfully", "Message should indicate todo created successfully");
    test:assertTrue(response.data is Todo, "Data should be a Todo record");
    
    Todo|Todo[]? data = response.data;
    if data is Todo {
        test:assertTrue(data.id > 0, "New todo should have a valid ID");
        test:assertEquals(data.title, todoRequest.title, "Title should match input");
        test:assertEquals(data.description, todoRequest.description, "Description should match input");
        test:assertEquals(data.completed, false, "Completed should match input");
    }
}

// Scenario 3.2: POST /api/v1/todos - Create todo with empty title
@test:Config {}
function testCreateTodoWithEmptyTitle() returns error? {
    // Action: Send POST request with empty or whitespace-only title
    TodoRequest todoRequest = {
        title: "   ",
        description: "Test description",
        completed: false
    };
    
    http:Response response = check clientEp->/api/v1/todos.post(todoRequest);
    
    // Validation: Verify HTTP status code is 400
    test:assertEquals(response.statusCode, 400, "Status code should be 400 for empty title");
}

// Scenario 4.1: PUT /api/v1/todos/[int todoId] - Update todo with valid data
@test:Config {}
function testUpdateTodoWithValidData() returns error? {
    // First create a todo to update
    TodoRequest newTodo = {
        title: "Todo to Update",
        description: "Original description",
        completed: false
    };
    TodoResponse createResponse = check clientEp->/api/v1/todos.post(newTodo);
    
    Todo|Todo[]? data = createResponse.data;
    if data is Todo {
        int todoId = data.id;
        
        // Action: Send PUT request with valid todo ID and TodoRequest payload
        TodoRequest updateRequest = {
            title: "Updated Todo Title",
            description: "Updated description",
            completed: true
        };
        
        TodoResponse response = check clientEp->/api/v1/todos/[todoId].put(updateRequest);
        
        // Validation: Verify todo is updated with new values and response contains the updated data
        test:assertEquals(response.success, true, "Success flag should be true");
        test:assertEquals(response.message, "Todo updated successfully", "Message should indicate todo updated successfully");
        test:assertTrue(response.data is Todo, "Data should be a Todo record");
        
        Todo|Todo[]? dataResult = response.data;
        if dataResult is Todo {
            test:assertEquals(dataResult.id, todoId, "ID should remain the same");
            test:assertEquals(dataResult.title, updateRequest.title, "Title should be updated");
            test:assertEquals(dataResult.description, updateRequest.description, "Description should be updated");
            test:assertEquals(dataResult.completed, true, "Completed should be updated");
        }
    }
}

// Scenario 4.2: PUT /api/v1/todos/[int todoId] - Update non-existent todo
@test:Config {}
function testUpdateNonExistentTodo() returns error? {
    // Action: Send PUT request with non-existent todo ID
    TodoRequest updateRequest = {
        title: "Updated Title",
        description: "Updated description",
        completed: true
    };
    
    http:Response response = check clientEp->/api/v1/todos/[99999].put(updateRequest);
    
    // Validation: Verify HTTP status code is 404
    test:assertEquals(response.statusCode, 404, "Status code should be 404 for non-existent todo");
}

// Scenario 6.1: DELETE /api/v1/todos/[int todoId] - Delete existing todo
@test:Config {}
function testDeleteExistingTodo() returns error? {
    // First create a todo to delete
    TodoRequest newTodo = {
        title: "Todo to Delete",
        description: "Test description",
        completed: false
    };
    TodoResponse createResponse = check clientEp->/api/v1/todos.post(newTodo);
    
    Todo|Todo[]? data = createResponse.data;
    if data is Todo {
        int todoId = data.id;
        Todo originalTodo = data;
        
        // Action: Send DELETE request with valid existing todo ID
        TodoResponse response = check clientEp->/api/v1/todos/[todoId].delete();
        
        // Validation: Verify response contains the deleted todo data
        test:assertEquals(response.success, true, "Success flag should be true");
        test:assertEquals(response.message, "Todo deleted successfully", "Message should indicate todo deleted successfully");
        test:assertTrue(response.data is Todo, "Data should be a Todo record");
        
        Todo|Todo[]? dataResult = response.data;
        if dataResult is Todo {
            test:assertEquals(dataResult.id, originalTodo.id, "Deleted todo ID should match original");
            test:assertEquals(dataResult.title, originalTodo.title, "Deleted todo title should match original");
        }
        
        // Validation: Verify subsequent GET request for same ID returns 404
        http:Response getResponse = check clientEp->/api/v1/todos/[todoId];
        test:assertEquals(getResponse.statusCode, 404, "GET request for deleted todo should return 404");
    }
}

// Scenario 6.2: DELETE /api/v1/todos/[int todoId] - Delete non-existent todo
@test:Config {}
function testDeleteNonExistentTodo() returns error? {
    // Action: Send DELETE request with non-existent todo ID
    http:Response response = check clientEp->/api/v1/todos/[99999].delete();
    
    // Validation: Verify HTTP status code is 404
    test:assertEquals(response.statusCode, 404, "Status code should be 404 for non-existent todo");
}
