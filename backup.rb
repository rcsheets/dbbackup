#!/usr/bin/env ruby

require 'tempfile'
require 'time'

# Cross-platform way of finding an executable in the $PATH.
#
#   which('ruby') #=> /usr/bin/ruby
#
# Function based on code found at http://stackoverflow.com/a/5471032/221689
def which!(cmd)
  found = which(cmd)
  throw "I could not find #{cmd}" if found.nil?
  found
end

def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable? exe
    }
  end
  nil
end

mysqldump = which!('mysqldump')
mysql = which!('mysql')

puts "mysql found: #{mysql}"
puts "mysqldump found: #{mysqldump}"

exclude = [
  'mysql',                # system database treated specially
  '#mysql50#lost+found',  # horrible non-actual database
  'lost+found',           # see above
  'information_schema',   # we don't ever need to back this up, right?
]

# Get a list of databases other than the ones in the exclude array
query = "select schema_name from schemata where NOT (schema_name IN (#{exclude.map {|x| "'#{x}'"}.join(',')}))"

# This will fail horribly if our excluded databases have shell metacharacters.
# Obviously we should not shell out to mysql at all.
databases = %x{#{mysql} -BN -e "#{query}" information_schema}.split(' ')

start_time = Time.now.utc.iso8601
puts "#{start_time} Backup process starting"

if not Dir.exist?("/srv/dbbackup/some_host")
  Dir.mkdir("/srv/dbbackup/some_host")
end

databases.each do |db|
  outdir = "/srv/dbbackup/some_host/#{db}"
  if not Dir.exist?(outdir)
    puts "Output directory #{outdir} does not exist..."
    Dir.mkdir(outdir)
  end

  output = %x{#{mysqldump} -r #{outdir}/#{Time.now.utc.iso8601.tr!('-:','')}.sql #{db}}
end
end_time = Time.now.utc.iso8601

puts "#{end_time} Backup process complete"

