def choose_file
  case os
  when :macosx
    command = "osascript -e 'set the_file to choose file name with prompt \"Select an output file\"' -e 'set the result to POSIX path of the_file'"
    File.absolute_path(`#{command}`.strip)
  else
    File.absolute_path(gets)
  end
end