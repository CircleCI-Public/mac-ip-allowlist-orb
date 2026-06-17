#!/usr/bin/env bats

source ./src/tests/helpers/load_extensions.bash

@test "test enable" {
  stub networksetup \
    "-listallnetworkservices : echo 'An asterisk (*) denotes that a network service is disabled.'; echo 'Wi-Fi'; echo 'Ethernet'" \
    "-setv6off Wi-Fi : exit 0" \
    "-setv6off Ethernet : exit 0" \
    "-listallhardwareports : printf 'Hardware Port: Wi-Fi\nDevice: en0\nHardware Port: Ethernet\nDevice: en1\n'"

  # Match any device name — don't assume en0/en1 are the only valid names
  stub ifconfig \
    "* : echo 'inet 192.168.1.100 netmask 0xffffff00 broadcast 192.168.1.255'" \
    "* : echo 'inet 192.168.1.101 netmask 0xffffff00 broadcast 192.168.1.255'"

  stub sudo \
    "pfctl -E -f \* : echo \$4 > ${BATS_TEST_TMPDIR}/enabled_config" \
    "pfctl -s rules -a circleci.passlist : echo 'pass in quick from <passlist> user { testuser }'; echo 'pass out quick to <passlist> user { testuser }'" \
    "pfctl -s rules -a circleci.dns : echo 'pass out log quick inet proto tcp from any to 192.168.64.1 port 53'" \
    "pfctl -s rules -a circleci.ipv6block : echo 'block in quick inet6 all'; echo 'block out quick inet6 all'" \
    "pfctl -s rules -a circleci.blocklist : echo 'block in quick from <blocklist> user { testuser }'; echo 'block out quick from <blocklist> user { testuser }'" \
    "pfctl -t passlist -T show : echo '192.168.1.1'"

  run ./src/scripts/enable.sh

  assert_success
  assert_file_exists "${BATS_TEST_TMPDIR}"/enabled_config
  assert_file_contains "${BATS_TEST_TMPDIR}"/enabled_config "/opt/circleci/firewall/pf.conf"
  assert_output --partial "block in quick inet6 all"
  assert_output --partial "block out quick inet6 all"
  assert_output --partial "Disabling IPv6 on all network services"
  assert_output --partial "Verifying IPv6 has been disabled on all interfaces"

  unstub networksetup
  unstub ifconfig
  unstub sudo
}
