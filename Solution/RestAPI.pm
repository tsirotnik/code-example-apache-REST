package Solution::RestAPI;

use FindBin;
use lib $FindBin::Bin;

use Apache2::Access ();
use Apache2::Const qw(:common);
use Apache2::RequestRec();
use Data::Dumper;
use Digest::SHA qw(sha1_hex);
use JSON;
use List::Util qw(max);
use Solution::Client;
use TryCatch;
use base 'CGI::Application';
use strictures 2;

# -----------------------------------------------
# CGI::Application setup
# -----------------------------------------------

sub setup {
    my $self = shift;

    # sets default as the start mode
    $self->start_mode('default');
    $self->mode_param('rm');
    $self->run_modes(
        'default'      => 'invalid',  # set default url to 404
        'invalid'      => 'invalid',  # set invalid urls to 404
        'join'         => 'join',
        'lastResponse' => 'lastResponse',
        'split'        => 'split',
        );
}

# -----------------------------------------------
# run modes
# -----------------------------------------------

sub invalid
{
    my $self = shift;
    $self->header_add( -status => '404');
}


sub split
{
    my $self = shift;
    my $err;

    try
    {
        die "invalid sha1" if (! $self->sha1_ok());
        die "invalid auth" if (! $self->auth_ok());

        my $query = $self->query();
        my @data = $query->multi_param("POSTDATA");

        my $json;
        try  { $json = decode_json($data[0]) } catch { die "invalid parameters"};

        #validate json
        die "invalid parameters" if (! exists $json->{string} || scalar keys %$json > 1);

        $self->header_add( -type => "application/json");
        my ($odd, $even) = $self->split_string($json->{string});
        my $retval = encode_json ({"odd" => $odd, "even" => $even});
        $self->memcache($retval);
        return $retval;
    }
    catch($err where {$_ =~ "invalid sha1"} )       { $self->invalid_sha1() }
    catch($err where {$_ =~ "invalid parameters"})  { $self->invalid_parameters() }
    catch($err where {$_ =~ "invalid auth"})        { $self->invalid_auth() }
    catch($err)                                     { $self->server_error() };

}


sub join
{
    my $self = shift;

    try
    {
        # verify the sha1 and auth
        die "invalid sha1" if (! $self->sha1_ok());
        die "invalid auth" if (! $self->auth_ok());

        my $query = $self->query();
        my @data = $query->multi_param("POSTDATA");

        # check if json can be decoded
        my $json;
        try  { $json = decode_json($data[0]) } catch { die "invalid parameters"};

        #validate json
        die "invalid parameters" if (! exists $json->{odd} || ! exists $json->{even} || scalar keys %$json > 2);

        $self->header_add(-type => "application/json");
        my $retval = encode_json({"string" => $self->join_arrays($json->{odd}, $json->{even})});
        $self->memcache($retval);
        return $retval;
    }
    catch($err where {$_ =~ "invalid sha1"} )      { $self->invalid_sha1() }
    catch($err where {$_ =~ "invalid parameters"}) { $self->invalid_parameters() }
    catch($err where {$_ =~ "invalid auth"})       { $self->invalid_auth()}
    catch($err)                                    { $self->server_error()}
}


sub lastResponse
{
    my $self = shift;

    try
    {
        die "invalid auth" if (! $self->auth_ok());
        $self->header_add(-type => "application/json");
        my $last_response = $self->memcache();
        return $last_response;
    }
    catch($err where {$_ =~ "invalid auth"}) { $self->invalid_auth()}
    catch($err)                              { $self->server_error()}
}

# -----------------------------------------------
# Authentication
# -----------------------------------------------

sub auth_ok
{
    # do basic auth here
    my $self  = shift;
    my $query = $self->query();
    my $r     = $self->param('r');

    # this is the way to get the user and password
    # passed in through basic auth
    my ($res, $password) = $r->get_basic_auth_pw();
    my $username = $r->user();

    # using memcached to store and return last requested
    # the username + password combination will be unique key for debug purposes
    # IT IS UNSAFE TO STORE PASSWORD INFORMATION LIKE THIS
    # tbd - change to hash of username + password
    $self->{memd_key} = "$username.$password";

    return 0 if $username =~ /^\s*$/;
    return 0 if $password =~ /^\s*$/;

    return 0 if (! $self->interview_api_ok($username, $password));

    return 1;
}

sub interview_api_ok
{
    my ($self, $username, $password) = @_;
    my $client = Client->new(host=>"https://interview-api.example.com");
    my ($response_code, $content) = $client->GET("/auth?username=$username&password=$password");
    return 1 if ($response_code eq "200");
    return 0;
}

sub sha1_ok
{
    # verify that that sha is correct
    my $self = shift;
    my $query = $self->query();
    my $r = $self->param('r');

    # ugh! messy way to get the signature sha
    $r->args() =~ /signature=(.*)/;
    my $signature_sha1 = $1;

    my @data = $query->multi_param("POSTDATA");
    my $data_sha1 = sha1_hex($data[0]);

    return 0 if ($signature_sha1 ne $data_sha1);

    return 1;
}

# -----------------------------------------------
# memcache
# -----------------------------------------------

sub memcache
{
    my $self = shift;
    my $value = shift;

    if ( ! defined $value)
    {
        my $response = $GLOBAL::memd->get($self->{memd_key});
        return $GLOBAL::memd->get($self->{memd_key});
    }
    else
    {
        $GLOBAL::memd->set($self->{memd_key}, $value);
        return $GLOBAL::memd->get($self->{memd_key});
    }
}


# -----------------------------------------------
# helper methods for run modes
# -----------------------------------------------


sub split_string
{
    my ($self, $string) = @_;
    my @list = split("", $string);

    my (@odd, @even);

    for (my $idx=0; $idx< scalar(@list); $idx +=2)
    {
        push(@odd, $list[$idx]);
    }

    for (my $idx=1; $idx< scalar(@list); $idx +=2)
    {
        push(@even, $list[$idx]);
    }

    return (\@odd, \@even);
}


sub join_arrays
{
    my ($self, $odd, $even)  = @_;
    my $max = max(scalar @$odd, scalar @$even);

    my $joined = "";
    for (my $idx =0; $idx < $max; $idx++)
    {
        $joined .= shift @$odd if (@$odd);
        $joined .= shift @$even if (@$even);
    }
    return $joined;

}


# -----------------------------------------------
# invalid responses
# -----------------------------------------------


sub invalid_auth
{
    my $self = shift;
    $self->header_add( -status => '401');
}

sub invalid_parameters
{
    my $self = shift;
    $self->header_add( -status => '422');
}

sub invalid_sha1
{
    my $self = shift;
    $self->header_add( -status => '403');
}

sub server_error
{
    my $self = shift;
    $self->header_add( -status => '500');
}

1;
