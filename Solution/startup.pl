# set the lib path
use lib qw(/Solution);
use Cache::Memcached::Fast;

$GLOBAL::memd = new Cache::Memcached::Fast { 'servers' => [ "127.0.0.1:11211"],
                                             'debug'              => 1,
                                             'compress_threshold' => 10_000 };


1;
