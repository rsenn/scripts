# PP 991121 : this is Tom Zerucha's pgm  t2tgrtest 

# 981016 Added generic &#NN; , split("" v.s. delete, nonest fix
# 980204 Returns 1 if no tables have been rendered
# 980123 fixed graphic vrule cr problem
# 971125 Fixed unterminated table, added some local vars
# 970404 rowspan fixes and cleanup
# spreads rowspan out evenly (not based on other cell height)
# valign still not handled

#look for CONFIGURE for changable parameters
#
#command line usage
#
#t2t [- options...]
#
#options: (see below at BEGIN for explanation)
#
#nonest     use references instead of nesting
#graphic    use line drawing chars instead of |+-
#rowlines   add interrow lines
#vertstack  stack nested tables vertically (experimental)
#nonesid    omit nested sides for a thinner image (experimental)
#nosides    omit sides for a thinner image (experimental)
#maxwid=NNN try to wrap text in columns wider than this
#extlines   also render text outside of tables
#isolate=NN only print the Nth table
#denest=N   ignore N outside levels of tables
#datarows   only print rows with some text

####################
#This is to expand for integration into something like lynx
#The return value is the amount of spaces the markup takes
function vislength(str) {
  return length(str);
}

####################
#append string to image with alignment and space padding
function alimg( span, col, row,       cnt1, wid ) {
  wid = span - 1 - vislength(imline);
  cnt1 = 0;
  while( cnt1 < span )
    wid += colwid[tnst,col+cnt1++];
  if( !wid )
    image[iline] = image[iline] imline vrule;
  else if( substr(align[tnst,row,col],0,6) == "CENTER" ) {
    if( wid  % 2 ) {
      imline = imline " ";
      wid--;
    }
    wid = wid / 2;
    image[iline] = image[iline] substr( spaces, 0, wid ) imline substr( spaces, 0, wid ) vrule;
  }
  else if( substr(align[tnst,row,col],0,5) == "RIGHT" )
    image[iline] = image[iline] substr( spaces, 0, wid ) imline vrule;
  else
    image[iline] = image[iline] imline substr( spaces, 0, wid ) vrule;
}

####################
#write out line characters
function dohline( cl , cm, cr, rfl, row,        cnt,tcs1,col,cnt1 ) {

  col = 1;
  if( !rowlines || rsp[tnst,row,1] < 1 || iline == 0 )
    image[iline] = cl;
  else
    image[iline] = vrule;

  cnt = 0;
  while( col < mxcol ) {
    if( cnt || !rowlines || !rfl || rsp[tnst,row,col] < 1 || iline == 0 ) {
      image[iline] = image[iline] substr( hrule , 0, colwid[tnst,col] );
# corrects line image for colspans in row (top or bottom, not all middle)
      if( cnt ) {
	cnt--;
	image[iline] = image[iline] hrule1;
      }
      else if( tcs[tnst,row,col] <= 1 )
	image[iline] = image[iline] cm;
      else {
	cnt = tcs[tnst,row,col] - 2;
	image[iline] = image[iline] hrule1;
      }
      delete rsp[tnst,row-1,col];
      col++;
    }
    else {
      len = -1;
      cnt1 = rsp[tnst,row-1,col] + 1;
      while( cnt1 )
	len += rowhght[tnst, row - cnt1-- + 1] + rowlines;
      imline = ttext[tnst , row - rsp[tnst,row-1,col] , col , len ];
      delete ttext[tnst , row - rsp[tnst,row-1,col] , col , len ];

      tcs1 = tcs[tnst,row - rsp[tnst,row-1,col],col];
      delete rsp[tnst,row-1,col];
#compare below
      if( !tcs1 )
	tcs1++;
      alimg(tcs1,col, row);
      col += tcs1;
    }
  }
  image[iline] = image[iline] substr( hrule , 0, colwid[tnst,col] ) cr;

  if( graphic ) {
    gsub( "[^" hrule1 "]" cm , "&" cl , image[iline] );
    gsub( cm cl , cl , image[iline] );
    gsub( cm "[^" hrule1 "]" , cr "&" , image[iline] );
    gsub( cr cm , cr , image[iline] );
    gsub( cl "[^" hrule1 "]" , cl "&" , image[iline] );
    gsub( cl cl , vrule , image[iline] );
    gsub( vrule hrule1 , cl hrule1 , image[iline] );
    gsub( vrule cr , vrule , image[iline] );
  }

  if( !sides ) #strip sidebars?
    image[iline] = substr( image[iline] , 2 , length( image[iline] ) - 2 );

  iline++;
}

