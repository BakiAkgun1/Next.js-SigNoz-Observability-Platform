const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http');
const { Resource } = require('@opentelemetry/resources');

const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({
    url: 'http://localhost:4318/v1/traces',
    headers: {
      'Content-Type': 'application/json',
    },
  }),
  instrumentations: [getNodeAutoInstrumentations()],
  resource: new Resource({
    'service.name': 'nextjs-signoz-app',
    'service.version': '1.0.0',
    'deployment.environment': 'development',
  }),
});

sdk.start();
