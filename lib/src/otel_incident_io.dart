// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_incident_io_suppression.dart';

const _tracerName = 'dartastic_otel_libs_incident_io';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class IncidentIoResult {
  const IncidentIoResult({
    this.entityKind,
    this.entityId,
    this.action,
    this.incidentMode,
    this.incidentVisibility,
    this.severity,
    this.incidentStatus,
    this.incidentTypeId,
    this.summary,
    this.callDurationSec,
    this.affectedCustomerCount,
    this.followUpCount,
    this.followUpsCompleted,
    this.actionRequiredCount,
    this.policyId,
    this.escalationLevel,
    this.escalationKind,
    this.onCallSchedule,
    this.alertSourceConfigId,
    this.workflowId,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// `incident`, `incident_role`, `incident_status`, `incident_type`,
  /// `incident_update`, `incident_attachment`, `incident_timestamp`,
  /// `severity`, `action`, `follow_up`, `escalation`, `on_call_schedule`,
  /// `policy`, `alert`, `alert_source_config`, `workflow`, `user`,
  /// `custom_field`, `post_mortem`.
  final String? entityKind;

  final String? entityId;

  /// `create`, `update`, `delete`, `list`, `get`, `accept`, `decline`,
  /// `escalate`, `acknowledge`.
  final String? action;

  /// `real`, `test`, `tutorial`, `stream`, `retrospective`.
  final String? incidentMode;

  /// `public`, `private`.
  final String? incidentVisibility;

  /// Severity rank name (`Critical`, `Major`, `Minor`, ...).
  final String? severity;

  /// `triage`, `investigating`, `fixing`, `monitoring`, `closed`,
  /// `merged`, `declined`, `paused`, `learning`, `resolved`,
  /// `customer_impact`, `monitoring`.
  final String? incidentStatus;

  final String? incidentTypeId;
  final String? summary;

  /// Total time spent on the call (`call_duration`).
  final int? callDurationSec;

  /// Recorded affected-customer count.
  final int? affectedCustomerCount;

  // ── Follow-ups + actions ───────────────────────────────────────
  final int? followUpCount;
  final int? followUpsCompleted;
  final int? actionRequiredCount;

  // ── On-call ───────────────────────────────────────────────────
  final String? policyId;
  final int? escalationLevel;

  /// `pagerduty`, `opsgenie`, `slack`, `email`, `sms`, `phone`.
  final String? escalationKind;

  final String? onCallSchedule;

  // ── Alerts + workflows ────────────────────────────────────────
  final String? alertSourceConfigId;
  final String? workflowId;

  /// API error code.
  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

class IncidentIoCallResult<T> {
  const IncidentIoCallResult({required this.value, this.result});
  final T value;
  final IncidentIoResult? result;
}

/// Wraps an incident.io API call in a CLIENT span. [operation] is one of
/// `incidents.list`, `incidents.create`, `incidents.get`, `incidents.edit`,
/// `incidents.close`, `incidentTypes.list`, `severities.list`,
/// `severities.get`, `incidentStatuses.list`, `incidentUpdates.list`,
/// `incidentRoles.list`, `incidentAttachments.list`,
/// `actions.list`, `actions.create`, `actions.update`, `actions.complete`,
/// `followUps.list`, `followUps.create`, `followUps.complete`,
/// `users.list`, `users.get`, `customFields.list`,
/// `escalations.list`, `escalations.create`, `escalations.acknowledge`,
/// `escalationPolicies.list`, `onCallSchedules.list`,
/// `onCallSchedules.create`, `alerts.list`, `alerts.create`,
/// `alertSourceConfigs.list`, `workflows.list`, `workflows.run`,
/// `postmortem.create`, `postmortem.get`.
Future<T> tracedIncidentIo<T>({
  required String operation,
  required Future<IncidentIoCallResult<T>> Function() invoke,
}) async {
  if (incidentIoInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'incident_io',
    'rpc.method': operation,
    'incident_io.operation': operation,
  };

  final span = _tracer().startSpan(
    'incident_io $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.entityKind != null) {
        extras.add(OTel.attributeString(
          'incident_io.entity.kind',
          res.entityKind!,
        ));
      }
      if (res.entityId != null) {
        extras.add(OTel.attributeString(
          'incident_io.entity.id',
          res.entityId!,
        ));
      }
      if (res.action != null) {
        extras.add(OTel.attributeString('incident_io.action', res.action!));
      }
      if (res.incidentMode != null) {
        extras.add(OTel.attributeString(
          'incident_io.incident.mode',
          res.incidentMode!,
        ));
      }
      if (res.incidentVisibility != null) {
        extras.add(OTel.attributeString(
          'incident_io.incident.visibility',
          res.incidentVisibility!,
        ));
      }
      if (res.severity != null) {
        extras.add(OTel.attributeString(
          'incident_io.severity',
          res.severity!,
        ));
        if (res.severity == 'Critical') {
          span.setStatus(SpanStatusCode.Error, 'incident.io Critical');
        }
      }
      if (res.incidentStatus != null) {
        extras.add(OTel.attributeString(
          'incident_io.incident.status',
          res.incidentStatus!,
        ));
      }
      if (res.incidentTypeId != null) {
        extras.add(OTel.attributeString(
          'incident_io.incident.type_id',
          res.incidentTypeId!,
        ));
      }
      if (res.summary != null) {
        extras.add(OTel.attributeString(
          'incident_io.summary',
          res.summary!,
        ));
      }
      if (res.callDurationSec != null) {
        extras.add(OTel.attributeInt(
          'incident_io.call.duration_sec',
          res.callDurationSec!,
        ));
      }
      if (res.affectedCustomerCount != null) {
        extras.add(OTel.attributeInt(
          'incident_io.affected_customers',
          res.affectedCustomerCount!,
        ));
      }
      if (res.followUpCount != null) {
        extras.add(OTel.attributeInt(
          'incident_io.follow_ups.count',
          res.followUpCount!,
        ));
      }
      if (res.followUpsCompleted != null) {
        extras.add(OTel.attributeInt(
          'incident_io.follow_ups.completed',
          res.followUpsCompleted!,
        ));
      }
      if (res.actionRequiredCount != null) {
        extras.add(OTel.attributeInt(
          'incident_io.actions.required',
          res.actionRequiredCount!,
        ));
      }
      if (res.policyId != null) {
        extras.add(OTel.attributeString(
          'incident_io.policy.id',
          res.policyId!,
        ));
      }
      if (res.escalationLevel != null) {
        extras.add(OTel.attributeInt(
          'incident_io.escalation.level',
          res.escalationLevel!,
        ));
      }
      if (res.escalationKind != null) {
        extras.add(OTel.attributeString(
          'incident_io.escalation.kind',
          res.escalationKind!,
        ));
      }
      if (res.onCallSchedule != null) {
        extras.add(OTel.attributeString(
          'incident_io.on_call_schedule',
          res.onCallSchedule!,
        ));
      }
      if (res.alertSourceConfigId != null) {
        extras.add(OTel.attributeString(
          'incident_io.alert_source.config_id',
          res.alertSourceConfigId!,
        ));
      }
      if (res.workflowId != null) {
        extras.add(OTel.attributeString(
          'incident_io.workflow.id',
          res.workflowId!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTel.attributeString(
          'incident_io.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'incident.io ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'incident_io.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'incident.io HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
