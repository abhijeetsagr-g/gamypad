import 'package:gamypad_controller/src/connection/connection_target.dart';
import 'package:test/test.dart';

/// [UdpTarget.parse] is the gate between a scanned QR code and a socket, so it
/// is the one piece of connection setup a user can reach with a camera pointed
/// at the wrong thing. Every case here is something a real QR code can contain.
void main() {
  group('parse accepts', () {
    test('the exact payload gamypad_pc encodes', () {
      // PairingPanel builds `'$ip:$port'` from an IPv4 NetworkInterface lookup.
      // This is the cross-half contract: whatever the PC puts in the QR code,
      // this must read back.
      final target = UdpTarget.parse('10.0.0.5:41234');
      expect(target.host, '10.0.0.5');
      expect(target.port, 41234);
    });

    test('surrounding whitespace', () {
      final target = UdpTarget.parse('  192.168.1.7:41234  ');
      expect(target.host, '192.168.1.7');
      expect(target.port, 41234);
    });

    test('the lowest port', () {
      expect(UdpTarget.parse('10.0.0.5:1').port, 1);
    });

    test('the highest port', () {
      expect(UdpTarget.parse('10.0.0.5:65535').port, 65535);
    });

    test('a hostname, since lookup can resolve one', () {
      expect(UdpTarget.parse('gamypad.local:9000').host, 'gamypad.local');
    });

    test('whitespace around the port, because int.tryParse trims it', () {
      // Deliberate leniency rather than an accident: `int.tryParse` accepts
      // " 41234", and refusing it would mean hand-rolling a stricter parse for
      // no benefit. The PC's QR code never contains a space anyway. Pinned so
      // nobody later reads it as unspecified behaviour and tightens it.
      expect(UdpTarget.parse('10.0.0.5: 41234').port, 41234);
    });

    test('extra colons past the port are rejected rather than truncated', () {
      // indexOf finds the *first* colon, so this leaves '41234:5678' as the
      // port — which must not parse as 41234.
      expect(
        () => UdpTarget.parse('10.0.0.5:41234:5678'),
        throwsFormatException,
      );
    });
  });

  group('parse rejects', () {
    /// Each of these is a string a camera can plausibly hand us. None may
    /// produce a target, because a target that silently points somewhere
    /// unexpected is worse than a visible failure.
    const bad = <String, String>{
      'an empty string': '',
      'only whitespace': '   ',
      'a host with no port': '10.0.0.5',
      'a host with an empty port': '10.0.0.5:',
      'an empty host': ':41234',
      'port zero, which means bind-me-an-ephemeral-one': '10.0.0.5:0',
      'a port above 65535': '10.0.0.5:65536',
      'a wildly out-of-range port': '10.0.0.5:99999999',
      'a negative port': '10.0.0.5:-1',
      'a non-numeric port': '10.0.0.5:abc',
      'a port with trailing text': '10.0.0.5:41234abc',
      'a URL': 'http://10.0.0.5:41234',
      'something unrelated entirely': 'hello world',
    };

    bad.forEach((description, payload) {
      test(description, () {
        expect(
          () => UdpTarget.parse(payload),
          throwsFormatException,
          reason: 'payload: "$payload"',
        );
      });
    });

    test('the error names what was expected', () {
      // A FormatException the user never sees is still worth making legible to
      // whoever debugs the scanner.
      expect(
        () => UdpTarget.parse('10.0.0.5'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('host:port'),
          ),
        ),
      );
    });
  });

  group('tryParse', () {
    test('returns null instead of throwing', () {
      // For the scanner: a code that is not a pairing target should leave the
      // form empty, not raise across the async gap in onDetect.
      expect(UdpTarget.tryParse('some other qr code'), isNull);
    });

    test('returns a target for a good payload', () {
      expect(UdpTarget.tryParse('10.0.0.5:41234')?.port, 41234);
    });

    test('agrees with parse on every accepted payload', () {
      for (final payload in [
        '10.0.0.5:41234',
        ' 10.0.0.5:1 ',
        'gamypad.local:65535',
      ]) {
        expect(
          UdpTarget.tryParse(payload)?.toString(),
          UdpTarget.parse(payload).toString(),
        );
      }
    });

    test('agrees with parse on every rejected payload', () {
      for (final payload in ['', 'nope', '10.0.0.5:', ':1', 'a:0']) {
        expect(UdpTarget.tryParse(payload), isNull);
      }
    });
  });

  group('toString', () {
    test('is the inverse of parse', () {
      const payloads = ['10.0.0.5:41234', '192.168.1.7:1', 'host.local:65535'];
      for (final payload in payloads) {
        expect(UdpTarget.parse(payload).toString(), payload);
      }
    });

    test('is the form the user is shown, so it must round-trip', () {
      final target = UdpTarget(host: '10.0.0.5', port: 41234);
      expect(target.toString(), '10.0.0.5:41234');
      expect(UdpTarget.parse(target.toString()).host, target.host);
      expect(UdpTarget.parse(target.toString()).port, target.port);
    });
  });

  group('ConnectionTarget', () {
    test('is sealed, so a new transport kind is a compile-time decision', () {
      // Compile-time property, asserted here only as documentation: adding a
      // second target type would force every switch over ConnectionTarget to
      // decide what to do with it, rather than silently skipping it.
      expect(UdpTarget(host: 'h', port: 1), isA<ConnectionTarget>());
    });
  });
}
