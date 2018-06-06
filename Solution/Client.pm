package Client;

use Carp qw(cluck confess);
use Data::Dumper;
use JSON;
use Moo;
use REST::Client;
use TryCatch;
use autodie;
use strictures 2;

has "host" => (is => "ro");
has "client" => (is => 'ro', writer=> "_set_client");

sub BUILD
{
    my ($self, $args) = @_;
    $self->_set_client(REST::Client->new({
        host    => $self->host,
        timeout => 10}));
}


sub GET
{
    my ($self, $url) = @_;

    try
    {
        $self->client->GET($url);
        my $response_code = $self->client->responseCode();
        #not needed
        # my $content = decode_json($self->client->responseContent());
        return $response_code;
    }
    catch(my $err)
    {
        cluck("GET error: : $err ");
    };
}

sub POST
{
    my ($self, $url, $json) = @_;

    try
    {
        $self->client->POST($url, encode_json($json));
        my $response_code = $self->client->responseCode();
        # not needed
        #my $content = decode_json($self->client->responseContent());
        return $response_code;

    }
    catch(my $err)
    {
        cluck("POST error: $err ");
    };
}

1;
