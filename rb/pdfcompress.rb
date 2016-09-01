#!/usr/bin/ruby
require( 'fileutils' )

BASICCONVERTOPTIONS = " -compress Group4"
DELETEIGNOREFILE = false #Automatically delete files which grow in size after recompression?
TMPDIRNAME = "tmpx139toslw"

if ARGV[0] === NIL
    $stderr.puts "Syntax: pdfcompress.rb <PDF file> ( <additional convert options> )"
    exit 1
end

if ARGV[1] === NIL
    convertoptions = BASICCONVERTOPTIONS
else
    convertoptions = ARGV[1] + BASICCONVERTOPTIONS
end

begin
    Dir.mkdir( TMPDIRNAME )
    $stderr.puts "Processing file " + ( file = ARGV[0] ) + "..."
    
    #Convert to individual PDFs
    system( "pdfimages \"" + file +"\" " + File.join( TMPDIRNAME, "images" ) )
    Dir.glob( File.join( TMPDIRNAME, "*" ) ).each { |imagefile|
        $stderr.printf( "\rCompressing " + File.basename( imagefile ) + "..." );
        system( "convert #{convertoptions} \"" + imagefile + "\" \"" + imagefile.sub( /\.[^.]*$/, ".tiff" ) + "\"" )
        system( "tiff2pdf \"" + imagefile.sub( /\.[^.]*$/, ".tiff" ) + "\" -o \"" + imagefile.sub( /\.[^.]*$/, ".pdf" ) +"\"" )
    }
    $stderr.printf( "\n" );
    
    #Put them all together now
    $stderr.printf( "Combining PDF files... " );
    system( "pdftk \"" + Dir.glob( File.join( TMPDIRNAME, "*.pdf" ) ).join( "\" \"" ) + "\" cat output \"" + ( output_filename = File.basename( file ).sub( /#{File.extname( file )}$/, ".2.pdf" ) ) + "\"" )
    $stderr.printf( "Done\n" );
    
    #Compare the sizes
    if( File.size( file ) > File.size( output_filename ) )
        $stdout.puts "Compressed file " + File.basename( file ) + " - Compressed from " + File.size( file ).to_s + " to " + File.size( output_filename ).to_s
    else
        $stdout.puts "Ignored file " + File.basename( file ) + " - Changed from " + File.size( file ).to_s + " to " + File.size( output_filename ).to_s
        File.delete( output_filename ) if DELETEIGNOREFILE
    end
ensure
    #Clean up temp dir
    Dir.glob( File.join( TMPDIRNAME, "*" ) ).each { |delfile| File.delete( delfile ) }
    Dir.delete( TMPDIRNAME );
end

