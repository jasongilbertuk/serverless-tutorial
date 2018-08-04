'use strict';

exports.handler = function(event, context, callback) {

	var responseBody = {
		"message" : "Hello World!"
	};

    const response = { 'statusCode': 200, 
                       'headers': {'Content-Type': 'application/json'},
                       'body': JSON.stringify(responseBody),
                       'isBase64Encoded' : false };
    callback(null, response);
}