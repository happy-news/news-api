import ballerina/http;
import ballerina/sql;
import ballerinax/postgresql;
import ballerina/os;


listener http:Listener httpListener = new(9090);

service /newsAPI on httpListener {

    resource function get news() returns json|error {
        // Environment variables
        string dbHost =  os:getEnv("DB_HOST");
        string dbUsername =  os:getEnv("DB_USERNAME");
        string dbPassword =  os:getEnv("DB_PASSWORD");
        string dbName =  os:getEnv("DB_NAME");
        

        // MySQL client configuration
        postgresql:Client dbClient = check new(
            dbHost,
            dbUsername,
            dbPassword,
            dbName
        );
        sql:ParameterizedQuery query = `SELECT id, title, news, image_url, url, category_id FROM news`;
        // Select query
        stream<News, sql:Error?> resultStream = dbClient->query(query);

        // Initialize json array
        json[] newsArray = [];

        check from News news in resultStream
        do {
            newsArray.push(news.toJson());
        };

        // Close database connection
        check dbClient.close();

        return newsArray;
    }
}

type News record {
    int id;
    string title;
    string news;
    string image_url;
    string url;
    int category_id;
};
