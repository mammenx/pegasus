#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long;

  #Internal Variables
  my  $polyWidth  = undef;
  my  $polyHex    = undef;
  my  $dataWidth  = undef;

  #Function to display help
  sub disp_help {
    print "usage -> perl crc_gen.pl -polyWidth <> -polyHex <> -dataWidth <>\n";
    print "\t-polyWidth   - Width of the polynomial\n";
    print "\t-polyHex     - Value of the polynomial in hexadecimal\n";
    print "\t-dataWidth   - Width of data bus\n";
  }


  #Function to print module head
  sub gen_mod_head  {
    my  ($mod_name,$polyWidth,$polyVal,$dataWidth,$fHandle)  = @_;

    print $fHandle  "//${polyWidth}b CRC generation block with ${dataWidth}b parallel data using poly $polyVal\n";
    print $fHandle  "module $mod_name #(\n";
    print $fHandle  "  parameter  POLY_W       = $polyWidth,\n";
    print $fHandle  "  parameter  DATA_W       = $dataWidth,\n";
    print $fHandle  "  parameter  CRC_INIT_VAL = 0\n";
    print $fHandle  ") (\n";
    print $fHandle  "  input                    clk,\n";
    print $fHandle  "  input                    rst_n,\n\n";
    print $fHandle  "  input                    init_crc,\n\n";
    print $fHandle  "  input                    data_valid,\n";
    print $fHandle  "  input      [DATA_W-1:0]  data,\n\n";
    print $fHandle  "  output reg [POLY_W-1:0]  crc\n";
    print $fHandle  ");\n\n\n";
    print $fHandle  "  always@(posedge clk, negedge rst_n)\n";
    print $fHandle  "  begin\n";
    print $fHandle  "    if(~rst_n)\n";
    print $fHandle  "    begin\n";
    print $fHandle  "      crc         <=  CRC_INIT_VAL;\n";
    print $fHandle  "    end\n";
    print $fHandle  "    else\n";
    print $fHandle  "    begin\n";
    print $fHandle  "      if(init_crc)\n";
    print $fHandle  "      begin\n";
    print $fHandle  "        crc       <=  CRC_INIT_VAL;\n";
    print $fHandle  "      end\n";
    print $fHandle  "      else if(data_valid)\n";
    print $fHandle  "      begin\n";

  }

  #This function calculates CRC by shifting a single bit
  sub div_data1 {
    my  ($width,$crcArr_ref,$polyBitArr_ref,$bit) = @_;

    my  @resArr = ();

    if($$polyBitArr_ref[0]  eq  "1")  {
      $resArr[0]  = sprintf("%s ^ %s",$$crcArr_ref[$width-1],$bit);
    } else  {
      $resArr[0]  = "";
    }

    for(my  $idx=1; $idx<$width;  $idx++) {
      if($$polyBitArr_ref[$idx]  eq  "1")  {
        $resArr[$idx]  = sprintf("%s ^ %s ^ %s",$$crcArr_ref[$idx-1],$$crcArr_ref[$width-1],$bit);
      } else  {
        $resArr[$idx]  = sprintf("%s",$$crcArr_ref[$idx-1]);
      }
    }

    for(my $idx=0;  $idx<$width;  $idx++) {
      $$crcArr_ref[$idx]  = $resArr[$idx];
    }
  }


  #------------------ Main Execution Block  -------------------------
  #Parse options
  GetOptions  ( "-polyWidth=i"  =>  \$polyWidth,
                "-polyHex=s"    =>  \$polyHex,
                "-dataWidth=i"  =>  \$dataWidth,
                "-h"            =>  \&disp_help
              )
  or die("Error parsing opts!\n");


  #Check that options are defined
  if(!defined($polyWidth))  {
    die("Polynomial width is not defined!");
  }

  if(!defined($polyHex))  {
    die("Polynomial value is not defined!");
  }

  if(!defined($dataWidth))  {
    die("Data width is not defined!");
  }

  $polyHex  =~  s/0x//;
  my  $mod_name = "crc${polyWidth}_d${dataWidth}";

  print "Generating ${mod_name}.v with polynomial 0x${polyHex} ... ";

  my  $polyBit  = unpack("B${polyWidth}", pack("H${polyWidth}", $polyHex));
  my  @polyBitArr = split(//,reverse($polyBit));

  my  @crcArr = ();
  for(my  $i=0; $i<$polyWidth;  $i++) {
    $crcArr[$i] = "crc[$i]";
  }

  open  my  $fHandle, '>',  "${mod_name}.v" or die("Could not open $mod_name.v\n");

  gen_mod_head($mod_name,$polyWidth,"0x${polyHex}",$dataWidth,$fHandle);

  for(my  $idx=$dataWidth-1;  $idx>=0;  $idx--) {
    div_data1($polyWidth,\@crcArr,\@polyBitArr,"data[$idx]");
  }

  for(my $idx=0;  $idx<$polyWidth;  $idx++) {
    print $fHandle  "        crc[$idx] <= $crcArr[$idx];\n";
  }

  print $fHandle  "      end\n";
  print $fHandle  "    end\n";
  print $fHandle  "  end\n\n";
  print $fHandle  "endmodule //${mod_name}\n";

  close($fHandle);

  print "Done\n";
