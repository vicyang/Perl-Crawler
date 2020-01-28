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
STDOUT->autoflush(1);

exit unless exists $ENV{'HOME'};

our $wdir = $ENV{'HOME'} ."/temp/zhihu_pages";
our $url = "https://zhuanlan.zhihu.com/p/103691078";
our $ua = Mojo::UserAgent->new();

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
        $res = $ua->get( $url )->result;
        if ( $res->is_success ) {
            printf "Save to %s\n", $file;
            write_file( $file, {binmode=>":raw"}, $res->body );
        } else {
            printf "false\n";
        }

        for ( 1 .. 10 ) { print "."; sleep 60.0; }
        print "\n";
    }

    #say u2gbk($res->body());
}

sub gbk { encode('gbk', $_[0]) }
sub u2gbk { encode('gbk', decode('utf8', $_[0])) }