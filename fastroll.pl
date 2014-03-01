#!/usr/bin/perl

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use LWP::UserAgent;
use LWP::ConnCache;
use HTTP::Request::Common;
use HTTP::Message;
use HTTP::Cookies;
use threads;

# NOTE: Before using, change the my_video string to match your video's ID string
# TODO: Add support for other proxy lists

$hits = 0;
$my_video = "wbk83I2ssnw";

# Country list
@country = ("au", "nz", "ca", "uk", "br", "mx", "jp", "ru");

# User agents
@user_agent = (
   # Misc
   'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.4; en-US; rv:1.9b5) Gecko/2008032619 Firefox/3.0b5',
   'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-GB; rv:1.9.0.5) Gecko/2008120122 Firefox/3.0.5',
   'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:x.xx) Gecko/20030504 Mozilla Firebird/0.6',

   # Internet Explorer 8.0
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET CLR 3.0.04506; Media Center PC 5.0; SLCC1; Tablet PC 2.0)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; WOW64; Trident/4.0; SLCC1; .NET CLR 2.0.50727; Media Center PC 5.0; .NET CLR 1.1.4322; .NET CLR 3.5.21022; InfoPath.2; .NET CLR 3.5.30729; .NET CLR 3.0.30618)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; SLCC1; .NET CLR 2.0.50727; Media Center PC 5.0; InfoPath.1; .NET CLR 3.5.21022; .NET CLR 3.5.30729; .NET CLR 3.0.30618)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; SLCC1; .NET CLR 2.0.50727; Media Center PC 5.0; .NET CLR 3.5.21022; Tablet PC 2.0; .NET CLR 3.5.30729; .NET CLR 3.0.30618)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; SLCC1; .NET CLR 2.0.50727; Media Center PC 5.0; .NET CLR 3.5.21022; .NET CLR 3.5.30729; .NET CLR 3.0.30618; Tablet PC 2.0; .NET CLR 1.1.4322)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; SLCC1; .NET CLR 2.0.50727; Media Center PC 5.0; .NET CLR 3.0.04506; InfoPath.2; FDM)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; SLCC1; .NET CLR 2.0.50727; .NET CLR 3.0.04506; .NET CLR 1.1.4322)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; MathPlayer 2.10d; SLCC1; .NET CLR 2.0.50727; Media Center PC 5.0; .NET CLR 3.0.04506; InfoPath.2; .NET CLR 3.5.21022)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; FunWebProducts; SLCC1; .NET CLR 2.0.50727; Media Center PC 5.0; .NET CLR 3.0.04506; InfoPath.1)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; Tablet PC 1.7; .NET CLR 1.0.3705; .NET CLR 1.1.4322)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; SV1; .NET CLR 2.0.50727; InfoPath.2)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; MathPlayer 2.10d; FDM; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022; .NET CLR 1.1.4322)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; GTB5; .NET CLR 1.1.4322)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; InfoPath.2; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; InfoPath.2; .NET CLR 3.0.04506.30)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022; InfoPath.1; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; InfoPath.2)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)',
   'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30)',

   # Internet Explorer 7.0
   'Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 6.0)',
   'Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 5.2; .NET CLR 1.1.4322; .NET CLR 2.0.50727; InfoPath.2; .NET CLR 3.0.04506.30)',
   'Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 5.1; Media Center PC 3.0; .NET CLR 1.0.3705; .NET CLR 1.1.4322; .NET CLR 2.0.50727; InfoPath.1)',
   'Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 5.1; FDM; .NET CLR 1.1.4322)',
   'Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 5.1; .NET CLR 1.1.4322; InfoPath.1; .NET CLR 2.0.50727)',
   'Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 5.1; .NET CLR 1.1.4322; InfoPath.1)',
   'Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 5.1; .NET CLR 1.1.4322; Alexa Toolbar; .NET CLR 2.0.50727)',
   'Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 5.1; .NET CLR 1.1.4322; Alexa Toolbar)',
   'Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)',
   'Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.40607)',
   'Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 5.1; .NET CLR 1.1.4322)',
   'Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 5.1; .NET CLR 1.0.3705; Media Center PC 3.1; Alexa Toolbar; .NET CLR 1.1.4322; .NET CLR 2.0.50727)',

   # Firefox 3.1.6
   'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.2) Gecko/2008092313 Ubuntu/8.04 (hardy) Firefox/3.1.6',
   'Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.9.0.2) Gecko/2008092313 Firefox/3.1.6',

   # Firefox 3.1
   'Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.0.2) Gecko/2008092313 Ubuntu/8.04 (hardy) Firefox/3.1',
   'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.2) Gecko/2008092313 Ubuntu/8.04 (hardy) Firefox/3.1',
   'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.6pre) Gecko/2009011606 Firefox/3.1',

   # Firefox 3.0.0
   'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.1) Gecko/2008070208 Firefox/3.0.0',
   'Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.0.1) Gecko/2008070208 Firefox/3.0.0',

   # Safari 4.0
   'Mozilla/5.0 (Macintosh; U; PPC Mac OS X 10_4_11; en) AppleWebKit/528.5+ (KHTML, like Gecko) Version/4.0 Safari/528.1',
   'Mozilla/5.0 (Macintosh; U; PPC Mac OS X 10_4_11; en) AppleWebKit/528.4+ (KHTML, like Gecko) Version/4.0 Safari/528.1',
   'Mozilla/5.0 (Macintosh; U; PPC Mac OS X 10_4_11; en) AppleWebKit/528.1 (KHTML, like Gecko) Version/4.0 Safari/528.1',
   'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_6; en-us) AppleWebKit/528.10+ (KHTML, like Gecko) Version/4.0 Safari/528.1',

   # Safari 3.2.2
   'Mozilla/5.0 (Windows; U; Windows NT 6.1; de-DE) AppleWebKit/525.28 (KHTML, like Gecko) Version/3.2.2 Safari/525.28.1',
   'Mozilla/5.0 (Windows; U; Windows NT 5.2; de-DE) AppleWebKit/528+ (KHTML, like Gecko) Version/3.2.2 Safari/525.28.1',
   'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/525.28 (KHTML, like Gecko) Version/3.2.2 Safari/525.28.1',  
);