####################
#print a table into the image
function printtab(        tcs1,col,row,cnt)  {

  sides = 1; #all
  if( nonesid )
    sides = ( tnst == 1 ); #nonesided
  else if( nosides )
    sides = 0; #never

  while( !colwid[tnst,mxcol] && mxcol > 0 )
    mxcol--;

  row = 1;
  iline = 0;
  if( !tcs[tnst,1,1] ) #short or blank row
    tcs[tnst,1,1] = mxcol;
#top line
  dohline( boxtl , boxt , boxtr , 1, row);
#data rows
  while( row < crow ) {
#lines in row (valign not handled yet)
    hght = 0;
    while( hght < rowhght[tnst,row] ) {
      image[iline] = vrule;
#each col in line
      col = 1;
      while( col <= mxcol ) {
	if( rsp[tnst,row-1,col] > 0 ) {
	  len = 0;
	  cnt = rsp[tnst,row-1,col];
	  while( cnt )
	    len += rowhght[tnst, row - cnt--] + rowlines;
	  imline = ttext[tnst , row - rsp[tnst,row-1,col] , col , hght + len ];
	  delete ttext[tnst , row - rsp[tnst,row-1,col] , col , hght + len ];
	  tcs1 = tcs[tnst,row - rsp[tnst,row-1,col],col];
	  if( !rowlines && hght+1 == rowhght[tnst,row] )
	    delete rsp[tnst,row-1,col];
	}
	else {
	  imline = ttext[tnst,row,col,hght];
	  delete ttext[tnst,row,col,hght];
	  tcs1 = tcs[tnst,row,col];
	  if( !tcs1 ) #short or blank row
	    tcs1 = mxcol - col + 1;
	}
	if( !tcs1 )
	  tcs1++;
	alimg(tcs1,col,row);
	col += tcs1;
      }
      hght++;
      if( !sides ) { #strip sidebars?
	image[iline] = substr( image[iline] , 2 , length(image[iline]) - 2 );
	sub(" $" , vrule , image[iline]);
	sub("^ " , vrule , image[iline]);
      }
      iline++;
    }
#bottom or interrow line
    if( row + 1 == crow )
      dohline( boxbl , boxb , boxbr , 0, row);
    else if( rowlines )
      dohline( boxlf , cross , boxrt , 1, row);
    row++;
  }

  iline--;
  row = 1;
  while( row < crow )
    delete rowhght[tnst,row++];
  col = 0;
  while( col <= mxcol )
    delete colwid[tnst,col++];

  delete colwid[tnst];
  delete rowhght[tnst];
  delete tcs[tnst];
  delete rsp[tnst];

}

####################
#remove quotes around strings, i.e. "123" becomes 123
function stripit( pval ) {
  if( substr(pval,0,1) == "\"" ) {
    pval = substr(pval,2,length(pval)-1);
    if( match( pval , "\"" ) )
      pval = substr(pval,0,RSTART-1);
  }
  else if( match(pval," ") )
    pval = substr(pval,0,RSTART-1);
  gsub( "\>" , "", pval );
  return pval;
}

