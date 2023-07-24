#!/usr/bin/env ruby

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
WHITE = '#ffffff'.freeze
SWEET_CANYON_PALETTE =
  %w[
    #0f0e11 #2d2c33 #40404a #51545c #6b7179 #7c8389 #a8b2b6 #d5d5d5
    #eeebe0 #f1dbb1 #eec99f #e1a17e #cc9562 #ab7b49 #9a643a #86482f
    #783a29 #6a3328 #541d29
    #42192c
    #512240
    #782349
    #8b2e5d
    #a93e89
    #d062c8
    #ec94ea
    #f2bdfc
    #eaebff
    #a2fafa
    #64e7e7
    #54cfd8
    #2fb6c3
    #2c89af
    #25739d
    #2a5684
    #214574
    #1f2966
    #101445
    #3c0d3b
    #66164c
    #901f3d
    #bb3030
    #dc473c
    #ec6a45
    #fb9b41
    #f0c04c
    #f4d66e
    #fffb76
    #ccf17a
    #97d948
    #6fba3b
    #229443
    #1d7e45
    #116548
    #0c4f3f
    #0a3639
    #251746
    #48246d
    #69189c
    #9f20c0
    #e527d2
    #ff51cf
    #ff7ada
    #ff9edb
  ].freeze

def add_colours_based_on_text(palette, pixels, text)
  palette_length = palette.length
  text_length_mod80 = text.length % 80
  text_bytes = text.unpack('U*')
  text_bytes.each do |t|
    pixels.push(palette[(t % palette_length) + 1])
  end
  # if it's not a multiple of 80 characters, pad with white
  return pixels if text_length_mod80.zero?

  pixels += Array.new(80 - text_length_mod80) { WHITE }
end

if ARGV.length < 2
  puts "usage: #{$PROGRAM_NAME} <questions_CSV_file> <answers_CSV_file>"
  exit
end

all_questions = CSV.read(ARGV[0], headers: true)
all_answers = CSV.read(ARGV[1], headers: true)\

fn_str = 'tb-question-colours-%<id>s-%<yyyy>4.4d-%<mm>2.2d-%<dd>2.2d-%<hh>2.2d-%<min>2.2d-%<ss>2.2d.text'

all_questions.each do |q|
  pixels = []
  id = q['id']
  pixels = add_colours_based_on_text(PINK_COLOUR_PALETTE, pixels, q['title'])
  pixels = add_colours_based_on_text(PINK_COLOUR_PALETTE, pixels, q['content'])
  question_creator = q['creator']
  created = Time.parse(q['created']).utc
  answers = all_answers.find_all { |a| a['question_id'] == id }
  answers.each do |a|
    pixels = if a['creator'] == question_creator
               add_colours_based_on_text(PINK_COLOUR_PALETTE, pixels, a['content'])
             else
               add_colours_based_on_text(SWEET_CANYON_PALETTE, pixels, a['content'])
             end
  end
  filename = format(
    fn_str,
    id: id, yyyy: created.year, mm: created.month, dd: created.day,
    hh: created.hour, min: created.min, ss: created.sec
  )
  File.open(filename, 'w+') do |f|
    f.puts(pixels)
  end
end
