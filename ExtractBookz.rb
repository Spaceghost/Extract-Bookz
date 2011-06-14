module ExtractBookz
	require 'rubygems' # Supports 1.8.7
	require 'FileUtils'
	require 'wriggle' # A DSL for Find

	def self.process source, target
		# Sanitize directory strings
		source = File.expand_path(source)
		target = File.expand_path(target)
		# Confirm directories
		raise "Source directory must exist!" unless File.directory? source
		raise "Target directory must exist!" unless File.directory? target
		# Confirm tools
		raise "unzip must be in path!" unless which "unzip"
		raise "unrar must be in path!" unless which "unrar"
		raise "exiftool must be in path!" unless which "exiftool"

		# Is this a folder full of book directories or a single book directory?
		directory_count = 0
		wriggle source do |source_dir| 
			source_dir.directories do |sub_dirs| 
				directory_count += 1 # Note: Source counts as a directory
		end; end

		directory_count > 1 ? extract_folder(source, target) : extract_book(source, target)
	end

	private
	def self.which(cmd)
	# Cross-platform way of finding an executable in the $PATH.
		exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
		ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
			exts.each do |ext|
				exe = "#{path}/#{cmd}#{ext}"
				return exe if File.executable? exe
		end; end
		return nil
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

		`unrar -o+ -inul e "#{tmp_book_dir}/"*.rar "#{tmp_book_dir}"`
		`mv -f "#{tmp_book_dir}"/*.pdf "#{target}/#{book_name}.pdf"`
		`exiftool -Title="#{book_name}" "#{target}/#{book_name}.pdf" -overwrite_original`
		FileUtils.rm_rf tmp_book_dir
	end

	def self.clean_name(book_dir)
		clean_name = book_dir.sub(/\/$/,'') # remove ending / if exists
		.sub(/^.*\//,'') # remove from start to last / to get directory name only
		.sub(/.\d{4}.*$/,'') # from .YEAR to end
		.sub(/^.*-/,'') # from beginning to -
		.gsub('.',' ') # spaces for .
		.gsub('_',' ') # spaces for _
		.strip # trailing/leading whitespaces
		if book_dir =~ /[BBL|DDU]$/ then # BBL/DDU releases 
			clean_name = clean_name.sub(/^\S*\s*/, '') # remove publisher (first word)
			.sub(/\s.{3}$/,'') # remove three letter month
		end
		return clean_name
	end 
end 

# Until I create a real interface for this module...
if ARGV[0] then
	ExtractBookz.process ARGV[0], ARGV[1]
end
