# coding: utf-8
#
# tested Netgear
#       GS305E V1.0.0.9

require 'date'
router_ip = ARGV[0]
interface = ARGV[1]
#
# password is MD5 format. you can get MD5 format from packet dump or chrome developer mode
#
password = ARGV[2]

backup_file ="/tmp/netgear-rateup-#{router_ip}.html"


html = ""
if (File.exist?(backup_file) && (DateTime.now.to_time - File.mtime(backup_file)) <= 120)
  File.open(backup_file, "r:UTF-8") do |body|
    body.each_line do |oneline|
      html = html + oneline
    end
  end
else
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

  options =           {
    "password" => password
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

