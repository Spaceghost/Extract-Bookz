# ExtractBookz
I'm not a fan of ebooks released according to scene rules. That is, a PDF with a 8.3 filename inside multi-rars inside multi-zips inside a Dir-ect-tor-y. So I made a script with Ruby that extracts and renames the PDFs.
## Requirements: 
	* unzip and unrar in your path 
		* OS X: Install unrar with MacPorts or Homebrew
	* Ruby
		* Install wriggle gem with "sudo gem install wriggle"
	* Un*x (tested on OS X, should work on Linux)
		* Windows support soon.
## Usage:
	ruby ExtractBookz.rb "source" "target"
Source can either be a single directory like "~/My.Publisher.-.My.Crazy.Book.2011.ebook-DiGiBook/", or a folder that contains a bunch of those directories. ExtractBookz cleans up after itself, and won't delete or change the original directories. Target is where the PDFs will go.
## TODO: 
	* Linux/Windows testing. 
	* Set PDF "title" and "author" attributes.
	* MacRuby GUI (Looking for JRuby or IronRuby guys, too)
