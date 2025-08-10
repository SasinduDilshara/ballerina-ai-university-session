// Todo item record type
public type Todo record {|
    int id;
    string title;
    string? description;
    boolean completed;
|};

// Request payload for creating/updating todos
public type TodoRequest record {|
    string title;
    string description?;
    boolean completed?;
|};

// Response wrapper for API responses
public type TodoResponse record {|
    boolean success;
    string message;
    Todo|Todo[]? data;
|};