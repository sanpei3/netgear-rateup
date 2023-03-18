# coding: utf-8
#
# tested Netgear
#       GS305E V1.0.0.9

require 'date'
router_ip = ARGV[0]
interface = ARGV[1]

backup_file ="/tmp/netgear-rateup-#{router_ip}.html"


html = ""
if (File.exist?(backup_file) && (DateTime.now.to_time - File.mtime(backup_file)) <= 120)
  File.open(backup_file, "r:UTF-8") do |body|
    body.each_line do |oneline|
      html = html + oneline
    end
  end
else
  require 'netrc'
  n = Netrc.read
  user, password = n[router_ip]
  require 'mechanize'
  # over write http-cookie routine
  module RespectDoubleQuotedCookieValue
    def self.prepended(klass)
      klass.singleton_class.prepend(ClassMethods)
    end
    module ClassMethods
      def quote(str)
        return str
      end
    end
  end
  HTTP::Cookie::Scanner.prepend(RespectDoubleQuotedCookieValue)

  agent = Mechanize.new
  url = "http://"+router_ip+"/login.cgi"
  agent.get(url)
  if (i = agent.page.body.match(/<input type=hidden id='rand' value='([0-9]+)' disabled>/))
    randStr = i[1]
  end

  passwdArray = password.split("")
  randStrArray = randStr.split("")
  mergedStr = ""
  i1 = 0
  i2 = 0
  while ((i1 < passwdArray.length) || (i2 < randStrArray.length))
         if (i1 < passwdArray.length)
           mergedStr += passwdArray[i1]
           i1 = i1 + 1
         end
         if (i2 < randStrArray.length)
           mergedStr += randStrArray[i2]
           i2 = i2 + 1
         end
  end
  require 'digest/md5'
  md5password =  Digest::MD5.hexdigest(mergedStr)

  options =           {
    "password" => md5password
  }
  url = "http://"+router_ip+"/login.cgi"
  page = agent.post(url, options)
  referer = url
  sleep(0.05)
  
  url = "http://"+router_ip+"/portStatistics.cgi"
  agent.get(url)
  html = agent.page.body.force_encoding("UTF-8").encode("UTF-8")
  File.write(backup_file, html)
  sleep(0.05)

  url = "http://"+router_ip+"/logout.cgi"
  agent.get(url)
end

interfaces =  Array.new(6) { Array.new(2,0) }
inout = 0
index = 1
html.each_line do |oneline|
  if (oneline =~ /^\<td class=\"def\" sel=\"text\"\>([0-9]+)/)
    interfaces[index][inout] = $1
    if (inout == 0)
      inout = inout + 1
    else
      inout = 0
      index = index + 1
    end
  end
end

puts interfaces[interface.to_i][0]
puts interfaces[interface.to_i][1]

