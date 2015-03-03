def os
  @os ||= (
    require "rbconfig"
    host_os = RbConfig::CONFIG['host_os'].downcase

    case host_os
    when /linux/
      :linux
    when /darwin|mac os/
      :macosx
    when /mswin|msys|mingw32/
      :windows
    when /cygwin/
      :cygwin
    when /solaris|sunos/
      :solaris
    when /bsd/
      :bsd
    when /aix/
      :aix
    else
      raise Error, "unknown os: #{host_os.inspect}"
    end
  )
end