####################
#begin table data or header entry
function startentry(        col1) {
#missing </td>
  if( tdflag )
    endentry();

  ccol++;
  csp = 1;

  while( rsp[tnst,crow-1,ccol] >= 1 )
    ccol++;

#grab alignment
  align[tnst,crow,ccol] = defalign[tnst];
  valign[tnst,crow,ccol] = defvalign[tnst];
  if( substr(toupper($1)" ",0,3) == "TH " )
    align[tnst,crow,ccol] = "CENTER";
  if( match(toupper($1), " ALIGN=") )
    align[tnst,crow,ccol] = toupper(substr($1,RSTART+7,6));
  if( match(toupper($1), " VALIGN=") )
    valign[tnst,crow,ccol] = toupper(substr($1,RSTART+8,6));

#grab colspan
  if( match(toupper($1), "COLSPAN=") )
    csp = int(stripit(substr($1,RSTART+8,5)));

#grab rowspan;
  rowsp = 1;
  if( match(toupper($1), "ROWSPAN=") )
    rowsp = int(stripit(substr($1,RSTART+8,5)));
  rowspan[ccol] = rowsp;
  while( rowsp ) {
    rowsp--;
    col1 = csp;
    tcs[tnst,crow+rowsp,ccol] = col1;
    while( col1-- )
      rsp[tnst,crow+rowsp-1,ccol+col1] = rowsp;
    ttext[tnst,crow+rowsp,ccol,0] = "";
  }
  linet = 0;
  tdflag = 1;
}

####################
#correct column widths for longest text
function fixcolsp(        col1) {
  if( vertstack ) {
    if( col > colwid[tnst,ccol] )
      colwid[tnst,ccol] = col;
  }
  else {
    if( !csp )
      csp = 1;

    col1 = 0;
    while( col1 < csp ) {
      if( !colwid[tnst,ccol+col1] )
	colwid[tnst,ccol+col1] = 1;
      col -= colwid[tnst,ccol+col1];
      col1++;
    }
    if( col > 0 ) {
      col = int( ( col + csp - 1 ) / csp ) ;
      col1 = 0;
      while( col1 < csp ) {
	colwid[tnst,ccol+col1] += col;
	col1++;
      }
    }
  }
}

####################
#remove spaces on either side
function stripsd (str) {
  while( sub(" $","",str));
  while( sub("^ ","",str));
  return(str);
}

####################
#end table data or header entry
function endentry(        lx, lastcol) {

  if( colwid[tnst,ccol] == 0 )
    colwid[tnst,ccol] = 1;

  lastcol = 0;
  lx = 0;
  while( lx <= linet ) {
#trim edge spaces
    imline = stripsd(ttext[tnst,crow,ccol,lx]);
    col = vislength( imline );
    if( !col ) {
      imline = imline " ";
      col = 1;
    }
    else
      rowdata=1;
    ttext[tnst,crow,ccol,lx] = imline;

#debug
#print tnst " row:" crow " col:" ccol " line:" lx " len:" col \
#  " cs:" tcs[tnst,crow,ccol] "=" csp,rsp[tnst,crow,ccol] " >" \
#  ttext[tnst,crow,ccol,lx] "<";

    if( col > lastcol ) {
      fixcolsp();
      lastcol = col;
    }
    lx++;
  }
#remove trailing blank lines
  while( lx > 1 && ttext[tnst,crow,ccol,lx-1] == " " )
    lx--;

  rowsp = rowspan[ccol];
  if( rowsp > 1 )
    lx = int( (lx + rowsp) / rowsp); #+rowsp-1

  while( rowsp-- )
    if( lx > rowhght[tnst,crow+rowsp] )
	rowhght[tnst,crow+rowsp] = lx - (rowsp && rowlines);

  while( csp > 1 ) {
    rowspan[ccol+1] = rowspan[ccol];
    tcs[tnst,crow,++ccol] = 0;
    csp--;
  }

  tdflag = 0;
  linet = 0;
  tralready = 0;
}

####################
#normalize structures in cases of omitted </td> or two few entries
function endrow () {
  if( tdflag )
    endentry();
  if( ccol > mxcol )
    mxcol = ccol;
  ccol = 0;
  if( !datarows || rowdata )
    crow++;
  if( !rowhght[tnst,crow] )
    rowhght[tnst,crow] = 1;
  linet = 0;
  tralready = 1;
}

