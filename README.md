# ExtractBookz
I'm not a fan of ebooks released according to scene rules. That is, a PDF with a 8.3 filename inside multi-rars inside multi-zips inside a Dir-ect-tor-y. So I made a script with Ruby that extracts and renames the PDFs.
## Requirements: 
	* unzip and unrar in your path
	* Ruby (tested on 1.9.2) and wriggle (sudo gem install wriggle)
	* Un*x (tested on OS X)
Should work on Linux. Windows support soon.
## Usage:
	ruby ExtractBookz.rb source target
Source can either be a single directory like "~/My.Publisher.-.My.Crazy.Book.2011.ebook-DiGiBook/", or a folder that contains a bunch of those directories. ExtractBookz cleans up after itself, and won't delete or change the original directories. Target is where the PDFs will go. Use "quotes" around source and target if there are spaces in the pathname.
## TODO: 
	* Linux/Windows testing. Fewer requirements.
	* Set PDF "title" and "author" attributes.
	* GUI (Java or native)
