// udpcount.click

// This file is a simple UDP/IP packet counter, meant to be used in the
// Linux kernel module. It counts UDP packets received on port 1234. (Change
// the argument to 'ip_classifier' to use a different port.) See
// 'udpgen.click' for a traffic generator corresponding to udpcount.click.

// The interface's hardware and IP addresses go here.
AddressInfo(me 1.0.0.1 0:0:c0:8a:67:ef);

classifier	:: Classifier(12/0800 /* IP packets */,
			      12/0806 20/0001 /* ARP requests */,
			      - /* everything else */);
ip_classifier	:: IPClassifier(dst udp port 1234 /* relevant UDP packets */,
				- /* everything else */);
in_device	:: PollDevice(me);
out		:: Queue(200) -> ToDevice(me);
to_host		:: ToHost;
ctr		:: Counter /* or AverageCounter */;

in_device -> classifier
	-> CheckIPHeader(14, CHECKSUM false) // don't check checksum for speed
	-> ip_classifier
	-> ctr
	-> Discard;
classifier[1] -> ARPResponder(me) -> out;
classifier[2] -> to_host;
ip_classifier[1] -> to_host;