####################
#begin table data row
function startrow () {
#omitted </tr>
  if( tdflag || !tralready )
    endrow();
  tralready = 0;
#valign?
  defalign[tnst] = "default";
  defvalign[tnst] = "default";
  if( match(toupper($1), " ALIGN=") )
    defalign[tnst] = toupper(substr($1,RSTART+7,6));
  if( match(toupper($1), " VALIGN=") )
    defvalign[tnst] = toupper(substr($1,RSTART+8,6));
  if( !rowhght[tnst,crow] )
    rowhght[tnst,crow] = 1;
  tcs[tnst,crow,1] = 0;
  rowdata=0;
}

####################
# print text outside tables
function doxline() {
  inrow = 0;
  while( inrow <= linet ) {
    imline = stripsd(ttext[0,1,0,inrow++]);
    if( length(imline) )
      print imline;
  }
  split("", ttext);
  linet = 0;
}

####################
function resetvars() {
  linet = 0;  crow = 1;  ccol = 0;
  mxcol = 1;  csp = 1;  tdflag = 0;
}

####################
function fillstr(str) {
  str = str str str str; #4
  str = str str str str; #16
  str = str str str str; #64
  str = str str str str; #256
  return str;
}

####################
function endtable() {
  if( !tralready )
    endrow();
  tralready = 0;
#generate image
  printtab();
  tnst--;
  tdflag = tdf[tnst];      linet = line[tnst];      crow = currow[tnst];
  ccol = curcol[tnst];      mxcol = maxcol[tnst];      csp = colsp[tnst];

#go past a nonblank line      
  imline = stripsd(ttext[tnst,crow,ccol,linet]);
  ttext[tnst,crow,ccol,linet] = imline;
  if( length( imline ) )
    linet++;
#print or copy the rendered subtable
  inrow = 0;
  if( nonest || tnst <= denest ) {
    if( !isolate || isolate == curtbl[tnst] ) {
      while( inrow <= iline )
	print image[inrow++];
      if( nonest )
	print "TABLE " tnst + 1 "." curtbl[tnst] "\n";
    }
    if( !nonest )
      linet = 0;
    system("");
    exitflag = 0;
  }
  else {
    while( inrow <= iline ) {
      ttext[tnst,crow,ccol,linet+inrow] = image[inrow];
      inrow++;
    }
    col = vislength( image[inrow-1] );
    csp = tcs[tnst,crow,ccol];
    fixcolsp();
    linet += inrow;
    if( linet > rowhght[tnst,crow] )
      rowhght[tnst,crow] = linet;
  }
  inrow = 0;
  if( tnst > denest && ( vertstack || !tdflag ) ) {
    endentry();
    endrow();
  }
}

####################
#main

