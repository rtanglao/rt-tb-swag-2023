#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'amazing_print'
require 'json'
require 'time'
require 'date'
require 'csv'
require 'logger'
require 'bindata'

logger = Logger.new($stderr)
logger.level = Logger::DEBUG
# From https://simplicable.com/colors/dark-pink "64 Types of Dark Pink"
ROW_LENGTH = 80
PINK_COLOUR_PALETTE =
  [
    0x7c383eff, 0x8c055eff, 0x90305dff, 0x985672ff, 0x9c004aff, 0x9d6984ff, 0xab485bff, 0xab495cff,
    0xb94c66ff, 0xbb3377ff, 0xc6174eff, 0xc62168ff, 0xc62d42ff, 0xc7607bff, 0xc93756ff, 0xc95efbff,
    0xc97376ff, 0xcb416bff, 0xcc338bff, 0xcc33ccff, 0xcd7584ff, 0xce6ba4ff, 0xd0417eff, 0xd04a70ff,
    0xd0576bff, 0xd2738fff, 0xd3507aff, 0xd46a7eff, 0xd58d8aff, 0xd74894ff, 0xd99294ff, 0xd998a0ff,
    0xda467dff, 0xda6d91ff, 0xdb4bdaff, 0xdd00ccff, 0xdd8374ff, 0xdf6fa1ff, 0xe04f80ff, 0xe34285ff,
    0xe4007cff, 0xe4445eff, 0xe94b7eff, 0xe95295ff, 0xe96a97ff, 0xea5a79ff, 0xeb4962ff, 0xec6d71ff,
    0xf504c9ff, 0xf5054fff, 0xf56991ff, 0xf62681ff, 0xf77fbeff, 0xfa6e79ff, 0xfc0fc0ff, 0xfe02a2ff,
    0xfe46a5ff, 0xff007eff, 0xff0090ff, 0xff0099ff, 0xff0789ff, 0xff1476ff, 0xff1493ff, 0xff787bff
  ].freeze

TRANSPARENT = 0
SWEET_CANYON_PALETTE =
  [
    0x0f0e11ff, 0x2d2c33ff, 0x40404aff, 0x51545cff, 0x6b7179ff, 0x7c8389ff, 0xa8b2b6ff, 0xd5d5d5ff,
    0xeeebe0ff, 0xf1dbb1ff, 0xeec99fff, 0xe1a17eff, 0xcc9562ff, 0xab7b49ff, 0x9a643aff, 0x86482fff,
    0x783a29ff, 0x6a3328ff, 0x541d29ff, 0x42192cff, 0x512240ff, 0x782349ff, 0x8b2e5dff, 0xa93e89ff,
    0xd062c8ff,
    0xec94eaff,
    0xf2bdfcff,
    0xeaebffff,
    0xa2fafaff,
    0x64e7e7ff,
    0x54cfd8ff,
    0x2fb6c3ff,
    0x2c89afff,
    0x25739dff,
    0x2a5684ff,
    0x214574ff,
    0x1f2966ff,
    0x101445ff,
    0x3c0d3bff,
    0x66164cff,
    0x901f3dff,
    0xbb3030ff,
    0xdc473cff,
    0xec6a45ff,
    0xfb9b41ff,
    0xf0c04cff,
    0xf4d66eff,
    0xfffb76ff,
    0xccf17aff,
    0x97d948ff,
    0x6fba3bff,
    0x229443ff,
    0x1d7e45ff,
    0x116548ff,
    0x0c4f3fff,
    0x0a3639ff,
    0x251746ff,
    0x48246dff,
    0x69189cff,
    0x9f20c0ff,
    0xe527d2ff,
    0xff51cfff,
    0xff7adaff,
    0xff9edbff
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
fn_str += '%<min>2.2d-%<ss>2.2d-80x%<num_rows>d.rgba'

binary_data = BinData::Array.new(type: :Uint32be)
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
  binary_data.assign(pixels)
  File.open(filename, 'wb') do |io|
    binary_data.write(io)
  end
end
