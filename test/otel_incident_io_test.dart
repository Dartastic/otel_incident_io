// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_incident_io/otel_incident_io.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_incident_io-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('incidents.create records severity + status + customers', () async {
    await tracedIncidentIo<String>(
      operation: 'incidents.create',
      invoke: () async => const IncidentIoCallResult(
        value: 'ok',
        result: IncidentIoResult(
          entityKind: 'incident',
          action: 'create',
          incidentMode: 'real',
          incidentVisibility: 'public',
          severity: 'Major',
          incidentStatus: 'investigating',
          affectedCustomerCount: 12000,
          followUpCount: 4,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('incident_io incidents.create')!);
    expect(a['incident_io.severity'], 'Major');
    expect(a['incident_io.affected_customers'], 12000);
  });

  test('Critical severity sets span error', () async {
    await tracedIncidentIo<String>(
      operation: 'incidents.create',
      invoke: () async => const IncidentIoCallResult(
        value: 'ok',
        result: IncidentIoResult(severity: 'Critical'),
      ),
    );
    expect(
      spans.findSpanByName('incident_io incidents.create')!.status,
      SpanStatusCode.Error,
    );
  });

  test('escalations.create records policy + kind', () async {
    await tracedIncidentIo<String>(
      operation: 'escalations.create',
      invoke: () async => const IncidentIoCallResult(
        value: 'ok',
        result: IncidentIoResult(
          entityKind: 'escalation',
          policyId: 'pol_1',
          escalationLevel: 2,
          escalationKind: 'pagerduty',
        ),
      ),
    );
    final a = attrsOf(
      spans.findSpanByName('incident_io escalations.create')!,
    );
    expect(a['incident_io.escalation.level'], 2);
    expect(a['incident_io.escalation.kind'], 'pagerduty');
  });

  test('suppression skips spans', () async {
    await runWithoutIncidentIoInstrumentationAsync(() async {
      await tracedIncidentIo<String>(
        operation: 'severities.list',
        invoke: () async => const IncidentIoCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('incident_io '), isEmpty);
  });
}
