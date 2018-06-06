# Backend Engineer Coding Exercise

**__Link to solution documentation: [SOLUTION](README-solution.md)__**

In order to make this more about coding than operations work, we have
spun up an EC2 instance for you that uses the default Ubuntu 16.04
image. You have sudo on that box and are welcome to install any
languages or tools you wish to uses to complete this exercise.  The
following ports are publicly accessible: 22 (ssh), 80 (http), and 443(
https).


## Our Service

We have created a REST API which you will be utilizing manually and
programmatically within your service.

https://interview-api.example.com/

**POST/register**

Used to created new email/password combinations for authentication.
Your do not need to incorporate this into your service but will use it
to create valid credentials.
```
Input:
    JSON object containing "username" and "password"
Output:
    JSON object containing "user_id" on success. This can be
    ignored.
Example Response:
    {"user_id":"3"}
```

**GET/authentication**

Used by your service to validate the basic auth credentials passed to
each of your endpoints.
```
Input:
    Query parameters of "username" and "password"
Output:
    HTTP/200 with a JSON object containing "user_id" on successful
    auth. HTTP/404 on auth failure.
Example Request:
    curl 'https://interview-api.example.com/auth?username=TBD&password=TBD'
Example Response:
    {"user_id":"3"}
```

## Your Service

### General Requirements

All requests to your service should include basic auth. The
user/passed from the basic auth should be tested against
htts://interview-api.example.com/auth ( see above). Successful
authentication should continue, unsuccessful authentication should
immediately return an HTTP status code of 401 with no data.

POST requests should be a JSON object as the posted content.  They
should also include a SHA1 signature of the content passed in
"signature" as query parameter.  If the SHA1 passed is not valid for
the content posted, the API should return an HTTP status code of 403.

Missing parameters should be handled by returning a 422

Assume that your service will operate in a non-sticky, load balanced
environment and as such consecutive requests may be received by
different servers.

### Endpoints

**POST /split**

splits the passed string into even and odd character arrays. Assumes
that the first character in the string is character 1 which is odd.
```
Input:
    JSON object with single key of "string" that contains a string.
Output:
    JSON object with keys for "even" and "odd". Each is an array of
    characters.
Example Request:
    curl -X POST -u USER:PASSed \
    http://your_url/split?signature=04e74feb8cfc0b502ff701a9b5f0b98ecec0d3b4 \
    -d {"string":"split me"}
Example Response:
    {"odd" : ["s","l","t","m"], "even" : ["p", "i", " ", "e"]}
```

**POST /join**

The opposite of /split. Given assumptions in /split, the output
string will start with the first element from "odd".
```
Input:
   JSON object with keys for "even" and "odd". Each is an array of
   characters
Output:
   JSON object with single key of "string" that contains a string.
Example Request:
   curl -X POST -u USER:PASS \
   http://your_url/join?signature=6edd74450aa9206c4ba0b8c009de382a3e91f404 \
  -d '{"odd": ["s","l","t","m"], "even": "["p","i"," "m,"e'"]"}'
Example Response:
   {"string":"split me"}
```
**GET /lastResponse**

Returns the last successful result returned to that
authenticated user.
Note: Do note return user A's results to user B.
```
Input:
   None
Ouput:
   JSON object that was last returned the user. Actual object depends on
   which method was last called.
Example Request:
   curl -u USER:PASS http://your_url/lastResponse
Example Response:
{"string":"split me"}
```