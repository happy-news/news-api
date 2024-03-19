import ballerina/http;
import ballerina/sql;
import ballerinax/postgresql;
import ballerina/os;

listener http:Listener httpListener = new(9090);

service /newsAPI on httpListener {

    resource function get news() returns json|error {
        postgresql:Client dbClient = check createDbClient();
        sql:ParameterizedQuery query = `SELECT id, title, news, image_url, url, category_id FROM news`;
        stream<News, sql:Error?> resultStream = dbClient->query(query);
        json[] newsArray = [];
        check from News news in resultStream
        do {
            newsArray.push(news.toJson());
        };
        check closeDbClient(dbClient);
        return newsArray;
    }

    resource function get categories() returns json|error {
        postgresql:Client dbClient = check createDbClient();
        sql:ParameterizedQuery query = `SELECT id, category FROM categories`;
        stream<Category, sql:Error?> resultStream = dbClient->query(query);
        json[] categoriesArray = [];
        check from Category category in resultStream
        do {
            categoriesArray.push(category.toJson());
        };
        check closeDbClient(dbClient);
        return categoriesArray;
    }
}

// Utility function to create a new database client
function createDbClient() returns postgresql:Client|error {
    string dbHost =   os:getEnv("DB_HOST");
    string dbUsername =   os:getEnv("DB_USERNAME");
    string dbPassword =   os:getEnv("DB_PASSWORD");
    string dbName =   os:getEnv("DB_NAME");
    return new postgresql:Client(dbHost, dbUsername, dbPassword, dbName, 25059);
}

// Utility function to close the database client
function closeDbClient(postgresql:Client dbClient) returns error? {
    return dbClient.close();
}

type Category record {
    int id;
    string category;
};

type News record {
    int id;
    string title;
    string news;
    string image_url;
    string url;
    int category_id;
};