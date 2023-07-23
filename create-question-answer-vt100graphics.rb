require 'rubygems'
require 'bundler/setup'
require 'amazing_print'
require 'json'
require 'time'
require 'date'
require 'csv'
require 'logger'
logger = Logger.new($stderr)
logger.level = Logger::DEBUG
# From https://simplicable.com/colors/dark-pink "64 Types of Dark Pink"
PINK_COLOUR_PALETTE =
  %w[
    #7c383e #8c055e #90305d #985672 #9c004a #9d6984 #ab485b #ab495c
    #b94c66 #bb3377 #c6174e #c62168 #c62d42 #c7607b #c93756 #c95efb
    #c97376 #cb416b #cc338b #cc33cc #cd7584 #ce6ba4 #d0417e #d04a70
    #d0576b #d2738f #d3507a #d46a7e #d58d8a #d74894 #d99294 #d998a0
    #da467d #da6d91 #db4bda #dd00cc #dd8374 #df6fa1 #e04f80 #e34285
    #e4007c #e4445e #e94b7e #e95295 #e96a97 #ea5a79 #eb4962 #ec6d71
    #f504c9 #f5054f #f56991 #f62681 #f77fbe #fa6e79 #fc0fc0 #fe02a2
    #fe46a5 #ff007e #ff0090 #ff0099 #ff0789 #ff1476 #ff1493 #ff787b
  ].freeze
if ARGV.length < 2
  puts "usage: #{$PROGRAM_NAME} <questions_CSV_file> <answers_CSV_file>"
  exit
end
