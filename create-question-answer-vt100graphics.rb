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
ROW_LENGTH = 80
PINK_COLOUR_PALETTE =
  %w[
    #7c383eff #8c055eff #90305dff #985672ff #9c004aff #9d6984ff #ab485bff #ab495cff
    #b94c66ff #bb3377ff #c6174eff #c62168ff #c62d42ff #c7607bff #c93756ff #c95efbff
    #c97376ff #cb416bff #cc338bff #cc33ccff #cd7584ff #ce6ba4ff #d0417eff #d04a70ff
    #d0576bff #d2738fff #d3507aff #d46a7eff #d58d8aff #d74894ff #d99294ff #d998a0ff
    #da467dff #da6d91ff #db4bdaff #dd00ccff #dd8374ff #df6fa1ff #e04f80ff #e34285ff
    #e4007cff #e4445eff #e94b7eff #e95295ff #e96a97ff #ea5a79ff #eb4962ff #ec6d71ff
    #f504c9ff #f5054fff #f56991ff #f62681ff #f77fbeff #fa6e79ff #fc0fc0ff #fe02a2ff
    #fe46a5ff #ff007eff #ff0090ff #ff0099ff #ff0789ff #ff1476ff #ff1493ff #ff787bff
  ].freeze
TRANSPARENT = '#00000000'.freeze
SWEET_CANYON_PALETTE =
  %w[
    #0f0e11ff #2d2c33ff #40404aff #51545cff #6b7179ff #7c8389ff #a8b2b6ff #d5d5d5ff
    #eeebe0ff #f1dbb1ff #eec99fff #e1a17eff #cc9562ff #ab7b49ff #9a643aff #86482fff
    #783a29ff #6a3328ff #541d29ff #42192cff #512240ff #782349ff #8b2e5dff #a93e89ff
    #d062c8ff
    #ec94eaff
    #f2bdfcff
    #eaebffff
    #a2fafaff
    #64e7e7ff
    #54cfd8ff
    #2fb6c3ff
    #2c89afff
    #25739dff
    #2a5684ff
    #214574ff
    #1f2966ff
    #101445ff
    #3c0d3bff
    #66164cff
    #901f3dff
    #bb3030ff
    #dc473cff
    #ec6a45ff
    #fb9b41ff
    #f0c04cff
    #f4d66eff
    #fffb76ff
    #ccf17aff
    #97d948ff
    #6fba3bff
    #229443ff
    #1d7e45ff
    #116548ff
    #0c4f3fff
    #0a3639ff
    #251746ff
    #48246dff
    #69189cff
    #9f20c0ff
    #e527d2ff
    #ff51cfff
    #ff7adaff
    #ff9edbff
  ].freeze

def calc_num_rows(content)
  length = content.length
  (length % ROW_LENGTH).zero? ? length.div(ROW_LENGTH) : length.div(ROW_LENGTH) + 1
end

def add_colours_based_on_text(palette, pixels, text)
  palette_length = palette.length
  text_length_mod80 = text.length % ROW_LENGTH
  text_bytes = text.unpack('U*')
  text_bytes.each do |t|
    pixels.push(palette[t % palette_length])
  end
  # if it's not a multiple of ROW_LENGTH characters, pad with white
  return pixels if text_length_mod80.zero?

  pixels += Array.new(ROW_LENGTH - text_length_mod80) { TRANSPARENT }
end

if ARGV.length < 2
  puts "usage: #{$PROGRAM_NAME} <questions_CSV_file> <answers_CSV_file>"
  exit
end

all_questions = CSV.read(ARGV[0], headers: true)
all_answers = CSV.read(ARGV[1], headers: true)\

fn_str = 'tb-question-colours-%<id>s-%<yyyy>4.4d-%<mm>2.2d-%<dd>2.2d-%<hh>2.2d-'
fn_str += '%<min>2.2d-%<ss>2.2d-80x%<num_rows>d.text'

all_questions.each do |q|
  pixels = []
  id = q['id']
  num_rows = calc_num_rows(q['title'])
  pixels = add_colours_based_on_text(PINK_COLOUR_PALETTE, pixels, q['title'])
  num_rows += calc_num_rows(q['content'])
  pixels = add_colours_based_on_text(PINK_COLOUR_PALETTE, pixels, q['content'])
  question_creator = q['creator']
  created = Time.parse(q['created']).utc
  answers = all_answers.find_all { |a| a['question_id'] == id }
  answers.each do |a|
    num_rows += calc_num_rows(a['content'])
    pixels = if a['creator'] == question_creator
               add_colours_based_on_text(PINK_COLOUR_PALETTE, pixels, a['content'])
             else
               add_colours_based_on_text(SWEET_CANYON_PALETTE, pixels, a['content'])
             end
  end
  filename = format(
    fn_str,
    id: id, yyyy: created.year, mm: created.month, dd: created.day,
    hh: created.hour, min: created.min, ss: created.sec, num_rows: num_rows
  )
  File.open(filename, 'w+') do |f|
    f.puts(pixels)
  end
end
