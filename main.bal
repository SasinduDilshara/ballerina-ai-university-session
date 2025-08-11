import ballerinax/ai.openai;
import ballerina/io;

configurable string apiKey = ?;
final readonly & string[] categories = ["Gardening", "Sports", "Health", "Technology", "Travel"];

public type Blog record {|
    string title;
    string content;
|};

type Review record {|
    string? suggestedCategory;
    int rating;
|};

function reviewBlog(Blog blog) returns Review|error {
    openai:ModelProvider model = check new (apiKey, openai:GPT_4O_MINI);

    Review review = check model->generate(`You are an expert content reviewer for a blog site that 
        categorizes posts under the following categories: ${categories}

        Your tasks are:
        1. Suggest a suitable category for the blog from exactly the specified categories. 
        If there is no match, use null.

        2. Rate the blog post on a scale of 1 to 10 based on the following criteria

        Here is the blog post content:

        Title: ${blog.title}
        Content: ${blog.content}`);

    return review;
}

public function main() returns error? {
    Blog blog = {
        title: "The Benefits of Urban Gardening",
        content: "Urban gardening is a great way to grow your own food in the city. It helps reduce stress, provides fresh produce, and enhances the urban environment."
    };

    Review review = check reviewBlog(blog);
    io:println("Suggested Category: ", review.suggestedCategory);
    io:println("Rating: ", review.rating);
}
