use FindBin;
use lib $FindBin::Bin;

use Carp qw(cluck confess);
use Client;
use Data::Dumper;
use JSON;
use TryCatch;
use autodie;
use strictures 2;

sub register
{
    # used to test the example api as well as the REST Client module

    my ($username, $password) = @_;
    my $client = Client->new(host=>"https://interview-api.example.com");
    my $data = { username => $username,
                 password => $password };
    my ($response_code, $content) = $client->POST("/register", $data);
    print Dumper $content;
    return $response_code;
}

sub check_auth
{
    # used to test the example api as well as the REST Client module

    my ($username, $password) = @_;
    my $client = Client->new(host=>"https://interview-api.example.com");
    my ($response_code, $content) = $client->GET("/auth?username=$username&password=$password");
    print Dumper $content;
    return $response_code;
}