#set some variables
BEGIN { 
  RS = "\<" ; 
  FS = "\>" ; 

  exitflag = 1;

  tnst = 0;
  tralready = 0;
  denest = 0;
  isolate = 0;
  resetvars();
  rowdata=0;
  datarows=0;

#csp=1

#CONFIGURE
  nonest = 0;

#CONFIGURE
#sides (vertical)
#default  nonesid nosides
#+------+ +----+ ----
#|+---+ | |--- | ---
#||A|B|C| |A|BC| A|BC
#|+---+ | |--- | ---
#+------+ +----+ ----
  nonesid = 0;
  nosides = 0;
#CONFIGURE - set to 1 for lines between rows
  rowlines = 0;
#CONFIGURE - set to 1 for lines outside of tables
  extlines = 0;
#CONFIGURE - set to 1 to stack all tables vertically
  vertstack = 0;
#CONFIGURE
# Ascii boxes
  boxtl = "+"; boxt = "+"; boxtr = "+"; boxbl = "+"; boxb = "+"; boxbr = "+";
  vrule = "|"; hrule = "-"; cross = "+"; boxlf = "+"; boxrt = "+";

#CONFIGURE
#split if column would be wider than
  maxwid = 80;
#split at the first space after backing up
  splitat = 10;

  while( ARGC ) {
    if( match( ARGV[ARGC] , "graphic" ) ) {
# PC Graphics characters (single);
      boxtl = "\332";  boxt = "\302";  boxtr = "\277";
      boxbl = "\300";  boxb = "\301";  boxbr = "\331";
      vrule = "\263";  hrule = "\304";
      boxlf = "\303";  boxrt = "\264"; cross = "\305";
      graphic = 1;
    }
    else if( match( ARGV[ARGC] , "vertstack" ) )
      vertstack = 1;
    else if( match( ARGV[ARGC] , "maxwid=" ) )
      maxwid = int( substr( ARGV[ARGC], RSTART + 7 , 3 ));
    else if( match( ARGV[ARGC] , "denest=" ) )
      denest = int( substr( ARGV[ARGC], RSTART + 7 , 3 ));
    else if( match( ARGV[ARGC] , "isolate=" ) )
      isolate = int( substr( ARGV[ARGC], RSTART + 8 , 3 ));
    else if( match( ARGV[ARGC] , "rowlines" ) )
      rowlines = 1;
    else if( match( ARGV[ARGC] , "nonesid" ) )
      nonesid = 1;
    else if( match( ARGV[ARGC] , "nosides" ) )
      nosides = 1;
    else if( match( ARGV[ARGC] , "extlines" ) )
      extlines = 1;
    else if( match( ARGV[ARGC] , "nonest" ) )
      nonest = 1;
    else if( match( ARGV[ARGC] , "datarows" ) )
      datarows = 1;

    ARGC--;
  }

  hrule1 = hrule;

  hrule = fillstr(hrule1);
  spaces = fillstr(" ");
  underl = fillstr("_");
}

