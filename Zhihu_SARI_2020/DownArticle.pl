=info
    Author: 523066680
=cut

use utf8;
use Modern::Perl;
use Encode;
use Mojo::UserAgent;
use Mojo::DOM;
use File::Slurp;
use File::Path;
use Date::Format;
use Time::HiRes qw/sleep/;
use Try::Tiny;
STDOUT->autoflush(1);

our $prefix = exists $ENV{'HOME'} ? $ENV{'HOME'} : "D:";

our $wdir = $prefix ."/temp/zhihu_pages";
our $url = "https://zhuanlan.zhihu.com/p/103691078";
our $ua = Mojo::UserAgent->new();
our @headers = (
        'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:71.0) Gecko/20100101 Firefox/71.0',
        'Connection' => 'keep-alive',
    );

mkpath($wdir) unless -e $wdir;
chdir $wdir or die "$!";
get_page( $ua );

sub get_page
{
    my ( $ua ) = @_;
    my $file;
    my $res;

    while (1)
    {
        $file = time2str("%m-%d %H_%M_%S.html", time);
        $res = try_to_get($ua, $url, \@headers ) ;
        if ( $res and $res->is_success() ) {
            printf "Save to %s\n", $file;
            write_file( $file, {binmode=>":raw"}, $res->body );
        } else {
            printf "false\n";
        }

        for ( 1 .. 10 ) { print "."; sleep 60.0; }
        print "\n";
    }
}

sub try_to_get
{
    my ($ua, $link, $headers, $args) = @_;
    my $res;
    my $times = 0;
    while ( $times <= 5 )
    {
        try { $res = $ua->get( $link, $headers )->result; }
        catch
        {
            $_=~s/at .*$//s;
            printf "%s Retry: %d\n", $_, $times;
        };
        $times++;
        last if (defined $res and $res->is_success() );
    }
    return $res;
}

sub gbk { encode('gbk', $_[0]) }
sub u2gbk { encode('gbk', decode('utf8', $_[0])) }