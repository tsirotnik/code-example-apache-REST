### Git
There is a local git repo on the machine at:
```
/git/Solution
```

### Project Files:

All of the project files are checked out here:
```
/Solution
```
and the application runs from here.

### Apache2 + Memcached

I've configured Apache2 with mod_perl to act as the server using memcached as the data store for /lastResponse. In a production environment all of the REST servers will use the same memcached instance as their datastore so that should take care of the 'non-sticky' requirement.

I’ve left the apache2 and memcached services running for you.

### Testing

There is a test script located at /Solution/tests. You can test the application using:
```
cd /Solution/tests; perl test.pl
```

### Files

#### /Solution/apache-config/000-default.conf

This is a copy of the apache2 config that's deployed to /etc/apache2/sites-enabled.
Because I'm using CGI::Application::Dispatch there's some expected behavior that the urls will look like this:

/module/rest_call

so I'm using mod_rewrite to change the urls to conform to the specification:
/rest_call

#### /Solution/Solution/startup.pl

Provides memcached handle to be used globally by mod_perl processes. Sets lib path.

#### /Solution/Solution/Client.pm
Provides GET and POST requests. Used to query the example authentication server.

#### /Solution/Solution/Dispatch.pm
Dispatches the incoming rest calls to the appropriate methods

#### /Solution/Solution/RestAPI.pm
Incoming calls are dispatched here.  Functionality for the requests is provided here.

#### /Solution/utils/curl_util.sh
bash curl calls in case something needs to be done manually

#### /Solution/utils/util.pl (UNUSED )
Some perl methods unused by the application. Use these to access the example api in case you want to do it programmatically
.
#### /Solution/tests/test.pl
Test script providing some very basic unit tests. Assumes the following users are set up on the example authentication server:
```
valid1/password1
valid2/password2
```
And that the following users are *not* set up on the authentication server:
```
invalid/invalid
```