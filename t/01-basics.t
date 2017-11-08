use strict;
use warnings;
use Coro;
use AnyEvent;
use Coro::Countdown;
use Test2::Bundle::Extended;

subtest 'up/down' => sub {
  ok my $counter = new Coro::Countdown;
  is $counter->count, 0, 'initial count';

  is $counter->up, 1, 'up';
  is $counter->up, 2, 'up';
  is $counter->up, 3, 'up';
  is $counter->count, 3, 'count';

  is $counter->down, 2, 'down';
  is $counter->down, 1, 'down';
  is $counter->down, 0, 'down';
  is $counter->count, 0, 'final count';
};

subtest 'signal' => sub {
  my $counter = new Coro::Countdown;
  $counter->up for 1 .. 3;

  my $cv   = AE::cv;
  my $cons = async { $counter->join; $cv->send('sent') };
  my $prod = async { $counter->down for 1 .. 3; };

  is $cv->recv, 'sent', 'signaled';

  subtest 'reuse' => sub {
    $counter->up for 1 .. 3;
    my $cv   = AE::cv;
    my $cons = async { $counter->join; $cv->send('sent') };
    my $prod = async { $counter->down for 1 .. 3; };
    is $cv->recv, 'sent', 'signaled';
  };
};

done_testing;
