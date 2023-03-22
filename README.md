# netgear-rateup

# Feature :
netgear-rateup is mrtg module for NetGear Gigabit Ethernet Switch Unmanaged (tested with GS308E and GS305E). It is used to monitor the traffic load on each port, with SNMP unsupported network switch.

![image](https://user-images.githubusercontent.com/10361358/226910635-155e4856-1e8b-4aa2-85ca-81fbeaae9d94.png)

# Usage :
Please refer sample configuration file(mrtg-sample.cfg) in the repository.

```
Target[NetGear_IP_1]: `/usr/bin/ruby /etc/netgear-rateup.rb [NetGear_IP] [PortNumber]`
```

Password for Ethernet Switch is in ~/.netrc.

```
machine 192.168.11.2
login UserName
password [Password for 192.168.11.2]
```

# CHANGES :
 * [2023/3/18]  use ~/.netrc for password
 * [2023/1/26]  third argument is changed from MD5 to real password
