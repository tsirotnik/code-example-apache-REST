package Solution::Dispatch;

use FindBin;
use lib $FindBin::Bin;

use Apache2::Access ();
use base 'CGI::Application::Dispatch';


sub dispatch_path {
    # overloads base class dispath_path

    # this ensures that all urls other than:
    #     /split
    #     /join
    #     /lastResponse
    # are rewritten as "invalid" ensuring that the dispatch table ( below )
    # with send them to the correct run mode so the can get a 404
    # unspecified in spec what the should get so assume 404

    my $self = shift;
    my $path = $self->SUPER::dispatch_path();
    if ($path !~ /^\/split$/ && $path !~ /^\/join$/ && $path !~ /^\/lastResponse$/)
    {
        return "invalid";
    }
    else
    {
        return $path;
    }

}


sub dispatch_args {
    # dispatch table for incoming urls
    # note:  it's sending inappropriate request types ex: GET request for /join url
    #        to the invalid run mode so the can get a 404
    #        unspecified in spec what they should get so assume 404

    return {
        prefix  => '',
        debug => 1,
        table   => [
            '/'                 => {app => "Solution::RestAPI", rm=>"default"},
            'invalid'           => {app => "Solution::RestAPI", rm=>"invalid"},
            'join/[GET]'        => {app => "Solution::RestAPI", rm=>"invalid"},
            'join/[POST]'       => {app => "Solution::RestAPI", rm=>"join"},
            'lastResponse[GET]' => {app => "Solution::RestAPI", rm=>"lastResponse"},
            'lastResponse[POST]'=> {app => "Solution::RestAPI", rm=>"invalid"},
            'split/[GET]'       => {app => "Solution::RestAPI", rm=>"invalid"},
            'split/[POST]'      => {app => "Solution::RestAPI", rm=>"split"},

            ],
    };
}


1;