sub normal_rand {
   my ( $width, $mean ) = @_;
   my $t=0;
   $t+=rand() for(1..5);
   return int($t*$width+$mean);
}

sub LWP::UserAgent::redirect_ok {
   my ($self, $prospective_request, $response) = @_;

   my $location = $response->header("Location");
   if(defined $location && $location =~ /ip=(.*?)\&/) {
      print "Getting Video from IP Address $1\n";
   }

   return 1;
}

sub send_video_request {
   my ($ua, $req) = @_;

   my $bytes_received = 0;
   my $target_bytes = normal_rand(40000,11000);  

   print "Sending Video request, target = $target_bytes\n";
   my $res = $ua->request($req, 
      sub {
         my ($chunk, $res) = @_;
 
         $bytes_received += length($chunk);

         if($bytes_received > $target_bytes) {
            print "Bytes: $bytes_received\n";
	    die();
         }
      }
   );

   return;
}

sub view_thread {
   my ( $url ) = @_;
   my $proxy_url = "http://127.0.0.1:8118/";

   my $cookie_jar = HTTP::Cookies->new(
      file => "cookies.lwp",
   );

   # Create user agent
   print "Creating User Agent\n";
   my $ua = LWP::UserAgent->new;

   # Set headers and user-agent
   my $h = HTTP::Headers->new(
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Accept-Language' => 'en-gb,en;q=0.5',
      'Accept-Charset' => 'SO-8859-1,utf-8;q=0.7,*;q=0.7',
   );
   $ua->default_headers($h);

   $ua->agent($user_agent[rand(scalar(@user_agent))]);

   # Setup keep-alive, cookie jar and the proxy
   $ua->conn_cache(LWP::ConnCache->new());   # Use keep-alive
   $ua->cookie_jar( $cookie_jar );           # Use a cookie-jar
   $ua->proxy('http', $proxy_url);           # Use a proxy

   print "Sending request to $url\n";
   my $req = HTTP::Request->new(GET => $url);
   $req->header('Accept-Encoding' => 'gzip,deflate');
   my $res = $ua->request($req);

   # look for the string with the video_id and t arguments
   if($res->decoded_content !~ /swfArgs = \{(.*)\}/) {
      print "Couldn't find the swfArgs string!\n";
      return;
   }

   # get the video_id and t strings   
   my $swfargs = $1;
   if($swfargs !~ /\"video_id\": \"(.*?)\".*\"t\": \"(.*?)\"/) {
      print "Couldn't get the video_id or t strings\n";
      return;
   }

   my $video_id = $1;
   my $tstr = $2;
   print "video id: $video_id, t: $tstr\n";

   # Create video request
   $req = HTTP::Request->new(GET => "http://www.youtube.com/get_video?video_id=$video_id&t=$tstr&el=detailpage&ps=&fmt=5");

   send_video_request($ua, $req);
}

while(1) {
   # Spawn a new thread every random number of seconds
   $thr = threads->new(\&view_thread, "http://" . $country[rand(scalar(@country))] . ".youtube.com/watch?v=" . $my_video);

   my $rt = 2;

   print "Sleeping for $rt seconds before spawning a new thread\n";
   sleep($rt);

   # Don't have any more than 10 threads at a time
   while(scalar threads->list(threads::running) > 10) {
      sleep(10);
   }

   # Join any threads that have finished
   foreach $thr (threads->list(threads::joinable)) {
     $thr->join();
     $hits++;
     print "-----> Hits = $hits\n";
   }
}
