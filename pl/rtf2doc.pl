#! /usr/bin/perl -w 
# Copyright (C) 1999 Avi Kivity

sub usage
{
    print <<__USAGE__;
Usage: rtf2doc.pl FILE...
  Converts one or more MS .rtf FILEs to MS Word .doc files.
  Requires MS Word 97 or above, plus correct phase of moon.
__USAGE__
}

usage(), exit 0 
    if ($#ARGV < 0) || ($ARGV[0] =~ /^((-h)|(--help))$/);

use Cwd;
use Win32::OLE;
use Win32::OLE::Const 'Microsoft Word';

$cwd = cwd();

@storytypes = ( 4, 3, 8, 6, 11, 10, 2, 1, 9, 7, 5 );
my $Word = Win32::OLE->new('Word.Application', 'Quit');
die "Cannot open MS Word\n" unless $Word;

foreach (@ARGV) {
    my $src = $_;
    $src = "$cwd\\$src"
        unless $src =~ /^(.:\\)/;
    my $tgt = "$src.doc";
    my $Doc = $Word->Documents->Open($src);
    die "Cannot open $src\n" unless $Doc;
    $Doc->Repaginate();
    $Stories = $Doc->StoryRanges;
    for $s (@storytypes) {
        eval {            
            local $SIG{__WARN__} = {};    
            $Story = $Stories->Item($s);
            if ($Story) {
                $Story->Fields->Update();
                $Story->Fields->Unlink();
            }
        };
    }
    $Doc->SaveAs($tgt, 0);
    $Doc->Close();
}

$Word->Quit();
