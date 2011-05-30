module ExtractBookz
	require 'rubygems' # Supports 1.8.7
	require 'FileUtils'
	require 'wriggle' # A DSL for Find
	$delete_tmp = true

	def self.process source, target
		# Sanitize
		source = File.expand_path(source)
		target = File.expand_path(target)
		raise "Source directory must exist" unless File.directory? source
		raise "Target directory must exist" unless File.directory? target

		# Is this a folder full of book directories or a single book directory?
		directory_count = 0
		wriggle source do |source_dir| 
			source_dir.directories do |sub_dirs| 
				directory_count += 1 # Note: Source counts as a directory
		end; end

		directory_count > 1 ? extract_folder(source, target) : extract_book(source, target)
	end

	def self.extract_folder folder, target
		# Scan folder for book directories
		wriggle folder do |scenefolder| 
			scenefolder.directories do |book_dir| 
				next if book_dir == folder || book_dir == target
				extract_book book_dir, target
		end; end 
	end 

	def self.extract_book book_dir, target
		# Get name and create tempory directory
		book_name = clean_name(book_dir)
		tmp_book_dir = "#{target}/#{book_name}"
		FileUtils.mkpath tmp_book_dir

		# Unzip to tempory directory
		wriggle book_dir do |book_dir_files| 
			book_dir_files.extensions %w(zip) do |zip| 
				`unzip -o #{zip} -d "#{tmp_book_dir}"` 
		end; end 

		# Unrar, move to target and rename
		`unrar -o+ -inul e "#{tmp_book_dir}/"*.rar "#{tmp_book_dir}"`
		`mv -f "#{tmp_book_dir}"/*.pdf "#{target}/#{book_name}.pdf"`

		FileUtils.rm_rf tmp_book_dir if $delete_tmp
	end

	def self.clean_name(book_dir)
		name = book_dir.dup # Not sure why this is necessary
		name.sub!(/\/$/,'') # remove ending / if exists
		name.sub!(/^.*\//,'') # remove from start to last / to get directory name only
		name.sub!(/.\d{4}.*$/,'') # from .YEAR to end
		name.sub!(/^.*-/,'') # from beginning to -
		name.gsub!('.',' ') # spaces for .
		name.gsub!('_',' ') # spaces for _
		name.strip! # trailing/leading whitespaces
		if book_dir[/BBL$/] || book_dir[/DDU$/] then # BBL/DDU releases 
			name.sub! /^\S*\s*/, '' # remove publisher (first word)
			name.sub! /\s.{3}$/,'' # remove three letter month
		end
		return name
		# Possible features: Heuristics, Keep year, keep publisher, keep edition
	end 
end 

# Until I create a real interface for this module...
if ARGV[0] then
	ExtractBookz.process ARGV[0], ARGV[1]
end
