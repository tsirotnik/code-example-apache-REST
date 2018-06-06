
use Data::Dumper;
use Digest::SHA qw(sha1_hex);
use HTTP::Request::Common;
use JSON;
use LWP::UserAgent;
use Test::More;
use strict;
use warnings;

sub post_data
{

    my $type     = shift;
    my $username = shift;
    my $password = shift;
    my $json     = shift;
    my $url      = shift;
    my $sha1     = shift;

    $sha1 = sha1_hex($json) if ! defined $sha1;

    $url = "http://localhost/$type?signature=$sha1" if ! defined $url;
    my $req = HTTP::Request->new(POST => $url);
    $req->authorization_basic($username, $password);
    $req->content_type('application/json');
    $req->content($json);
    my $ua = LWP::UserAgent->new;
    my $res = $ua->request($req);

    return { response => $res->code(),
             content  => $res->content() }
}


sub lastResponse
{
    my $username = shift;
    my $password = shift;

    my $url = "http://localhost/lastResponse";
    my $req = HTTP::Request->new(GET => $url);
    $req->authorization_basic($username, $password);
    $req->content_type('application/json');
    my $ua = LWP::UserAgent->new;
    my $res = $ua->request($req);

    return { response => $res->code(),
             content  => $res->content() }
}


sub post_join { return post_data("join", $_[0], $_[1], $_[2])  }
sub post_split { return post_data("split", $_[0], $_[1], $_[2]) }

# data set 1
my $split_data1     = '{"odd":["s","l","t","m"],"even":["p","i"," ","e"]}';
my $split_data2     = '{"even":["p","i"," ","e"],"odd":["s","l","t","m"]}';
my $joined_data1    = '{"string":"split me"}';

# data set 2
my $split_data3     = '{"odd":["1","3","5","7","9"],"even":["2","4","6","8"]}';
my $split_data4     = '{"even":["2","4","6","8"],"odd":["1","3","5","7","9"]}';
my $joined_data2    = '{"string":"123456789"}';

# bad data
my $bad_joined_data = '{"nope":"split me"}';
my $bad_split_data1 = '{"xxx":["s","l","t","m"],"even":["p","i"," ","e"]}';


my ($result, $response, $result1, $result2);

# /join - dataset 1 - valid user/pass
$result  = post_join("valid1", "password1",  $split_data1)->{content};
ok( $result eq $joined_data1, "/join - dataset 1 - valid user/pass");

# /join - dataset 2 - valid user/pass
$result  = post_join("valid1", "password1",  $split_data3)->{content};
ok( $result eq $joined_data2, "/join - dataset 2 - valid user/pass");

# /split - dataset 1 - valid user/pass
my $lastsplit = post_split("valid1", "password1", $joined_data1)->{content};
ok ($lastsplit  eq $split_data1 || $lastsplit eq $split_data2, "/split - dataset 1 -valid user/pass");

# /split - dataset 2 - valid user/pass
$lastsplit = post_split("valid1", "password1", $joined_data2)->{content};
ok ($lastsplit  eq $split_data3 || $lastsplit eq $split_data4, "/split - dataset 2 - valid user/pass");

# setup for lastResponse
$result1  = post_join("valid1", "password1",  $split_data1)->{content};
$result2  = post_join("valid2", "password2",  $split_data1)->{content};

# /lastResponse - check content match for valid1/password1
$response = lastResponse("valid1", "password1")->{content};
ok( $response eq $result1, "/lastResponse - check content match for user");

# /lastResponse - check content match for valid2/password2
$response = lastResponse("valid2", "password2")->{content};
ok( $response eq $result2, "/lastResponse - check content match for user");

# 404 - bad url - valid user/pass
$response = post_data("", "valid1", "password1", "", "http://localhost/crazy/url")->{response};
ok( $response eq "404", "404 - bad url - valid user/pass");

# 404 - / - valid user/pass
$response = post_data("", "valid1", "password1", "", "http://localhost")->{response};
ok( $response eq "404", "404 - / - valid user/pass");

# 422 - /split - using bad parameters
$response = post_split("valid1", "password1", $bad_joined_data)->{response};
ok( $response eq "422", "422 /split -  using bad parameters");

# 422- /join - using bad parameters
$response = post_join("valid1", "password1", $bad_split_data1)->{response};
ok( $response eq "422", "422 - /join - using bad parameters");

# 200 - /lastResponse - valid user/pass
$response = lastResponse("valid1", "password1")->{response};
ok( $response eq "200", "200 - /lastResponse - valid user/pass");

# 403 - /join - bad sha1
$response = post_data("join", "valid1", "password1", $split_data1, undef, "fakesha1")->{response};
ok( $response eq "403", "403 - /join - bad sha1 - valid user/pass");

# 401 - /join - invalid user/pass
$response  = post_join("invalid", "invalid",  $split_data1)->{response};
ok( $response eq "401", "401 /join invalid user/pass");

# 401 - /split - invalid user/pass
$response = post_split("invalid", "invalid", $joined_data1)->{response};
ok( $response eq "401", "401 /split invalid user/pass");
