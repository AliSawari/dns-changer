import 'dart:io';

import 'package:dns_changer/src/models/network_interface_model.dart';
import 'package:dns_changer/src/util/dns_util.dart';

class DNSUtilLinuxImpl implements DNSUtil {
  // Get network interfaces string
  @override
  Future<String> getNetworkInterfacesRaw() async {
    final result =
        await Process.run('netsh', ['interface', 'show', 'interface']);

    return result.stdout;
  }

  // Extract list of network interfaces
  @override
  Future<List<NetworkInterfaceModel>> getNetworkInterfacesList() async => [];

  @override
  Future<List<String?>> getCurrentDNSServers({String interface = ""}) async {
    final result = await Process.run(
      'grep',
      ['nameserver' '/etc/resolv.conf', '|', 'awk', "'{print", r"$2}'"],
    );

    if ((result.stdout as String).isEmpty) {
      return [];
    }

    final ipPattern =
        RegExp(r'/(?<=nameserver\s)\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/g');
    final ipMatches = ipPattern.allMatches(result.stdout);
    final ips = ipMatches.map((match) => match.group(0)).toList();

    return ips;
  }

  @override
  Future<void> setDNS(
    String interface,
    String primary,
    String secondary,
  ) async {
    // Set primary DNS
    await Process.run('netsh', [
      'interface',
      'ipv4',
      'add',
      'dns',
      '"$interface"',
      primary,
    ]);

    // Set secondary DNS
    await Process.run('netsh', [
      'interface',
      'ipv4',
      'add',
      'dns',
      '"$interface"',
      secondary,
      'index=2'
    ]);
  }

  // Delete dns records
  @override
  Future<void> clearDNS(String interface) async => await Process.run(
      'netsh', ['interface', 'ip', 'set', 'dns', '"$interface"', 'dhcp']);

  // Flush dns
  @override
  Future<void> flushDNS() async => await Process.run('ipconfig', ['/flushdns']);

  @override
  Future<String> ping(String server) async {
    final result = await Process.run('ping', [server, '-c', '1']);

    if (result.stdout != "") {
      final regExp = RegExp(r"time=(?:(\d+) ms)|(?:(\d+\.\d+) ms)");
      final match = regExp.firstMatch(result.stdout);

      return match?.group(1) ?? match?.group(2) ?? "N/A";
    }

    return "N/A";
  }
}
