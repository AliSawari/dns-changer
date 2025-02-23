import 'package:dns_changer/src/models/network_interface_model.dart';

abstract class DNSUtil {
  Future<String> getNetworkInterfacesRaw();
  Future<List<NetworkInterfaceModel>> getNetworkInterfacesList();
  Future<List<String?>> getCurrentDNSServers({String interface = ""});
  Future<bool> isIPV6Enabled(String interface);
  Future<void> changeIPV6Status(String interface, bool enabled);
  Future<String> ping(String server);
  Future<void> setDNS(String interface, String primary, String secondary);
  Future<void> clearDNS(String interface);
  Future<void> flushDNS();
}
