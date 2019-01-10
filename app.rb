require 'trello'
require 'terminal-table'

SKIPPED_LISTS = ['Inbox', 'Pending approval']

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_PUBLIC_KEY']
  config.member_token = ENV['TRELLO_TOKEN']
end

board = Trello::Board.find(ENV['TRELLO_BOARD_ID'])

board_points = board.lists.map do |list|
  points_per_list = list.cards.map do |card|
    card.labels.select { |l| l.color == 'blue' }.first
  end.compact.map { |l| l.name.to_i }.sum

  [list.name, points_per_list]
end

points = board_points.dup

deliverable_points = board_points.dup.select do |list|
  !SKIPPED_LISTS.include?(list.first)
end

points << :separator
points << ['Total deliverable', deliverable_points.map { |ary| ary.last}.sum]
points << :separator
points << ['Total', board_points.map { |ary| ary.last}.sum]

table = Terminal::Table.new rows: points

puts table