#################### MAIN processing
{
#print "a:"tnst","crow","ccol","linet "<" $1 ">" $2 ":" ttext[tnst,crow,ccol,linet] ":";
  imline = toupper($1) " ";

  if( substr(imline,0,6) == "TABLE " ) {

    curtbl[tnst]++;
    if( tnst > denest ) {
      if( !tdflag ) {
	startrow();
	startentry();
      }
      if( nonest )
	ttext[tnst,crow,ccol,linet] = "[Table " tnst+1 "." curtbl[tnst] "]";
    }
#text outside tables
    else if ( extlines )
      doxline();

    system("");

    line[tnst] = linet;    currow[tnst] = crow;    curcol[tnst] = ccol;
    maxcol[tnst] = mxcol;    colsp[tnst] = csp;    tdf[tnst] = tdflag;
    tnst++;
    resetvars();
    rowhght[tnst,1] = 1;
    tralready = 1;
  }

  if( tnst > denest ) {
#begin/end markers
    if( substr(imline,0,3) == "TD " \
	|| substr(imline,0,3) == "TH " )
      startentry();
    else if( substr(imline,0,4) == "/TD " \
	|| substr(imline,0,4) == "/TH " )
      endentry();
    else if( substr(imline,0,3) == "TR " )
      startrow();
    else if( substr(imline,0,4) == "/TR " )
      endrow();
#END OF TABLE
    else if( substr(imline,0,7) == "/TABLE " )
      endtable();
  }
  else if( substr(imline,0,7) == "/TABLE " && tnst )
    tnst--;
  else if( substr(imline,0,6) == "/HTML " )
    tnst = 0;

#something we want to format?
  if( tnst > denest || extlines ) {
#line breaking entries
    if(        imline == "BR " || \
	substr(imline,0,3) == "HR " || \
	substr(imline,0,3) == "LI " || \
	substr(imline,0,2) == "P " || \
	substr(imline,0,7) == "OPTION " || \
	substr(imline,0,8) == "/SELECT " \
	) {

#ignore for blank lines
      imline = stripsd(ttext[tnst,crow,ccol,linet]);
      ttext[tnst,crow,ccol,linet] = imline;
      if( length(imline) ) {
	linet++;
	ttext[tnst,crow,ccol,linet] = "";
      }
    }

#extract ALT string
    if( match(substr(imline,0,4), "IMG ") ) {
      if( match(toupper($1)," ALT")) {
	name = substr($1,RSTART+4,length($1)-7);
	match( name , "=" );
	name = substr(name,RSTART+1,length(name)-1);
	sub(/^ */,"",name);
	if( substr(name,0,1) == "\"" ) {
	  name = substr(name,2,length(name)-1);
	  match(name,"\"");
	  name = substr(name,0,RSTART-1);
	}
	else if( match(name," ") )
	  name = substr(name,0,RSTART-1);
	gsub( "\>" , "", name );
	$2 = " [" name "]" $2;
      }
    }

#indicate options follow
    if( substr(imline,0,7) == "SELECT " )
      $2 = "[select]";

#form input fields
    if( substr(imline,0,6) == "INPUT " ) {
      size = 0;
      if( match(imline, "SIZE=") )
	size = int( stripit( substr($1 , RSTART + 5 , 64) ) );
      value = "*";
      if( match(imline, "VALUE=") )
	value = stripit( substr($1 , RSTART + 6 , 256) );
      if( length( value ) < size )
	value = value substr( underl , 0 , size - length(value) );
      if( !match(imline, "TYPE=.?HIDDEN") )
	ttext[tnst,crow,ccol,linet] \
	  = ttext[tnst,crow,ccol,linet] "[" value "]";
    }

#fix character formats - convert specials into something normal
    if( NF > 1 && length($2) ) {
      gsub("\046amp;","\\&",$2);      gsub("\046#169;","(C)",$2);
      gsub("\046#0124;","|",$2);      gsub("\046#0146;","'",$2);
      gsub("\046#146;","'",$2);
      gsub("\046#162;","c",$2);       gsub("\046#160;"," ",$2);
      gsub("\046quot","\"",$2);       gsub("\046copy;","(C)",$2);
      gsub("\046reg;","(R)",$2);      gsub("\046nbsp;"," ",$2);
      gsub("\046nbsp"," ",$2);

      while( match($2,"\046#" ) ) {
	val = substr( $2, RSTART + 2, 10 );
	gsub( ";.*", "", val);
	val = val + 0;
	if( val < 127 && val > 31 )
	  val = sprintf( "%c", val );
	else
	  val = sprintf("[%02x]",val);
	sub("\046#[0-9]*;",val,$2);
      }

      gsub("\n"," ",$2);
      gsub("\r","",$2);      gsub("\t"," ",$2);
      gsub("  *"," ",$2);
      if( !tdflag )
	sub(" $","",$2);
      gsub("\221","`",$2);      gsub("\222","'",$2);
      gsub("\223","(",$2);      gsub("\224",")",$2);
    }

#append line
    if( NF > 1 && length($2) ) {
      if( vertstack && tnst > denest && !ccol )
	ccol++;

      imline = ttext[tnst,crow,ccol,linet] $2;
      ttext[tnst,crow,ccol,linet] = imline;
#Split long lines - not fully operational
      while( length( imline ) > (maxwid / (tnst+1)) * csp ) {
	gsub( "^ ", "", imline );
	temp = 1;
	stspl = maxwid * csp - splitat * temp;
	while( stspl > 0 ) {
	  if( match( substr( imline, stspl , length( imline ) )," ") ) {
	    ttext[tnst,crow,ccol,linet] = substr(imline, 0, stspl + RSTART - 1);
	    ttext[tnst,crow,ccol,linet + 1] = substr(imline, stspl + RSTART - 1, length( imline ) );
	    stspl = -1;
	  }
	  else
	    stspl = maxwid * csp - splitat * ++temp;
	}
	linet++;
	imline = ttext[tnst,crow,ccol,linet];
      }
    }
  }
#print "B:"tnst","crow","ccol","linet "<" $1 ">" $2 ":" ttext[tnst,crow,ccol,linet] ":";
}

END { 
  while( tnst > denest )
    endtable();
  if( extlines )
    doxline();
  exit exitflag;
}
