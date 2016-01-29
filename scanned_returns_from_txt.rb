require 'csv'

def keep?(header)
  ['Account ID',
  'Letter Date',
  'First Name',
  'Last Name',
  'Address Line 1',
  'Address Line 2',
  'City',
  'State',
  'ZIP Code'].include?(header)
end


puts "Finding files"

files = Dir.glob('*.csv')
scannedFileName = Dir.glob("*.txt")[0]
account_ids = IO.readlines(scannedFileName)
account_ids.map!(&:chomp)
returns = account_ids.count

puts "\nFiles found"


puts "Processing..."

master_header = CSV.parse_line(File.open(files[0], &:gets))

files.each do |file|
  header = File.open(file, &:gets)
  master_header & CSV.parse_line(header)
end

master_header.keep_if {|header| keep?(header) }

CSV.open("#{Date.today.strftime("%m-%d-%Y returns")}.csv", 'w') do |out|

  out << master_header

  files.each do |file|
    CSV.foreach(file, headers: true) do |row|
      if account_ids.include?(row['Account ID'])
        out << master_header.map { |header| row[header] }
        account_ids.delete(row['Account ID'])
      end
    end
  end
end

puts account_ids.empty? ? "All #{returns} scanned entries found" : "Could not find #{account_ids.join(", ")}"

gets